Membership.where(:company_id => 10068, :membership_type_id => [10082,10084,10085],:status => 'current')

order_ids = Shipment.where(:company_id => 10068).where("status LIKE 'needs%'").pluck(:order_id)
- 320

Order.where(:id => order_ids).joins(:membership).group(:membership_type_id).count


MembershipType.where(:company_id => 10068).pluck(:delivery_date_1, :delivery_date_2)
[[10084, "Double"], [10159, "Single - Collect"], [10160, "Double - Collect"], [10161, "Triple - Collect"], [10082, "Single"], [10085, "Triple"]]

#
# Updates the current membership scheduled delivery dates.
#
MembershipType.where(:id => [10082,10085,10084,10159,10160,10161]).each do |mt|
  print '#'
  mt.delivery_date_1 = '2015-01-01'
  mt.delivery_date_2 = '2015-03-01'
  mt.delivery_date_3 = '2015-05-01'
  mt.delivery_date_4 = '2015-07-01'
  mt.delivery_date_5 = '2015-09-01'
  mt.delivery_date_6 = '2015-11-01'
  mt.save!

  mt.memberships.current.each do |m|
    print '.'
    m.update_columns(
      :delivery_date_1 => mt.delivery_date_1,
      :delivery_date_2 => mt.delivery_date_2,
      :delivery_date_3 => mt.delivery_date_3,
      :delivery_date_4 => mt.delivery_date_4,
      :delivery_date_5 => mt.delivery_date_5,
      :delivery_date_6 => mt.delivery_date_6);
    m.reload
    m.update_next_delivery_date()
    m.save
  end
end;nil 

Order.where(:id => order_ids).group(:membership_shipment_number).count

Membership.current.for_company(10068).where(:id => [11701, 11838, 11952, 11958, 12118, 11762]).each do |m|
  m.update_next_delivery_date()
  m.save!
end



Membership.current.for_company(10068).where(:membership_type_id => [10082,10084,10085]).has_upcoming_deliveries(Time.now).group(:membership_type_id).count

Membership.current.for_company(10068).where(:membership_type_id => [10082,10084,10085], :next_delivery_date => '2015-03-01').count

Membership.current.for_company(10068).where(:membership_type_id => [10082,10084,10085]).pluck(:next_delivery_date).uniq


Membership.current.for_company(10068).where(:membership_type_id => [10082,10084,10085]).count


s_o_ids = Shipment.for_company(10068).where("status LIKE 'needs%'").pluck(:order_id)
s_o_ids.count
m_ids = Order.where(:id => s_o_ids).pluck(:membership_id)
m_ids.count
missing_ids = Membership.current.for_company(10068).pluck(:id) - m_ids

Membership.where(:id => missing_ids).where.not(:hold_until => nil).count
-- 5

Membership.where(:id => missing_ids - hold_ids).pluck(:next_delivery_date)

Membership.where(:id => missing_ids - hold_ids).each do |m|
  puts m.customer
  puts m.orders.count
  puts m.orders.pluck(:status)
  puts "\n"
end;nil




emails = ['felicity_lines@bigpond.com','hstjernq@bigpond.net.au','dhawkins10@gmail.com','ghawkins17@gmail.com','mrpark8@bigpond.net.au','tiges_rule@hotmail.com','conniegalea25@hotmail.com','adamlindaross@bigpond.com','kristen@hmcr.com.au','gdsgrant@optusnet.com.au','raeneil@bigpond.com','simon190677@yahoo.com.au','stephaniel@plpaust.com','steve5572@gmail.com','rafal@medallionhomes.com.au','davidparrycraig@gmail.com','reg.fries@gmail.com','witold.kramarczuk@aussie.com.au','tvshipman@gmail.com','johnralph@hotmail.com','trent@schroeter.net.au','sarah.vidgeon@gmail.com','stevemc1111@hotmail.com','sharon@weslec.com.au','tony.proud@stratco.com.au','spurls6@bigpond.com','ian.hunt@flinders.edu.au','ali128hair@outlook.com','rosswryan@yahoo.com.au','michael.valenzuela@sydney.edu.au','irene@jonathanphillips.com.au','kristyv@iinet.net.au','mjrim45@gmail.com','clintmaxfield@gmail.com','greg.mitchell@bdo.com.au','bjburford@bigpond.com','benjamin.rice1980@icloud.com','kwsmiler@bigpond.net.au','coombe9@bigpond.com','elemental01@bigpond.com','design@iammelissa.com.au','pennygoesasailing@gmail.com','michelle.c.hosemann@outlook.com','paul@cogmarketing.com.au','sean@thejudges.com.au','nolahender@optusnet.com.au','nolavillis@gmail.com','statesound@hotmail.com']

c_ids = Customer.where(:email => emails).pluck(:id)

Order.for_company(10068).for_customer(c_ids).where.not(:status => 'cancelled').each do |o|
next if o.customer_id == 14342
puts "#{o.customer} - #{o.total_value}"
ol = o.Orderlines.where(:name => 'Prepaid').last
ol.name = 'Prepaid membership pack'
ol.price = -o.total_value
ol.tax1 = 0
ol.tax2 = 0
ol.save!
end;nil

Order.for_company(10068).for_customer(c_ids).where.not(:status => 'cancelled').each do |o|
  shipping_price = (o.shipment.present? and o.shipment.shipping_price) || 0
  o.total_value = o.orderlines.sum(:price) + shipping_price
  o.total_tax1 = o.orderlines.sum(:tax1)
  o.total_tax2 = o.orderlines.sum(:tax2)
  o.save!
end;nil

Orderline.where(:name => 'Prepaid').each do |ol|
puts "#{ol.order} - from #{ol.price} to #{ol.order.total_value}"
  ol.update_columns(
    :subtotal
    :price => -ol.order.total_value,
    :qty => 1,
    :tax1 => -ol.order.total_tax1,
    :tax2 => 0#-ol.order.total_tax2
  );
end;nil

Shipment.for_company(10068).where(:delivery_suburb => [nil,'']).each do |s|
  if [10159,10160,10161].include?(s.order.membership.membership_type_id)
    s.delivery_address = "Pickup at #{s.company.business_name}"
    s.delivery_suburb_id = s.company.suburb_id
    s.save!
  else
    puts s.order.to_s + " is not meant to be picked up.."
  end
end

#if o.orderlines.where(:name => 'Prepaid').blank?
  #  Orderline.create!(:name => 'Prepaid', :order => o )
  #o.save
#end

end;nil

Order.where(:id => order_ids).each do |o|
  if o.invoice.blank?
    puts "#{o} - no invoice?"
  elsif o.invoice.payments.blank?
    puts "#{o} - no payments?"
  else
    puts o
    o.invoice.payments.last.post_processing
  end
end;nil





processed_customers = [13096, 13097, 12937, 13128, 13191, 13220, 13231, 13261, 13031, 13080, 12811, 12842, 13084, 13204, 12795, 12986, 12992, 12796, 13194, 12998, 12801, 13160, 13157, 13034, 13246, 12794, 12924, 13124, 13132, 13140, 13169, 12791, 13167, 13188, 13248, 13092, 12958, 12962, 13153, 13190, 12768, 13180, 12775, 12787, 13222, 12833, 12841, 12832, 12862, 12860, 12863, 12884, 12880, 12895, 12901, 12914, 12926, 12932, 12944, 12943]

Order.for_company(10068).where(:payment_status => ['declined','error']).each do |o|

  if processed_customers.include?(o.customer_id)
    puts "WARNING - #{o} was already attempted? #{o.customer}"
  else
    payment = o.to_payment('auth')
    puts "Authorisation for order #{o} has been created?"
    #STDIN.gets
    if payment.status == 'pending'
      Processors::Payment.process [payment]
    else
      puts "Oups - payment error - #{payment.result}"
    end
    payment.reload
    puts "Done, result is #{payment.status} - was an email sent?"
    processed_customers << o.customer_id
    STDIN.gets
  end

  puts processed_customers.inspect

end


orders = []
Payment.where(:company_id => 10068,:status => 'success',:trx => 'offline').each do |p|
  if p.invoice.orders.count != 1
    puts "something is wrong with " + p.inspect
  else
    orders << p.invoice.orders.last.id
  end
end;nil


























