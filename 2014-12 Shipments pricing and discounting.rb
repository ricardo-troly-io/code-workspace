# This was used to revert all discounts and re-apply each with an additional discount
#
#

# Orders affected
order_ids = [12865, 12879, 12943, 12945, 12944, 12946, 12949, 12950, 12947, 12948, 12952, 12954, 12955, 12956, 12953, 12957, 12958, 12959, 12960, 12961, 12962, 12963, 12967, 12966, 12968, 12969, 12971, 12965, 12972, 12973, 12975, 12974, 12977, 12976, 12978, 12979, 12980, 12981, 12984, 12985, 12982, 12983, 12986, 12987, 12988, 12989, 12991, 12992, 12993, 12994, 12995, 12997, 12998, 12999, 12996, 13002, 13001, 13000, 13004, 13005, 13006, 13007, 13008, 13009, 13010, 13011, 13012, 13013, 13014, 13015, 13016, 13017, 13018, 13019, 13020, 13026, 13022, 13021, 13028, 13023, 13027, 13029, 13030, 13035, 13033, 13032, 13031, 13049, 13055, 13056, 13057, 13058, 13052, 13053, 13054, 13059, 13060, 13063, 13062, 13061, 13068, 13069, 13071, 13066, 13072, 13065, 13070, 13067, 13076, 13082]

# first remove the discount if there is one
Order.where(:id => order_ids).each do |o|
  has_discount = o.orderlines.where(:product_id => MEMBERSHIP_ROUND_PRODUCT_ID).exists?
  if has_discount
    discount = o.orderlines.where(:product_id => MEMBERSHIP_ROUND_PRODUCT_ID).last.price
    puts "Order #{o.id} has discount (#{discount})"
    o.orderlines.where(:product_id => MEMBERSHIP_ROUND_PRODUCT_ID).delete_all
  else
    puts "*** #{o.id} DOES NOT"
  end

end; nil


# Then re calculate the order total. note we are changing but not saving the order status, purely to be able to access the calculate method
Order.where(:id => order_ids).each do |o|
  old_status = o.status
  old_total = o.total_value
  o.status = 'confirmed'
  o.calculate
  o.update_column(:total_value, o.total_value)
  puts "Order #{o.id} changed from #{old_total} to #{o.total_value}"
end; nil

# Recalculate the discount for this order and reapply it.
Order.where(:id => order_ids).each do |o|
  discount = (o.total_value - (o.total_value / 0.8 * 0.75))
  inv = o.invoice
  
  o.status = 'confirmed'

  aol = Orderline.create!(:order_id => 1, :product_id => MEMBERSHIP_ROUND_PRODUCT_ID)
  aol.price = (discount * -1)
  aol.save!
  aol.update_column(:order_id, o.id)

  o.calculate
  o.update_column(:total_value, o.total_value)

  if inv.present?
    inv.total = o.total_value
    inv.tax1 = o.total_tax1
    inv.tax2 = o.total_tax2
    inv.save
  end
end;nil

# Update the shipment value
Order.where(:id => order_ids).each do |o|
  s = o.shipment
  if s.shipping_price.present?
    s.value = s.order.total_value + s.shipping_price
  else
    s.value = s.order.total_value
  end
  s.save!
end;nil


#
# Use separately to update the carrier back onto the customer
# 
Order.where(:id => order_ids).each do |o|
  cc = CompanyCustomer.where(:customer_id => o.customer_id, :company_id => o.company_id).last
  puts o.customer
  puts "    Applying shipping carrier (#{o.shipment.ship_carrier_pref}) to customer record (formerly '#{cc.ship_carrier_pref}')"
  cc.update_column(:ship_carrier_pref, o.shipment.ship_carrier_pref)
end


# Re-adjust all orderlines to ensure the price applied is the correct (20%) not full discount (25%)
Orderline.where(:order_id => order_ids).each do |ol|
  if ol.price > 0
  ratio = ol.price / ol.price_retail
  if (ratio < 0.8)
    puts "#{ol.id} --- #{ol.qty} * #{ol.price} => #{ol.subtotal} (#{ratio})"
  end
end
end;nil

29168 --- 1.0 * 33.75 => 33.75 (0.75)
29196 --- 1.0 * 33.75 => 33.75 (0.75)
29224 --- 1.0 * 33.75 => 33.75 (0.75)
29238 --- 1.0 * 33.75 => 33.75 (0.75)
29252 --- 1.0 * 33.75 => 33.75 (0.75)
29294 --- 1.0 * 33.75 => 33.75 (0.75)
29406 --- 1.0 * 33.75 => 33.75 (0.75)
29504 --- 1.0 * 33.75 => 33.75 (0.75)

[29168,29196,29224,29238,29252,29294,29406,29504]

29405 --- 1.0 * 22.5 => 22.5 (0.75)
29237 --- 1.0 * 22.5 => 22.5 (0.75)

Shipment.where(:order_id => order_ids ).where.not(:shipping_price => [nil,0]).each do |s|

end

# Check shipping costs (for Gerald, outsite of NSW and ACT which are free shipping)
Order.where(:id => order_ids).each do |o|
  if o.customer.delivery_suburb.to_s.match(/NSW/) || o.customer.delivery_suburb.to_s.match(/ACT/)
  else
  puts "#{o.id} - #{o.customer} - #{o.customer.delivery_suburb} - #{o.shipment.shipping_price}"
  if o.invoice.present?
    puts "    #{o.invoice.total}"
  end
  puts "    #{o.invoice.total}"
end
end;nil





  #old_total = o.total_value
  #o.status = 'confirmed'
  #o.calculate

  #puts "#{o.id} from #{old_total} to #{o.total_value}"
  #o.shipment.update_column(:value,  o.total_value)
  #o.update_column(:total_value, o.total_value)
end;nil
