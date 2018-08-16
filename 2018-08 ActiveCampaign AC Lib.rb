API_ENDPOINT = "https://troly.api-us1.com/admin/api.php?api_key=#{Rails.application.secrets.active_campaign_api_key}&api_output=json"
API_ENDPOINT_3 = "https://troly.api-us1.com/api/3"
POST_HEADERS = {'Content-Type' => 'application/x-www-form-urlencoded'}

# Call V1 of the API
def get_from_ac action, query
	url = "#{API_ENDPOINT}&api_action=#{action}"
	
	return JSON.parse(HTTParty.get(url, {:query => query}).response.body)
end

# Call V3 of the API
def get_from_ac3 resource, id=''
	url = id.blank? ? "#{API_ENDPOINT_3}/#{resource}?limit=100" : "#{API_ENDPOINT_3}/#{resource}/#{id}/?limit=100"
	res = JSON.parse(HTTParty.get(url, :headers => {'Content-Type': 'text/json', 'Api-Token': Rails.application.secrets.active_campaign_api_key}).response.body)
	return res if res['meta'].blank?
	if res[res.keys.first].count < res['meta']['total'].to_i
		max = res['meta']['total']
		while res[res.keys.first].count <= max
			count = res[res.keys.first].count
			res2 = HTTParty.get("#{url}&?offset=#{count}", :headers => {'Content-Type': 'text/json', 'Api-Token': Rails.application.secrets.active_campaign_api_key})
			# puts "Getting #{count}... #{res2.keys.first}"
			res[res2.keys.first] += res2[res2.keys.first]
		end
	end
	return res
end

# The V3 version returns raw endpoints to call
# This lets you call them easily
def get_from_ac3_raw endpoint
	res = HTTParty.get(endpoint, :headers => {'Content-Type': 'text/json', 'Api-Token': Rails.application.secrets.active_campaign_api_key}).response.body
	return JSON.parse(res)
end

# Post to V1 of the API
def post_to_ac action, payload
	url = "#{API_ENDPOINT}&api_action=#{action}&overwrite=0"
	return JSON.generate(HTTParty.post(url, {:body => URI.encode_www_form(payload), :headers => POST_HEADERS}).response.body)
end

# finds a custom field by name (ie, personalisation tag) on given AC contact. returns nil when not found
def find_in_ac_contact_fields(ac_contact,field)
		
	field = field.upcase
	field = "%" + field + "%" if field[0] != "%"

	return ac_contact["fields"].select{ |k,v| v["tag"] == field}.first[1]["val"]
end
