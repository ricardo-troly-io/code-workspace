t = Time.nowargs = {:metric => 'month', :range => 1..18}
from = eval("(#{args[:range]}).end.#{args[:metric].pluralize}.ago")

cids = Company.where(:is_fake => false).pluck(:id)
ids = Invoice.where(:customer_id => nil,:company_id => cids,:payment_status => 'completed').pluck(:id)

data = { 
  :companies => [], :ccs => [], :lastest_billing => [], :dates => [], 
  :customers => [], :products => [], :units_sold => [], :emails => [], 
  :payments => [], :payments_value => [], :signups => [], :orders => [], :shipments => [],
  :rev_total => [], :rev_subs => [], :rev_setup => [], :rev_trx => [], :rev_sales => [], :rev_valueadd => [] 
}

while from < Time.now do
    range = eval("from.beginning_of_#{args[:metric]}..from.end_of_#{args[:metric]}")

    inv = Invoice.where(:id => ids,:issued_at => range)
    data[:rev_total] << inv.sum(:total).to_f

    tmp = { :rev_subs => 0, :rev_setup => 0, :rev_trx => 0, :rev_sales => 0, :rev_valueadd => 0 }

    inv.each do |i|
        puts "\n#{i.company.business_name} v#{i.company.billing_scheme} (#{i.total.to_f} - #{i.number})"
        i.orders.last.orderlines.each do |ol|
            if ol.name.match(/Subscription fees/)
                print "S "
                tmp[:rev_subs] += ol.subtotal

            elsif ol.name.match(/Implementation fee|One-off setup/)
                print "I "
                tmp[:rev_setup] += ol.subtotal

            elsif ol.name.match(/payments processed/)
                print "T "
                tmp[:rev_trx] += ol.subtotal

            elsif ol.name.match(/Bandwidth, hosting, backups, support and maintenance fees/)
                print "✓ "
                tmp[:rev_valueadd] += ol.subtotal

            elsif ol.name.match(/Setup and training fees|Subscribility|Ongoing fees|Funds withheld|SMS|Australia Post|Mailchimp|WordPress|eWay|Fastway Prepaid|Online Payments|Data Export|Tasting Experience|payment provider transaction fees/)
                print "x "
            else 
                print "  "
            end
            puts "#{ol.name} → #{ol.subtotal.to_f}"
        end
    end

    tmp.keys.each do |k|
        data[k] << tmp[k]
    end


    puts tmp.inspect

    from = eval("from.end_of_#{args[:metric]}") + 1
end;nil