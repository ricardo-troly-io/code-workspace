

c.shipments.where(:status => ['needs_dispatching','needs_payment','needs_confirmation']).where.not(:delivery_instructions => ['',nil]).each do |s|
	if stdin_for_regex(/[yn]/, "Confirm signature removal given instructions: '#{s.delivery_instructions}'? [yn]") == "y"
  		if (s.provider_data == '' || s.provider_data == nil)
  			RakeHelper::rputs("No Shipping Label data available for #{s.name}")
  		else
  			RakeHelper::gputs("Updated #{s.name} to require no signature.")
  			s.provider_data[:options][:signature] = false;
  			s.save!
  		end
  	end
end

