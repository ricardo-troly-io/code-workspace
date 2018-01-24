

Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper

session=RakeHelper::init_google_session

wsheet=RakeHelper::init_google_worksheet nil, "Pipedrive Import Worksheet", session


9199

Pipedrive.authenticate('f5daf99190a7cbe95b1c4b2169196ea4b76d438b')
METADATA="0a27dbe26b511eb0b2efebc7a0dedf509a97906c"
DETAILS="6f9dbe12bf139d7a88c73189a5f329ff54a76fea"
CAMPAIGNS="a7ca684a0b9f2543692592318902c70f1ed0ce04"

def website_uses_wordpress(url)
	return false if url.blank?

	url = "http://#{url}" if url[0..3] != 'http'
	begin
		www=HTTParty.get("#{url}/wp-login.php", follow_redirects: [301,302])
	rescue => e
		puts e.inspect
		return false
	end
	return www.code == 200 && /wordpress|WordPress|wp-admin|wp-content/.match(www.response.body).present?
end


deal_id = RakeHelper::pick_from_array(Hash[(0...wsheet.rows[0].size).zip wsheet.rows[0]], "What column is the DEAL ID stored in?").to_i + 1
org_id = RakeHelper::pick_from_array(Hash[(0...wsheet.rows[0].size).zip wsheet.rows[0]], "What column is the ORG ID stored in?").to_i + 1
ppl_id = RakeHelper::pick_from_array(Hash[(0...wsheet.rows[0].size).zip wsheet.rows[0]], "What column is the PERSON ID stored in?").to_i + 1
owner = RakeHelper::pick_from_array(Hash[(0...wsheet.rows[0].size).zip wsheet.rows[0]], "What column is the OWNER stored in?").to_i + 1
marker = RakeHelper::pick_from_array(Hash[(0...wsheet.rows[0].size).zip wsheet.rows[0]], "What column is the MARKER stored in?").to_i + 1
subject = marker+1

i = 1
j = wsheet.rows.count
while (i < j)
	case wsheet[i,5]
	when /Tremblay/
		owner_id=1835035
	when /Ligneris/
		owner_id=1835779
	else
		owner_id=1835762
	end

	#Pipedrive::Activity.create({ subject:"FU: Open & Click", type:"follow_up_call", deal_id:wsheet[i,1], person_id:wsheet[i,3], org_id:wsheet[i,2], due_date:'tomorrow', assigned_to_user_id:owner_id })
end

cols=
column = RakeHelper::pick_from_array(Hash[(0...wsheet.rows[0].size).zip wsheet.rows[0]], "What column is the email stored in?").to_i + 1
date_column = RakeHelper::pick_from_array(Hash[(0...wsheet.rows[0].size).zip wsheet.rows[0]], "What column has the last activity date stored in?").to_i + 1
add_to = RakeHelper::stdin_for_regex(/[A-Z]{1}/,"What column to store interactions?").ord() - 64

i = 1
j = wsheet.rows.count
while (i < j)
	if (i % 100) == 0
		wsheet.save
	end
	i +=1
	if wsheet[i,column].blank?
		RakeHelper::rputs "Email missing for #{wsheet.rows[0][0]}: #{wsheet[i,1]}"
		next
	end

	wsheet[i,column].split(',').each_with_index do |email,idx|
		email = email.strip

		response = HTTParty.get("https://api.mixmax.com/v1/events?search=to:#{email},", :headers => { "X-API-Token" => "410c8e17-edf8-4d81-8f6b-c940c189f861"})
		if response["results"].blank?
			RakeHelper::rputs "#{sprintf(" %-4s", i)} No recorded interactions with #{email} [#{idx}] (#{response["results"].inspect})"
			next
		end

		response["results"].map{ |r| r["subject"] }.uniq.each_with_index do |subject,subject_offset|

			subject_offset *= 4

			o = response["results"].select{ |r| r["action"] == 'opened' && r["subject"] == subject}.count
			c = response["results"].select{ |r| r["action"] == 'clicked' && r["subject"] == subject}.count
			clicks = response["results"].select{ |r| r["action"] == 'clicked' && r["subject"] == subject}.map{ |r| r["object"]["title"] }
			
			if ( o > 0 || c > 0 )

				wsheet[i,add_to+0+subject_offset] = subject
				wsheet[i,add_to+1+subject_offset] = o
				wsheet[i,add_to+2+subject_offset] = c
				wsheet[i,add_to+3+subject_offset] = clicks.join(', ')

				if ( c >= 1 )
					RakeHelper::gputs "!!! #{o} opens, #{c} clicks from #{email} on '#{subject}'"

					case wsheet[i,5]
						when /Tremblay/
							owner_id=1835035
						when /Ligneris/
							owner_id=1835779
						else
							owner_id=1835762
					end

					if /[Ss]urvey/.match(clicks.join())
						RakeHelper::pputs "CREATE FU:Survey (#{clicks.join(', ')})"

						deal=Pipedrive::Deal.find(wsheet[i,1])
						deal.update({ "df78389d75a833a6168b220ef03f280ab044deeb" => "clicked" })

						RakeHelper::gputs "1 Creating Survey Clicked"
						#Pipedrive::Activity.create({ subject:"FU: Survey Clicked", type:"follow_up_call", deal_id:wsheet[i,1], person_id:wsheet[i,3], org_id:wsheet[i,2], assigned_to_user_id:owner_id })
					else
						#RakeHelper::pputs "CREATE FU:Email (#{clicks.join(', ')})"
						RakeHelper::gputs "2 Creating Open  Click"
						#Pipedrive::Activity.create({ subject:"FU: Open & Click", type:"follow_up_call", deal_id:wsheet[i,1], person_id:wsheet[i,3], org_id:wsheet[i,2], due_date:'tomorrow', assigned_to_user_id:owner_id })
					end
				elsif o > 2
					RakeHelper::gputs "2 Creating Open  Click"
				else
					RakeHelper::yputs "#{o} opens, #{c} clicks from #{email} on '#{subject}'"
				end
			else
				RakeHelper::yputs "#{o} opens, #{c} clicks from #{email} on '#{subject}'"
			end
		end
		sleep(2)
	end
end;
wsheet.save;


website_uses_wordpress('stompwine.com.au')


column = RakeHelper::stdin_for_regex(/[A-Z]{1}/,"What column is the website stored in?").ord() - 64
i = 1
j = wsheet.rows.count#1RakeHelper::stdin_for_regex(/\d/,"What row should we start with?").to_i
while i < j
	if (i % 50) == 0
		wsheet.save
	end
	i +=1
	next if wsheet[i,column].blank? || wsheet[i,column+1].present? 
	if website_uses_wordpress(wsheet[i,column])
		RakeHelper::gputs "#{wsheet[i,1]} (#{wsheet[i,column]})"
		wsheet[i,column+1] = "✓";
	elsif !wsheet[i,column].blank?
		RakeHelper::rputs "#{wsheet[i,1]} (#{wsheet[i,column]})"
		wsheet[i,column+1] = "✖";
	end

end;
wsheet.save



## UPDATE/ADD WordPress Tag

column = RakeHelper::stdin_for_regex(/\d/,"What column is the website stored in?").to_i
i = 1
j = wsheet.rows.count#1RakeHelper::stdin_for_regex(/\d/,"What row should we start with?").to_i
while i < j

	i+=1

	next if wsheet[i,column+1].blank?

	org = Pipedrive::Organization.find(wsheet[i,2])
	details = org[DETAILS]
	details = details.blank? ? [] : details.split(',')

	if wsheet[i,column+1] == "✓" 
		if !details.include?("55")
			RakeHelper::pputs "Adding WordPress to #{org.name}"
			details << "55"
			org.update({DETAILS => details.join(',')})
		else
			RakeHelper::yputs "#{org.name} flagged as WordPress"
		end
	elsif wsheet[i,column+1] == "✖"
		if details.include?("55")
			RakeHelper::gputs "Removing WordPress from #{org.name}"
			details -= ["55"]
			org.update({DETAILS => details.join(',')})
		else
			RakeHelper::yputs "#{org.name} not flagged as WordPress"
		end
	
	end
	sleep(1)
end



trx_p_month_col=nil
trx_total_col=nil

wsheet.rows.each do |row|

	c=Company.find(row[0])

	c.provider_data ||= { :external_ids => {}} 
	
	if c.provider_data[:external_ids][:pipedrive].blank?
		c.provider_data[:external_ids][:pipedrive] = RakeHelper::stdin_for_regex(/\d/,"What is the Pipedrive ID for this company?").to_i 
		c.save!
	end

	trx_p_month_col = RakeHelper::pick_from_array(Hash[(0...wsheet.rows[0].size).zip wsheet.rows[0]], "What column is Trx Per Month stored in?").to_i if trx_p_month_col.nil?
	trx_total_col = RakeHelper::pick_from_array(Hash[(0...wsheet.rows[0].size).zip wsheet.rows[0]], "What column is Trx Per Month stored in?").to_i if trx_total_col.nil?

	org=Pipedrive::Organization.find(c.provider_data[:external_ids][:pipedrive])
	
	meta = org[METADATA]
	meta = meta.blank? ? {} : Hash[meta.split("\n|,\s").collect { |m| m.split('=') }]

	meta["s99234_id"] = c.id
	meta["s99234_cc"] = c.cc_number.blank? ? 'no' : 'yes'
	meta["s99234_premium"] = c.is_premium == true ? 'yes' : 'no'
	meta["s99234_1500"] = row[trx_total_col].to_f > 1500 ? 'yes' : 'no'
	meta["s99234_pmth"] = (row[trx_p_month_col].to_f < 250 ? '=0' : (row[trx_p_month_col].to_f < 2500 ? '<2500' : (row[trx_p_month_col].to_f > 5000 ? '>2500' : '2500-5000')))
 
	org.update({METADATA => meta.map { |k,v|  "#{k}=#{v}"; }.join("\n")})

	sleep(1);
end





wsheet.rows.each do |row|
	next if row[2].blank? || row[2] == '#N/A'
	org=Pipedrive::Organization.find(row[2])
	org.update({"05de570fc981f33584de19bd381f228097edee15" => row[0]})
end;


ppl.update({"phone" => [{"label"=>"", "value"=>"other", "primary"=>false}, {"label"=>"", "value"=>"1233333", "primary"=>false}, {"label"=>"", "value"=>"true", "primary"=>false}]})
ppl.update({"phone" => {"label"=>"mobile", "value"=>"123"}})
ppl.update({"phone" => [{"Work"=>"123"}]})

i=2
j=wsheet.rows.count
while (i <= j) do
	ppl=Pipedrive::Person.find(wsheet[i,2])
	puts ppl.name
	ppl.update({"phone" => wsheet[i,9].split("|")})
	i+=1;
	sleep(1)
end;

i=2
j=wsheet.rows.count
while (i <= j) do
	ids = wsheet[i,3]
	i+=1;
	next if ids.blank?
	puts wsheet[i,1]
	ids = ids.split('|')
	HTTParty.post("https://api.pipedrive.com/v1/organizations/#{ids.max}/merge?api_token=f5daf99190a7cbe95b1c4b2169196ea4b76d438b", :body => { "merge_with_id" => ids.min })
	
	sleep(1)
end;


MASS MERGING
## $('.custom-fields-edit li span').each(function(a,s) { console.log(s.id + " → " + s.innerText); })

custom_field_52 → Competitor → Vin65
custom_field_53 → EDM → Mailchimp
custom_field_54 → EDM → Campaign Monitor
custom_field_55 → Website → WordPress
custom_field_56 → Website → Other
custom_field_57 → Competitor → cru.io
custom_field_58 → Competitor → Blackboxx
custom_field_59 → POS → VEND
custom_field_60 → POS → ImPOS
custom_field_61 → POS → Other
custom_field_62 → Accounting → Xero
custom_field_63 → Accounting → MYOB
custom_field_64 → Accounting → Other
custom_field_65 → NEEDS → Website
custom_field_66 → NEEDS → POS
custom_field_67 → NEEDS → Marketing
custom_field_68 → POS → SENPOS
custom_field_79 → Website → Winebox
custom_field_80 → Competitor → Other


https://s99234.pipedrive.com/organization/8750