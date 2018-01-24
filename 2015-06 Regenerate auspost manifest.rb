# When a manifest submission failed, regenerate xml and resubmit it for the existing manifest.
m = Manifest.find(10461)
gateway = Processors::Shipment.get_gateway(10044, "Auspost")
xml = gateway.build_manifest_xml m, gateway.instance_variable_get("@mlid"), gateway.instance_variable_get("@post_charge_to_account")
success = gateway.upload_manifest(xml, m.number)
m.provider_data = xml
m.save!