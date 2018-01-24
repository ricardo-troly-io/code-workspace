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

def find_by_sha_or_email(sha, email, fname=nil, lname=nil, org=nil)
    result = nil;

    res_sha = sha.present? ? ac_post('contact_list', {"filters[fields][%SHA%]" => sha}) : nil;
    res_email = email.present? ? ac_get('contact_view_email', {"email" => email}) : nil;

    if res_sha.present? && res_sha.count == 4

        result = res_sha["0"];

    elsif res_email.present? && res_email["result_code"] != 0
        
        result = res_email

    elsif res_sha.present? && res_sha.count > 4
        
        RakeHelper::rputs "It appears SHA:#{sha} is not unique: (Fix and run again)"

        res_sha.delete("result_output")
        res_sha.delete("result_code")
        res_sha.delete("result_message")

        res_sha.map{ |k,v| puts "#{v['email']} → https://comms.troly.io/app/contacts/#{v['id']}" }

        return nil;

    end

    if result.present?
        updates = {}

        if (email.present? && result["email"] != email) && (result["email"].blank? || 'y' == RakeHelper::stdin_for_regex(/[yn]/, "Contact found with different EMAIL address (#{result["email"]}, new value is #{email}). Update? [yn]"))
            updates.merge!({ "id" => result["id"], "overwrite" => "0", "email" => email})
        end
        if (fname.present? && result["first_name"] != fname) && (result["first_name"].blank? || 'y' == RakeHelper::stdin_for_regex(/[yn]/, "Contact found with different NAME (#{result["first_name"]} #{result["last_name"]}, new value is #{fname} #{lname}). Update? [yn]"))
            updates.merge!({ "id" => result["id"], "overwrite" => "0", "first_name" => fname, "last_name" => lname})
        end
        if (org.present? && result["orgname"] != org) && (result["orgname"].blank? || 'y' == RakeHelper::stdin_for_regex(/[yn]/, "Contact found with different ORGANISATION (#{result["orgname"]}, new value is #{org}). Update? [yn]"))
            updates.merge!({ "id" => result["id"], "overwrite" => "0", "orgname" => org})
        end

        if @for_real && updates.length > 0
            ac_post("contact_edit", updates)
            result = ac_get("contact_view", {"id" => result["id"]})
        
            #RakeHelper::stdin_for_regex(/[yn]/, "#{result["result_message"]}: https://comms.troly.io/app/contacts/#{result["id"]}. Continue? [yn]")
        end

    elsif email.present? && ('y' == RakeHelper::stdin_for_regex(/[yn]/, "No contact found for SHA:#{sha} EMAIL:#{email}. Create? [yn]"))
        
        res = ac_post('contact_add', {"email" => email, "field[%SHA%]" => sha})
        if res["result_code"] == 0
            RakeHelper::rputs "There was an error creating this record:"
            puts res.inspect
            #error
        else
            res = ac_get("contact_view", {"id" => res["subscriber_id"]})
            if res["result_code"] != 0
                result = res;
            end
        end

    end

    return result;
    
end

$agents = nil
def find_agent(email, fname)

    fname = fname.split(' ').first
    if $agents.blank?
        $agents = ac_get("user_list",{"ids"=>"all"})
    end
    $agents.each do |k,x|
        if x.class == Hash && x["id"].present? && (x["email"] == email || x["first_name"] == fname)
            return x;
        end
    end
    return nil;
end

def create_deal_if_not_found(org, contact_id, agent)

    res = ac_get("deal_list",{"filters[title]"=>org,"status"=>"0"})

    if (res["deals"].count > 0)
        deal = res["deals"].first
    else
        RakeHelper::gputs("Creating deal for '#{org}'")
        deal = ac_post("deal_add",{"title"=>org,"value"=>"100","currency"=>"aud","pipeline"=>"1","stage"=>"1","contactid"=>contact_id})
    end

    if (agent.present? && deal["owner"] != agent)
        ac_post("deal_edit",{"id" => deal["id"],"userid"=>agent})
        deal = ac_get('deal_get', {"id"=>deal["id"]})

    end
    return deal;
end

def find_campaign_tag(tags)
    selection = tags.select{ |t| t.match(/CALL\s\d{3}\s/) }
    if selection.present?
        return selection.last.match(/CALL\s\d{3}\s/)[0].gsub(/CALL\s/,"CALLED ")
    end

    campaigns = [
        "CALL 001: Email Missing",
        "CALL 002 REVIVE: got smashed",
        "CALL 003 REVIVE",
        "CALL 004 INTRO",
        "CALL 005 HELLO",
    ]

    campaign = RakeHelper::pick_from_array(Hash[(1...campaigns.size+1).zip campaigns], "Tag missing. What was the campaign for this contact?").to_i - 1

    return campaigns[campaign] + "," + campaigns[campaign].match(/CALL\s\d{3}\s/)[0].gsub(/CALL\s/,"CALLED ");
end

session = RakeHelper::init_google_session
sheet_name = "EZLeads Forrest Clean List"
wsheet = RakeHelper::init_google_worksheet nil, sheet_name, session

columns=Hash[(0...wsheet.rows[0].size).zip wsheet.rows[0]]
sha_col=(RakeHelper::pick_from_array(columns, "What column is the SHA value is stored in?").to_i + 1);
action_col=(RakeHelper::pick_from_array(columns, "What column is the ACTION is stored in?").to_i + 1);
params_col=(RakeHelper::pick_from_array(columns, "What column are the ACTION PARAMS stored in?").to_i + 1);
fname_col=(RakeHelper::pick_from_array(columns, "What column are the FIRST NAME stored in?").to_i + 1);
lname_col=(RakeHelper::pick_from_array(columns, "What column are the LAST NAME stored in?").to_i + 1);
results_col=(RakeHelper::pick_from_array(columns, "What column are RESULTS stored in?").to_i + 1);
org_col=(RakeHelper::pick_from_array(columns, "What column is the ORGANISATION stored in?").to_i + 1);
email_col=(RakeHelper::pick_from_array(columns, "What column is the EMAIL stored in?").to_i + 1);
agent_col=(RakeHelper::pick_from_array(columns, "What column is the AGENT stored in?").to_i + 1);
notes_col=(RakeHelper::pick_from_array(columns, "What column are NOTES stored in?").to_i + 1);
notes_email_col=(RakeHelper::pick_from_array(columns, "What column are NOTES TO EMAIL stored in?").to_i + 1);
date_col=(RakeHelper::pick_from_array(columns, "What column are DATE stored in?").to_i + 1);

while true
    wsheet.reload
    wsheet = RakeHelper::init_google_worksheet nil, sheet_name, session

row=1
while (row+=1) <= wsheet.num_rows
    next if wsheet[row,action_col].blank?

    contact = find_by_sha_or_email(wsheet[row,sha_col], wsheet[row,email_col], wsheet[row,fname_col], wsheet[row,lname_col], wsheet[row,org_col])

    next if contact.blank?

    wsheet[row,action_col].split(",").each do |action|
        action = action.gsub(/^\s*/,"").gsub(/\s*$/,"");
    
        RakeHelper::gputs("Processing #{action} for #{wsheet[row,org_col]}")
    
        case action
        #when 'EMAIL_NOTES' 

         #   from_notes = contact["fields"]["26"]["val"]
          #  to_notes = wsheet[row,params_col]

           # RakeHelper::gputs("Updating NOTES from '#{from_notes}' to '#{to_notes}'")
            #if @for_real
             #   ac_post("contact_edit",{ "id" => contact["id"], "overwrite" => "0", "field[26,0]" => to_notes})
            #end
            #wsheet[row,results_col] = wsheet[row,results_col] + "\nNOTES added: #{to_notes}"

        when 'ADD_TAG'

            tags = wsheet[row,params_col]
            if (tags.match(/successful/i) && !tags.match(/unsuccessful/i))
                if @for_real
                    create_deal_if_not_found(contact["orgname"],contact["id"],find_agent(nil,wsheet[row,agent_col])["id"])
                end
                wsheet[row,results_col] = wsheet[row,results_col] + "\nDeal Created: #{contact["orgname"]}"
            end

            campaign_tag = find_campaign_tag(contact["tags"])

            tags = tags.gsub(/,\s/,",")
            tags = tags.gsub(/unsuccessful/i, campaign_tag + "✖")
            tags = tags.gsub(/successful/i, campaign_tag + "✓")
            
            from_tags = contact["tags"].join(",")
            to_tags = (contact["tags"] + tags.split(",")).join(",")

            RakeHelper::gputs("Updating tags from '#{from_tags}' to '#{to_tags}'")
            if @for_real
                ac_post("contact_edit",{ "id" => contact["id"], "overwrite" => "0", "tags" => to_tags, "p[3]"=>"1", "p[9]" => "1", "p[10]" =>"1"})
            end
            wsheet[row,results_col] = wsheet[row,results_col] + "\nTags Updated to #{to_tags}"
       
        when 'REC_NOTES' 

            RakeHelper::gputs("Recording call notes")
            notes = "(#{wsheet[row,date_col]} by #{wsheet[row,agent_col]}) #{wsheet[row,notes_col]}"
            if @for_real
                ac_post("contact_note_add",{ "id" => contact["id"], "listid" => "0", "note" => notes })
            end
            wsheet[row,results_col] = wsheet[row,results_col] + "\nNotes recorded (#{notes.split(' ').count} words)"

        end
    end
    
    wsheet[row,results_col] = wsheet[row,results_col].gsub(/^[\n\s]*/,"");
    wsheet.save
end
end



res = HTTParty.post(base_url, {:body => "filters[first_name]=John&api_action=contact_list", :headers => { 'Content-Type' => 'application/x-www-form-urlencoded' }})