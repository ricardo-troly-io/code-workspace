Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper


def xero_save_buffer buffer, options={}
	options.reverse_merge!(
		:chunk => 3,
		:force => false
	)

	buffer.each do |obj,records|
		if (records.count >= options[:chunk] || (records.count > 0 && options[:force]))
			to_save = options[:force] ? records : records.last(options[:chunk])
			puts "#{to_save.count} #{obj.model_name} of #{records.count}"
			if obj.save_records(to_save.flatten) == false
				RakeHelper::rputs "Error saving #{to_save.count} #{obj.model_name}s into Xero (with force:#{options[:force].to_s})"
				#to_save.reverse.each do |ts|
				#	puts ts.inspect
					#obj.save_records([ts].flatten)
				#end
			else
				RakeHelper::gputs "Saved #{to_save.count} #{obj.model_name}s into Xero (with force:#{options[:force].to_s})"
				buffer[obj] -= to_save
			end
			puts "#{buffer[obj].count} #{obj.model_name}s remain"
		end
	end
	return buffer
end

$learning_accounts = {
	"Subscribility"=>"201",
	"Stripe"=>"211",
	"UPS"=>"211",
	"Tasting Experience and Show"=>"201",
	"Mailchimp"=>"201",
	"Activity Summary"=>"201",
	"FedEx"=>"201",
	"WordPress Ecommerce"=>"201",
	"Australia Post"=>"201",
	"Online Payments"=>"211",
	"Text Messaging"=>"201",
	"Data Export"=>"201",
	"Fastway Prepaid"=>"201",
	"CommWeb"=>"201",
	"eWAY"=>"201",
	"translation missing: en-AU.integration.provider.FedEx"=>"201",
	"translation missing: en-AU.integration.provider.Stripe"=>"201",
	"WordPress"=>"201",
	"Gmail"=>"201",
	"Couriers Please Prepaid"=>"201"
}

def define_xero_acc name, qty, subtotal, ol=nil
	acct=nil
	case name
		when *$learning_accounts.keys
			acct = $learning_accounts[name]
		when /^Subscribility$/, /^Platform access fee$/
			acct=201
		when /\d* payments processed$/, /\d* shipments dispatched$/, /\d* data syncs$/, /\d* orders completed$/, /\d* Payment processed$/, /^Usage fee/
			acct=202
		when /\d* payment provider transaction fees$/
			acct=211
		when /\d* shipping provider transaction fees$/
			acct=212
		when /\d* SMS sent$/, /^SMS$/, /^\d* SMS provider transaction fees$/
			acct=213
		when /.*Support.*/, /.*Implementation.*/, /.* integration configuration$/, /^Setup.*/
			acct=203
		when /Monies owed to Subscribility/, /Monies owed to Troly/
			acct=260
		when /^Funds withheld$/, /^Payments made to providers$/
			acct=620
		when /Subscribility account credit/, /Troly account credit/
			acct=415
	end

	if acct.nil?
		puts ol.inspect
		acct = RakeHelper::pick_from_array({
			201=>'SAAS - Membership Income',
			202=>'SAAS - Usage Fee Income',
			211=>'BANKING - Surcharge Income',
			212=>'SHIPPING - Surcharge Income',
			213=>'SMS - Surcharge Income',
			221=>'WEB - Web Hosting Income',
			222=>'WEB - Web Development Income',
			203=>'SAAS - Implementation & Support Services',
			998=>'XX - Skip Line',
			999=>'XX - Skip Invoice',
			},"What should be the account number for '#{name}' (at $#{subtotal})?")
		$learning_accounts[name] = acct
	end

	return acct
end






## Pushes all winery invoices to Xero from a specific date and/or specific numbers
##
##
def push_invoices(options={})

	options.reverse_merge!(
		:from => nil, 					## Startng date range, defaults to 1970
		:to => nil, 					## End date range, defaults to NOW
		:include_numbers => [],	## Specific invoice numbers, as array or comma-separated list
		:skip_numbers => [],		## Invoice numbers to skip, as array or comma-separated list
	);

	options[:include_numbers] = options[:include_numbers].split(',').map { |x| x.strip } if options[:include_numbers].present? && options[:include_numbers].is_a?(String);
	options[:skip_numbers] = options[:skip_numbers].split(',').map { |x| x.strip } if options[:skip_numbers].present? && options[:skip_numbers].is_a?(String);
	
	processed_numbers = []

	xero = Xeroizer::PrivateApplication.new(Rails.application.config.subs_xero_key, Rails.application.config.subs_xero_secret, Rails.root.join('lib/integrations/xero/certs/privatekey.pem'))

	save_buffer = { xero.Invoice => [], xero.Payment => [] };

	cids = Company.where(:is_fake => false).pluck(:id);
	invoices = Invoice.where(:customer_id => nil,:company_id => cids, :payment_status => 'completed');

	invoices = invoices.where('issued_at >= :date OR updated_at >= :date',:date => options[:from]) if options[:from].present?;
	invoices = invoices.where('issued_at <= :date OR updated_at <= :date',:date => options[:to]) if options[:to].present?;
	invoices = invoices.where(:number => options[:include_numbers]) if options[:include_numbers].present?;
	invoices = invoices.where.not(:number => options[:skip_numbers]) if options[:skip_numbers].present?;
	
	invoices = invoices.order(:issued_at);

	RakeHelper::dputs "Pushing invoices to Xero (#{options[:from] || 'begining of time'} to #{options[:to] || 'now'}, #{options[:include_numbers].present? ? options[:include_numbers].join(', ') : 'all numbers'})"

	invoices.each do |i|

		processed_numbers << i.number
		
		RakeHelper::pputs "Processing #{i.number}"
		
		x_i = xero.Invoice.all(:where => {:type => "ACCREC", :invoice_number => i.number}).last || xero.Invoice.build(:type => "ACCREC", :invoice_number => i.number)

		if x_i.status == 'PAID'
			RakeHelper::yputs("PAID IN FULL: Cannot process invoice #{i.number} for #{i.company.legal_name}. Skipping.", '→')
			next;
		end

		if i.company.provider_data[:external_ids][:xero].present?
			x_i.contact = xero.Contact.build(:id => i.company.provider_data[:external_ids][:xero])
		else
			x_i.contact = xero.Contact.all(:where => {:contact_number => i.company_id}).first
		end

		x_i.date = i.issued_at
		x_i.due_date = (i.issued_at + 2.days)
		x_i.status = 'DRAFT'

		x_i.line_items.count
		x_i.line_items = Array.new

		#invoice.line_amount_types = ['NSW','VIC','TAS'].include? i.company.state ? 'Exclusive' : 'NoTax'
		x_i.line_amount_types = 'NoTax'

		catch :skip_invoice do
			
				i.orders.first.orderlines.where(:display_only => false).each do |ol|

					acct = define_xero_acc(ol.name,ol.qty,ol.subtotal,ol)

					next 						if acct == 998
					throw :skip_invoice 		if acct == 999
					
					if acct == 620

						identifier = "OID:#{ol.order_id}, OLID:#{ol.id}"

						if x_i.id.nil? && (x_i.save == false || (x_i = xero.Invoice.all(:where => {:type => "ACCREC", :invoice_number => i.number}).last).blank?)

							RakeHelper::yputs("Invoice #{i.number} a prepayment registered and is currently being created in Xero. Run this again to ensure prepayment is recorded.","!")
							
							processed_numbers.delete(i.number)

						elsif x_i.payments.select{ |payment| payment.reference == identifier }.present?

							RakeHelper::pputs "Prepayment of $#{ol.price.abs} on invoice #{i.number} already recorded. Skipping."

						else	

							x_i.status = 'AUTHORISED'

							RakeHelper::pputs "Recording prepayment of $#{ol.price.abs} as '#{ol.name}' against invoice #{i.number} (#{acct})"
							payment=xero.Payment.build(:amount => ol.price.abs, :date => x_i.date, :status =>'AUTHORISED', :invoice => {:id => x_i.id}, :reference => identifier, :account => {:code => acct})
							save_buffer[xero.Payment] << payment

						end

						x_i.add_line_item({
							:quantity => 1,
							:unit_amount => 0,
							:description => "#{ol.name} (#{ol.price.abs})",
							:account_code => acct
						})

					else
						
						x_i.add_line_item({
							:quantity => ol.qty,
							:unit_amount => ol.price.to_f,
							:description => ol.name,
							:account_code => acct
						})

					end
				end

			# register successful Credit Card payments made against that invoice
			i.payments.where(:status => 'success', :trx =>'charge').each do |p|

				identifier = "PID:#{p.id}, RRN:#{p.rrn}"

				if x_i.id.nil? && (x_i.save == false || (x_i = xero.Invoice.all(:where => {:type => "ACCREC", :invoice_number => i.number}).last).blank?)
					
					RakeHelper::yputs("Invoice #{i.number} has payment registered and is currently being created in Xero. Run this again to ensure payment is recorded.","!")

					processed_numbers.delete(i.number)


				elsif x_i.payments.select{ |payment| payment.reference == identifier }.present?

					#RakeHelper::pputs "Payment of $#{ol.subtotal.to_f} on invoice #{i.number} already recorded. Skipping."

				else

					x_i.status = 'AUTHORISED'

					RakeHelper::pputs "Registering payment of $#{p.amount} as '#{identifier}' to against invoice #{i.number} (803c)"
					payment=xero.Payment.build(:amount => p.amount, :date => p.updated_at, :status =>'AUTHORISED', :invoice => {:id => x_i.id}, :reference => identifier, :account => {:code => '803c'})
					save_buffer[xero.Payment] << payment
				end
			end

			save_buffer[xero.Invoice] << x_i
			save_buffer = xero_save_buffer save_buffer, {force:invoices.last.id == i.id } 

		end
		sleep(5);

	end

	return processed_numbers;
end

def push_companies_to_xero from=nil
	
	xero = Xeroizer::PrivateApplication.new(Rails.application.config.subs_xero_key, Rails.application.config.subs_xero_secret, Rails.root.join('lib/integrations/xero/certs/privatekey.pem'))

	save_buffer = { xero.Contact => [] }

	companies = Company.where(:is_fake => false)
	companies = companies.where('created_at > :date OR updated_at > :date',:date => from) if from.present?

	RakeHelper::dputs "Pushing companies to Xero" + (from.present? ? " (from: #{from})" : '')

	companies.each do |c|

		contact = xero.Contact.all(:where => {:contact_number => c.id}).first

		if contact.nil?
			contact = xero.Contact.build(:name => c.legal_name, :contact_number => c.id)
			RakeHelper::gputs "Creating #{c}"
		else
			c.provider_data ||= {}
			c.provider_data[:external_ids] ||= {}
			c.provider_data[:external_ids][:xero] ||= contact.id
			c.save!
			RakeHelper::pputs "Updating #{c}"
		end

		contact.name = c.legal_name
		contact.name += " - LOCKED" if c.is_locked
		contact.name += " (#{c.id})"
		contact.add_phone(:type => "DEFAULT", :number => c.phone)

		if c.admin_users.where(:company_users => {:is_billing => true}).blank? && 
			(first_admin = c.admin_users.where.not("email LIKE '%empireone%' or email LIKE '%subscribility%'").first).present?
			CompanyUser.where(:user_id => first_admin.id, :company_id => c.id).update_all(:is_billing => true)
			RakeHelper::yputs "Added #{first_admin.email} as billing contact.",'!'
		end

		if (billing_contact = c.admin_users.where(:company_users => {:is_billing => true}).first).present?
		
			contact.email_address = billing_contact.email
			contact.first_name = billing_contact.fname
			contact.last_name = billing_contact.lname
			contact.add_address({
				:type => 'STREET',
				:line1 => c.address,
				:line2 => c.suburb,
				:postal_code => c.postcode,
				:region => c.state
			})
		else
			RakeHelper::rputs "No billing contact found for #{c.business_name}"
		end
		
		save_buffer[xero.Contact] << contact

		save_buffer = xero_save_buffer save_buffer, {force:companies.last.id == c.id } 

		sleep(2)
	end;

end

cids = Company.where(:is_fake => false).pluck(:id);

ok = []
exceptions = []
Invoice.where(:company_id => cids, :customer_id => nil, :created_at => Time.new(2017, 10, 1)..Time.new(2017, 12, 31)).where.not(:created_at => nil, :number => ok+exceptions).each do |i|
	sleep(7);
	begin
		ok += push_invoices :include_numbers => i.number
	rescue
		exceptions << i.number
	end
end;

#exceptions = ["70101-5700-001","70101-6800-002","70101-14700-001","70201-35200-001","70201-35300-001","70201-35500-001","70201-6800-001","70224-22100-001","70224-35100-001","70301-36200-001","70301-36900-001","70301-37900-001","70301-35200-001","70301-35500-001","70301-35100-001"]