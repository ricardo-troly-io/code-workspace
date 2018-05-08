Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper

@api_endpoint = "https://troly.api-us1.com"
@api_token = "f8b7ef441352e9883df8a3bc93f2b86575bb35bf8f52237f0ee34e8f4a12e5f2abaa3efb"
@base_url = @api_endpoint + "/admin/api.php?api_output=json&api_key=" + @api_token + "&"
@headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
@for_real = true

def track_event event, data, email

    body = {
        "api_output" => "json",
        "api_key" => @api_token,
        "actid" => "609711776", 
        "key"=>"d4a4f2f69d14076de7a070d889bd76d3e5986485",
        "event" => event,
        "eventdata" => data,
        "track_email" => email
    }
    return HTTParty.post("https://trackcmp.net/event", {:body => body })
end

def ac_post(action, params)
    #params['api_action'] = action;
    body = params.map{ |k,v| "&" + k + "=" + URI.encode(v.to_s).gsub(/@/,"%40").gsub(/\+/,"%2B"); }.join('');
    return HTTParty.post(@base_url + "&api_action=" + action, {:body => body, :headers => @headers})
end
def ac_get(action, params)
    params['api_action'] = action;
    query = params.map{ |k,v| "&" + k + "=" + URI.encode(v.to_s).gsub(/@/,"%40").gsub(/\+/,"%2B"); }.join('');
    return HTTParty.get(@base_url + query)
end



Company.where(:is_fake => false).each do |c|
	puts c.business_name
	res = ac_post("contact_list",{"filters[fields][%TCOMPANYID%]"=>c.id})
	res.delete("result_code")
	res.delete("result_message")
	res.delete("result_output")

	res.each do |k,contact|
		if contact["fields"].select{ |k,v| v["tag"] == "%TROLES%"}.first[1]["val"] == "||||||||"
			puts contact["email"] + "\t" + contact["subscriberid"]
			User.where(:email => contact["email"]).each do |u|
				delete = true

				CompanyUser.where(:user_id => u.id).each do |cu|
					if cu.is_admin || cu.is_billing || cu.is_sales_staff
						puts "Role Found!			"
						delete = false
					else
						puts "..."
					end
				end

				if delete
					puts "removing #{u.id} (#{u.email})"
					active_campaign_delete_email u.email
				sleep(2)
				end
			end
		end
		#contact["fields"].select{ |k,v| v["tag"] == "%TROLES%"}.first[1]["val"]
	end;
	sleep(5)
end;