['65550-1009116','65556-1009116','65557-1009116','65558-1009116','65559-1009116','65561-1009116','65571-1009116','65572-1009116'].each do |order_id|

	puts ""
	
	o = Order.where(:number => order_id).last
	c = o.customer
	s = o.shipment

	RakeHelper::yputs "Order #{order_id} located for #{c.name}. Restoring address and cc details"

	c.delivery_address = s.delivery_address
	c.delivery_suburb  = s.delivery_suburb
	c.delivery_state   = s.delivery_state
	c.delivery_postcode = s.delivery_postcode
	c.delivery_country  = s.delivery_country
	c.delivery_instructions  = s.delivery_instructions

	cc_version = c.versions.where("object_changes LIKE '%cc_number%####%'").first(2).last
	if cc_version.nil?
		RakeHelper::rputs "Oups, cannot find cc details in record versions (#{c.name})"
		next
	end

	RakeHelper::pputs "Exp Year: " + /cc_exp_year:\n.*(\d{2,4}).*\n/.match(cc_version.object_changes)[1]
	#RakeHelper::pputs "Exp Year: " + /cc_exp_year:[^\d]*(\d{2,4})[^\n]/.match(cc_version.object_changes)[1]
	c.cc_exp_year = /cc_exp_year:\n.*(\d{2,4}).*\n/.match(cc_version.object_changes)[1]

	RakeHelper::pputs "Exp Month: " + /cc_exp_month:\n.*(\d{2}).*\n/.match(cc_version.object_changes)[1]
	c.cc_exp_month = /cc_exp_month:\n.*(\d{2}).*\n/.match(cc_version.object_changes)[1]

	if /cc_cvv:\n.*(\d{3}).*\n/.match(cc_version.object_changes).present?
		RakeHelper::pputs "CC CCV: " + /cc_cvv:\n.*(\d{3}).*\n/.match(cc_version.object_changes)[1]
		c.cc_cvv = /cc_cvv:\n.*(\d{3}).*\n/.match(cc_version.object_changes)[1]
	end

	RakeHelper::pputs "CC Number: " + c.decrypt_cc
	c.cc_number = c.decrypt_cc

	if 'y' == RakeHelper::stdin_for_regex(/y|n/,"Looking good to save? (y|n)")
		RakeHelper::gputs "#{c.name} has been corrected"
		c.save
	else
		RakeHelper::rputs "#{c.name} has been SKIPPED"
	end
end