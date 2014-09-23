#
# Resets the shipping carrier preference for each shipment to the customer or the companies..
Shipment.where(:company_id => 10027).each do |s|
  if s.ship_carrier_pref.blank?
    cc = CompanyCustomer.where(:company_id => s.company_id, :customer_id => s.customer_id).last
    puts cc.ship_carrier_pref.present? ? cc.ship_carrier_pref : s.company.ship_carrier_pref
    s.update_attribute(:ship_carrier_pref, cc.ship_carrier_pref.present? ? cc.ship_carrier_pref : s.company.ship_carrier_pref)
  else
    puts s.
  end
end; nil



#
# Prints orders, shipping prefernces and products for non-standards (qty != 6) orders
CompanyCustomer.where(:company_id => 10027).where.not(:upcoming_shipment_instructions => nil).each do |cc|
  o=Order.where(:customer_id => cc.customer_id).last
  c = Customer.find(cc.customer_id)
  if o
    ol = o.orderlines.where(:display_only => false).where.not(:product_id => MEMBERSHIP_ROUND_PRODUCT_ID)
    total = ol.sum(:qty)
    print "Order #{o.name} - #{cc.ship_carrier_pref}"
    if total == 6
      puts ": ok"
    else
      puts ":"
      ol.each do |li|
        puts "   #{li.qty}x #{li.name}"
      end
    end
  else
    puts "#{c} doesn't have any order?"
  end
end;nil


