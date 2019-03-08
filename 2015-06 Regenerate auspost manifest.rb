# When a manifest submission failed, regenerate xml and resubmit it for the existing manifest.

manifests = ['M2000122','M2000121','M2000120','M2000119']

# WARNING:
# Manifest numbers can be reused across different company, double check which manifests
# are being pulled by the below
Manifest.where(:number => manifests, :created_at => 1.month.ago..Time.now).each do |m|

	puts "Manifest #{m.number} was marked as successfully sent to Auspost on #{m.updated_at} (#{m.company.business_name})"

	gateway = Processors::Shipment.get_gateway(m.company_id, "Auspost")

	if m.provider_data.blank?
		xml = gateway.build_manifest_xml m, gateway.instance_variable_get("@mlid"), gateway.instance_variable_get("@post_charge_to_account")
		m.provider_data = xml
		m.save!
	else
		xml = m.provider_data
	end
	if gateway.upload_manifest(xml, m.number)
		puts "Manifest #{m.number} was resent to Auspost successfully"
	else
		puts "There was an error resending manifest #{m.number}"
	end
end