Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper



cid = 10091
order_number = '55608-1009116'
provider = 'Auspost'


shipments = Shipment.where(:order_id => Order.for_company(cid).where(:number => order_number).pluck(:id))

gateway = Processors::Shipment.get_gateway(10091,provider)

manifests = Manifest.where(:company_id => cid, :provider => provider, :id => shipments.pluck(:manifest_id))

puts gateway.inspect


###
### BECAUSE OF THE STDIN INTERACTION, THE FOLLOWING LInES NEED TO BE EXECUTED MANUALLY ONE AT A TIME
###
mlid = stdin_for_regex(/[A-Z0-9]{3}/,"What is the MLID (check the config, @mlid, not the gateway :mlid)")
charge_to = stdin_for_regex(/[0-9]{6,7}/,"What is the Charge Account (check the config, @post_charge_to_account, not the gateway :charge_to)")

manifests.each do |m|
 puts "\n\n\nXML for Manifest #{m.number}:".yellow
 puts gateway.build_manifest_xml(m,mlid,charge_to)
 puts "\n\n\n"
end