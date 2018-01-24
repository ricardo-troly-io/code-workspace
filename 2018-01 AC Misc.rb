
def ignore_update_missing_hashes

	res = ac_post("contact_list",{"filters[fields][%SHA%]"=>""})

	res.delete("result_message")
	res.delete("result_code")
	res.delete("result_output")

	res.keys.each do |k|

		contact = res[k]
	

		updates = { "id" => contact["id"], "overwrite" => "0", "field[%SHA%,0]" => contact["hash"]}

		
		out = ac_post("contact_edit", updates)

		if out["result_code"] == 1
			RakeHelper::gputs "Updating #{contact['email']} (#{contact['id']}) to #{contact['hash']} (#{out['result_message']})"
		else
			RakeHelper::rputs "Failed updating #{contact['email']} (#{contact['id']}) to #{contact['hash']} (#{out['result_message']})"
		end

		sleep (2)

	end
end

def ignore_sync_company_data (company_id)


	Company.where(:id => company_id).each do |c|
	
		res = ac_post("contact_list",{"filters[fields][%TCOMPANYID%]"=>c.id})


		h = c.integrations.group_by(&:status).map{ |k,v| {k => v.map{ |i| i.processor + "_" + i.provider}}}.reduce({}, :merge)
		payload = { :company => c, :company__integrations => h }

	end




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


def company_updates (troly_company)

	updates = {}
	##
## ORGANISATION
##
	updates["orgname"] = troly_company.business_name
	updates["field[%TCOMPANYID%,0]"] = troly_company.id
	updates["phone"] = troly_company.phone
	updates["field[%POSTCODE%,0"] = troly_company.postcode
	updates["field[%TCOMPANYCREATEDAT%,0"] = troly_company.created_at


##
## STATS
##

	last_month = Time.now.last_month
	last_3month = (last_month - 2.months).beginning_of_month..last_month.end_of_month
	last_6month = (last_month - 5.months).beginning_of_month..last_month.end_of_month
	last_month = last_month.beginning_of_month..last_month.end_of_month

	updates["field[%TMONTHLYSALES%,0]"] = Payment.where(:company_id => troly_company.id, :trx => ['offline','charge'], :created_at => last_month).sum(:amount).to_i
	updates["field[%T3MONTHLYSALES%,0]"] = Payment.where(:company_id => troly_company.id, :trx => ['offline','charge'], :created_at => last_3month).sum(:amount).to_i / 3
	updates["field[%T6MONTHLYSALES%,0]"] = Payment.where(:company_id => troly_company.id, :trx => ['offline','charge'], :created_at => last_6month).sum(:amount).to_i / 6

##
## INTEGRATIONS
##
	updates["field[%TADDONSINSTALLED%,0]"] = []
	updates["field[%TADDONSINSTALLING%,0]"] = []

	# loop or switch or else
	updates["field[%TADDONSINSTALLED%,0]"] += ["Shipping - FastWay (Troly)"]
	updates["field[%TADDONSINSTALLED%,0]"] += ["Payments - Troly (CBA)"]

	# end

	updates["field[%TADDONSINSTALLED%,0]"] = "||" + updates["field[%TADDONSINSTALLED%,0]"].join("||") + "||"
	updates["field[%TADDONSINSTALLING%,0]"] = "||" + updates["field[%TADDONSINSTALLING%,0]"].join("||") + "||"

return updates
end

def push_company ( troly_company )

	troly.company.where(:is_admin => true, :asdasdsa).each do
		updates = { "id" => ac_user["id"], 
			"overwrite" => "0", 
			"field[%SHA%,0]" => ac_user["hash"],
			"field[%TUSERID%,0]" => troly_user.id,
			"field[%TUSERCREATEDAT%,0]" => troly_user.created_at
		   }

		 updates.merge!(push_company(cu.company))

		 out = ac_post("contact_edit", updates)
	end
end

def find_or_create_user (email)

	ac_user = ac_get('contact_view_email', {"email" => email})

	if (ac_user["result_code"] == 0)
		res = ac_post('contact_add', {"email" => email})

		if res["result_code"] == 1
			ac_user = ac_get('contact_view_email', {"email" => email})
			RakeHelper::yputs "Contact created #{ac_user['email']} (#{ac_user['id']})"
		else
			ac_user = nil
			RakeHelper::rputs "Contact doesn't exist and could not be created #{troly_user.email}"
		end
	end

	return ac_user
end

def push_user ( troly_user )

	cu = CompanyUser.where(:user_id => troly_user.id).first


	# exclude any user signining up as result of an errir
	if !(cu.is_admin || cu.is_billing || cu.is_sales_staff)
		RakeHelper::rputs "#{troly_user.email} is not a Company contact for #{cu.company.business_name}"
		return nil;
	end

	if (troly_user.email.match(/empireone|subscribility|troly/))
		RakeHelper::yputs "#{troly_user.email} doesn't need record as Company contact for #{cu.company.business_name}"
		return nil;
	end

	ac_user = fond_or_create_user( troly_user )

	updates = { "id" => ac_user["id"], 
				"overwrite" => "0", 
				"field[%SHA%,0]" => ac_user["hash"],
				"first_name" => troly_user.fname,
				"last_name" => troly_user.lname,
				"field[%TUSERID%,0]" => troly_user.id,
				"field[%TUSERCREATEDAT%,0]" => troly_user.created_at
			   }


##
## USER ROLES
##
	updates["field[%TROLES%,0]"] = []
	updates["tags"] = ac_user["tags"] || []

	if (cu.is_admin)
		updates["field[%TROLES%,0]"] += ["Company Admin"]
		updates["tags"] += ["Company Admin"]
	end
	if (cu.is_billing)
		updates["field[%TROLES%,0]"] += ["Billing Contact"]
		updates["tags"] += ["Company Billing"]
	end
	if (cu.is_sales_staff)
		updates["field[%TROLES%,0]"] += ["Sales Staff"]
		updates["tags"] += ["Company Sales"]
	end

	updates["field[%TROLES%,0]"] = "||" + updates["field[%TROLES%,0]"].join("||") + "||"
	updates["tags"] = updates["tags"].join(", ")

	updates.merge!(push_company(cu.company))


	#integrations

	out = ac_post("contact_edit", updates)

	if out["result_code"] == 1
		RakeHelper::gputs "Updating #{cu.company.business_name}: #{ac_user['email']} (#{ac_user['id']}) (#{out['result_message']})"
	else
		RakeHelper::rputs "Failed to update #{cu.company.business_name}: #{ac_user['email']} (#{ac_user['id']}) (#{out['result_message']})"
	end


	#ac_post('track_event_add',, "event" => "pipeline 05 monthly sales reached", "eventdata" => last_month.end.to_s.split(" ")[0].to_s})

	sleep(1)
end


Company.where(:is_fake => false, :created_at => (Time.now - 5.years)..Time.now.last_year).where("id > 1000").each do |c|
	c.company_users.where.not(:user_id => [nil,'']).each do |cu|
		next if cu.user.blank?
		create_or_update_user cu.user
	end
end;



