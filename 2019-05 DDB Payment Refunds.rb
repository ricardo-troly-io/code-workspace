cids = Payment.where(:company_id => 10082, :created_at => Date.parse('2019-05-25')..Date.parse('2019-05-27'), :status => 'success', :trx => ['auth', 'charge']).pluck(:customer_id);

res = Stream.where(:company_id => 10082, :customer_id => cids, :what => 'payment', :operation => 'charge', :created_at => Date.parse('2019-05-25')..Date.parse('2019-05-27')).order(customer_id: :asc, created_at: :asc);


#####
# If we process a reference, lets not worry about it again
# ----
# This loop checks the payment exists; no payment means auotmatic refund.
# If it does exist, we need to check if DDB have refunded already
# If it does exist and no refund is found, if there is only one, then we are OK
# Otherwise, mark for refund.
#####

pp = []
res.each do |d|
    next if pp.include?(d.data[:ref])
    pp << d.data[:ref]
    p1 = Payment.find_by_ref d.data[:ref]
    c = Customer.find(d.customer_id);
    if p1.present?
        
        oih = OrderInvoiceHistory.where(:order_id => OrderInvoiceHistory.find_by_invoice_id(p1.invoice_id).order_id)

        #####
        # If the payment is found, lets try to find all associated payments on that invoice
        # If we see auth->charge->refund, or charge->refund, then mark as REFUNDED
        # Otherwise, we have to do some digging
        #####
        is_refunded = false
        tracks = {'auth' => 0, 'charge' => 0, 'refund' => 0, 'void_auth' => 0}
        Payment.where(:invoice_id => p1.invoice_id, :status => 'success', :ref => p1.ref).order(id: :asc).each do |pay|
            tracks[pay.trx] += 1
        end

            
        is_refunded = true if tracks['auth'] > 0 && (tracks['auth'] + -tracks['void_auth']) == tracks['charge'] && tracks['charge'] == tracks['refund']

        if tracks['auth'] == 0 && tracks['charge'] > 0
            is_refunded = (tracks['charge'] == tracks['refund'])
        end

        ###
        # If we have been refunded, lets report it and go to the next one
        ###
        ref_count = Payment.where(:ref => d.data[:ref]).count
        puts ['REFUNDED', d.created_at.strftime("%F %T"), d.data[:ref], d.operation, p1.invoice_id, oih.first.order_id, ref_count, Order.find(oih.first.order_id).number, c.id, c.name, d.data[:amount]].join("\t") if is_refunded
        next if is_refunded
        
        p_count = Payment.where(:invoice_id => p1.invoice_id, :status => 'success').group_by(&:trx).map{|k,v| v.count < 2 ? 0 : v.count}.sum
        action = 'KEEP'

        ####
        # If an order was refunded, then we need to see if the previous invoice was processed OK
        ####
        if Order.where(:id => oih.pluck(:order_id).uniq).pluck(:invoice_id).include?(p1.invoice_id)
            if p_count == 0 && Payment.where(:invoice_id => p1.invoice_id, :status => 'success', :trx => 'refund', :ref => p1.ref).count == 1
                action = 'REFUNDED'
            end
        else
            action = 'REFUND'
        end
        puts [action, d.created_at.strftime("%F %T"), d.data[:ref], d.operation, p1.invoice_id, oih.first.order_id, ref_count, Order.find(oih.first.order_id).number, c.id, c.name, d.data[:amount]].join("\t")  
    else
        ref_count = Payment.where(:ref => d.data[:ref]).count
        puts ['REFUND', d.created_at.strftime("%F %T"), d.data[:ref], d.operation, '', '', ref_count, c.orders.last.number, c.id, c.name, d.data[:amount]].join("\t")  
    end
end;
