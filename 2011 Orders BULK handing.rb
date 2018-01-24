
Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}

include RakeHelper
ws = init_google_worksheet
c = company_lookup

i=2
c.shipments.where(:status => ['needs_packing','needs_payment','needs_confirmation','needs_dispatching']).each do |s|
	
	ws[i,2] = s.to_dimensions.map { |h| h[:product_qty] }.sum

	ws[i,3] = s.order.number
	ws[i,4] = s.status
	ws[i,5] = s.payment_status
	ws[i,6] = s.ship_carrier_pref
	ws[i,7] = s.name
	ws[i,8] = s.order.total_value.to_f
	ws[i,9] = s.customer.name
	ws[i,10] = s.delivery_address

	ws[i,14] = s.delivery_suburb
	ws[i,15] = s.delivery_postcode
	ws[i,16] = s.delivery_state
	ws[i,17] = s.customer.name
	ws[i,18] = s.customer.phone || s.customer.phone2
	ws[i,21] = s.delivery_instructions

	i+=1
end;nil
ws.save

c.shipments.where(:status => ['needs_packing','needs_payment','needs_confirmation','needs_dispatching']).last.to_dimensions


i=1
orders = {:to_cancel => [], :to_pay => [], :to_pack => [], :to_done => []}
while (i < 576)
	i+=1
	case ws[i,1]
	when 'CANCEL'
		orders[:to_cancel] << ws[i,2]
		next
	when 'READY TO PAY'
		orders[:to_pay] << ws[i,2]
		next
	when 'READY TO PACK'
		orders[:to_pack] << ws[i,2]
		next
	when 'HAVE BEEN SHIPPED'
		orders[:to_done] << ws[i,2]
	end
end

orders.keys.each do |k|
	puts "#{k}: #{orders[k].count}"
end

orders[:to_cancel].each do |number|
	o = Order.where(:company_id => 10093, :number => number)
	if o.count == 1
		o = o.last
		o.update_columns(:status => 'cancelled')
		o.shipment.update_columns(:status => 'cancelled')
	else
		puts "there is #{o.count} orders for #{number}"
	end
end


orders[:to_pack].each do |number|
	o = Order.where(:company_id => 10093, :number => number)
	if o.count == 1
		o = o.last
		o.update_columns(:payment_status => 'paid', :payment_status_details => 'payment OK ^ST')
		o.shipment.update_columns(:status => 'needs_packing', :payment_status => 'paid', :payment_status_details => 'payment OK ^ST', :shipping_status => 'none')
	else
		puts "there is #{o.count} orders for #{number}"
	end
end


orders[:to_pay].each do |number|
	o = Order.where(:company_id => 10093, :number => number)
	if o.count == 1
		o = o.last
		o.update_columns(:payment_status => 'none')
		o.shipment.update_columns(:status => 'needs_payment', :payment_status => 'none')
	else
		puts "there is #{o.count} orders for #{number}"
	end
end


orders[:to_dispatch] = []
i=1
while (i < 576)
	i += 1
	next if ws3[i,11].blank?

	number = Order.where(:name => ws3[i,11], :payment_status => 'paid').pluck(:number).last
	orders[:to_dispatch] << number if !orders[:to_dispatch].include?(number)
end


orders[:to_dispatch].each do |number|
	o = Order.where(:company_id => 10093, :number => number)
	if o.count == 1
		o = o.last
		o.update_columns(:payment_status => 'none')
		o.shipment.update_columns(:status => 'needs_dispatching', :shipping_status => 'pending-dispatch')
	else
		puts "there is #{o.count} orders for #{number}"
	end
end

