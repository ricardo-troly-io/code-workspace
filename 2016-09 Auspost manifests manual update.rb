manifests = Manifest.where(:provider => 'Auspost').where.not(provider_data: nil); nil

no_charge_codes = []
manifests.each do |m|
	empty_cc = /ChargeCode\//.match(m.provider_data)
	if empty_cc.present? 
		no_charge_codes << m 
	else
		puts "."
	end
end; nil


no_charge_codes.count


puts "The following Manifest (Xml) submitted may have had one or many missing 'ChargeCode' values:"
new_xml = []
no_charge_codes.each do |m|

	next if m.trx_date.to_s[0..3] != "2016"
	
	integration = m.company.integrations.where(:provider => 'Auspost',:status => 'ready').first

	if integration.nil?
		puts "crap"
	else

		charge_to = integration.params["charge_to"]
		rate_card = "Integrations::Auspost::Rates::A#{integration.params["charge_to"]}".constantize
		charge_code = rate_card.SERVICES.first.last.first.last[1]
		filename =  "#{integration.params["mlid"]}_#{m.number}_#{integration.params["ftp_username"]}.xml"			
		str = "Manifest number #{m.number} on #{m.trx_date} (#{m.company.business_name}, acct:#{charge_to}), \n  -> ChargeCode: #{charge_code}, Attachment: #{filename}\n\n"
		
		puts str
		
		# replace ChargeCode/ with ChargeCode>##</ChargeCode
		# puts "\n\n\n\n\n\n#{str}\n\n"
		
		# new_xml << xml.gsub(/ChargeCode\//,"ChargeCode>#{charge_code}</ChargeCode")

		# #puts new_xml.last

		# 				File.open(Rails.root.join('tmp', filename), 'w') do |f|
		# 			f.puts xml
		# 		end

		# 		# sftp file to server for processing
		# 		Net::SFTP.start('', '', :password => '') do |sftp|
		# 			sftp.upload!(Rails.root.join('tmp', filename).to_s)
		# 		end


	end


end;nil