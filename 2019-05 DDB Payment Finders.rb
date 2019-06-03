r1 = ['ch_1EeHH6J8DTnfVsUvzu9ey7Dl','ch_1EeHGjJ8DTnfVsUvr63zBpYb','ch_1EeHHUJ8DTnfVsUvOfFRQAap0']
include ActionView::Helpers::NumberHelper

Stripe.api_key = Integration.for_company(10082).where(:provider => 'Stripe').last.params[:api_key]

r1.map do |ref,customer_id|
    ch = Stripe::Charge.retrieve(ref)
    data = {}
    if ch.refunded == true
        puts "REFUNDED ALREADY - #{ref}"
        next
    end
    if ch.status == 'succeeded'
        print "PREPARING TO REFUND #{ref}\t"
        res = ch.refund

        data = {
				:amount => number_to_currency(ch.amount/100.00, :unit => '$'),
				:cc_on_file => "#{ch.payment_method_details.card.brand.titlecase} (ends #{ch.payment_method_details.card.last4}) ",
				:ref => res['id'],
				:auth => '',
                :rrn => res['id']
            }

        Stream::make("payment.refund", data, customer_id, 10082, data, timeframe = 0.seconds)
            
        puts res['status']
    else
        puts "FAILED #{ref} - #{ch.status}"
    end
    data
end



r4.map do |ref,customer_id|
    pay = Payment.where(:ref => ref, :trx => 'charge', :status => 'success').first
    ch = Stripe::Charge.retrieve(ref)
    data = {}
    if ch.refunded == true
        puts "REFUNDED ALREADY - #{ref}"
        next
    end

    if ch.status == 'succeeded'
        print "PREPARING TO REFUND #{ref}\t"
        p = Payment.create!(:invoice_id => pay.invoice_id, :trx => 'refund', :meth => pay.meth, :cc_data => {}, :rrn => ref)
        p.provider_data ||= {}
        res = ch.refund
        response = {
				:status => (["succeeded", "paid"].include?(res["status"]) ? "success" : "declined"),
				:rrn => res["id"],
				:ref => res["id"],
				:auth => "",
				:result => res["status"],
				:provider_data => { :last_stripe_response => res.inspect }
            }

        data = {
            :amount => number_to_currency(ch.amount/100.00, :unit => '$'),
            :cc_on_file => "#{ch.payment_method_details.card.brand.titlecase} (ends #{ch.payment_method_details.card.last4}) ",
            :ref => response['id'],
            :auth => '',
            :rrn => response['id']
        }


        if response[:status] == 'success'
            p.update_columns(:status => 'success', :rrn => response[:rrn] || p.rrn, :ref => response[:ref] || p.ref, :auth => response[:auth] || p.auth)
            p.provider_data = p.provider_data.merge(response[:provider_data]) if response[:provider_data].present?
            p.set_as_success! true, response[:result]
        end
        
        Stream::make("payment.refund", data, customer_id, 10082, data, timeframe = 0.seconds)
            
        puts res['status']
    else
        puts "FAILED #{ref} - #{ch.status}"
    end
end

r4.map do |ref, customer_id|
    s = Stream.where(:customer_id => customer_id, :company_id => 10082, :what => 'payment', :operation => 'refund').last
    res = Stripe::Charge.retrieve(ref)
    data = {
            :amount => number_to_currency(res.amount/100.00, :unit => '$'),
            :cc_on_file => "#{res.payment_method_details.card.brand.titlecase} (ends #{res.payment_method_details.card.last4}) ",
            :ref => ref,
            :auth => '',
            :rrn => ref
        }
    s.data = data
    s.save!
end

r5 = Order.where(:payment_id => Payment.where(:ref => Stream.where(:what => 'payment', :operation => 'charge', :company_id => 10082, :created_at => Date.parse("2019-05-25")..Date.parse("2019-05-27")).map{|s| next if s.data.nil?; s.data[:ref]}).pluck(:id));

r5_to_refund = []
r5.each do |order|
    next if order.payments.where(:trx => 'charge', :status => 'success').count == 1
    
    #####
    # We need to select the most recent payment as being good
    # All others are to be refunded
    #####
    oldest = (order.payments.where(:trx => 'charge', :status => 'success').first.created_at rescue nil)
    
    next if oldest.nil?

    order.payments.where(:trx => 'charge', :status => 'success').each do |payment|
        if oldest > payment.created_at
            next if Payment.where(:ref => payment.ref, :trx => 'refund', :status => 'success').count == 1
            r5_to_refund << payment.ref
        else
            oldest = payment.created_at
        end
    end
end;

r5_to_refund.each do |ref2|
    records = Payment.where(:ref => ref2).pluck(:ref, :customer_id);
    records.each do |ref, customer_id|
        ch = Stripe::Charge.retrieve(ref)
        data = {}
        if ch.refunded == true
            puts "REFUNDED ALREADY - #{ref}"
            next
        end
        if ch.status == 'succeeded'
            print "PREPARING TO REFUND #{ref}\t"
            res = ch.refund

            data = {
                    :amount => number_to_currency(ch.amount/100.00, :unit => '$'),
                    :cc_on_file => "#{ch.payment_method_details.card.brand.titlecase} (ends #{ch.payment_method_details.card.last4}) ",
                    :ref => res['id'],
                    :auth => '',
                    :rrn => res['id']
                }

            Stream::make("payment.refund", data, customer_id, 10082, data, timeframe = 0.seconds)
                
            puts res['status']
        else
            puts "FAILED #{ref} - #{ch.status}"
        end
    data
end