Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper

Google::APIClient.logger.level = 2

@api_endpoint = "https://troly.api-us1.com"
@api_token = "f8b7ef441352e9883df8a3bc93f2b86575bb35bf8f52237f0ee34e8f4a12e5f2abaa3efb"
@base_url = @api_endpoint + "/admin/api.php?api_output=json&api_key=" + @api_token + "&"
@headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
@for_real = true


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

# A) deal_get can only take a deal ID, no possibility to "search for a single deal and return it", and 
# B) The standard response returned from deal_get so we'll handle this here.
def ac_get_deal(params)
    ac_deals = ac_get('deal_list',params)
    RakeHelper::rputs "More than one deal available for ac_get_deal (#{params})" if  ac_deals["deals"].count > 1
    
    return nil if ac_deals["deals"].count == 0

    ac_deal = ac_post('deal_get',{ 'id' => ac_deals["deals"][0]["id"]})
    ac_deal["id"] = ac_deals["deals"][0]["id"]

    return ac_deal
end

def get_col(columns, question, regex_matches=nil)

    if regex_matches.present?

        match_cols = columns.select{ |k,v| v.match(Regexp.new(regex_matches)) }
        return match_cols.keys.first+1 if match_cols.size == 1

        columns = match_cols if match_cols.size > 1
    end

    return (RakeHelper::pick_from_array(columns, question).to_i + 1)
end

def add_website_intel_to_sheet(wsheet_or_session = nil)

    if (wsheet_or_session.is_a? GoogleDrive::Session)
        session = wsheet_or_session
        wsheet = RakeHelper::init_google_worksheet nil, nil, session
    elsif (wsheet_or_session.is_a? GoogleDrive::Worksheet)
        session = nil
        wsheet = wsheet_or_session
        wsheet.reload
    else
        session = RakeHelper::init_google_session
        wsheet = RakeHelper::init_google_worksheet nil, nil, session
    end

    columns=Hash[(0...wsheet.rows[0].size).zip wsheet.rows[0]]
    website_col=get_col(columns, "Where is the website URL stored in?","url|web");
    intel_col=get_col(columns, "Where should we store results in?", "cms");

    i=2 #skip first row (header)
    pending_changes = 0
    while i <= wsheet.max_rows do

        if wsheet[i,website_col].present? 
            if wsheet[i,intel_col].blank?
                #RakeHelper::pputs wsheet[i,website_col]
                
                website_intel = get_website_intel(wsheet[i,website_col])
                if website_intel.present?

                    cms = (website_intel[:website_cms].present? ? website_intel[:website_cms] : ( website_intel[:code] != 200 ? "Website Error" : ( website_intel[:competitor].present? ? website_intel[:competitor] : "" ) ))

                    wsheet[i,intel_col] = website_intel.map{|k,v| "#{k}: #{v}"}.join("\n")
                    #wsheet[i,intel_col] = cms
                    
                    
                    if cms.present? # prepare for saving
                        pending_changes = pending_changes + 1
                        RakeHelper::pputs "[#{pending_changes}] #{wsheet[i,website_col]} updated (#{cms})"
                        #wsheet.save
                    else
                        RakeHelper::yputs("No intel found for #{wsheet[i,website_col]}", "→")
                    end
                end
            else
                RakeHelper::yputs "Intel cell not empty for #{wsheet[i,website_col]}"
            end
        else
            RakeHelper::rputs "No website found for row #{i}"
        end

        i=i+1

        if (pending_changes >= 25) # only save max 25 ros
            RakeHelper::gputs "Saving #{pending_changes} records"
            wsheet.save
            pending_changes = 0
        end
    end

    if pending_changes > 0
        RakeHelper::gputs "Saving the last #{pending_changes} records"
        wsheet.save
    end

    return [session,wsheet]
end


def get_website_intel(domain, level=0)
    ua = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36'

    domain.gsub!(/^http(s)?:\/\//,"")
    domain.gsub!(/^www\./,"")
    domain.gsub!(/\/$/,"")
    domain.gsub!(/[^a-zA-Z0-9\.\-]/,"")

    website_url = ''
    response = ''

    [
        "https://store.#{domain}",
        "https://shop.#{domain}/Wines",
        "https://shop.#{domain}/index.cfm",
        "https://shop.#{domain}",
        "https://#{domain}/shop",
        "https://#{domain}/store",
        "https://www.#{domain}/shop",
        "https://www.#{domain}",
        "https://#{domain}",

    ].each do |website|
    
        RakeHelper::yputs "Checking #{website}" if level > 1
        begin

            begin
                response = HTTParty.get(website, {:follow_redirects => true, :timeout => 5, headers: {"User-Agent" => ua}})
            rescue Errno::ECONNRESET, Errno::ECONNREFUSED, OpenSSL::SSL::SSLError, HTTParty::RedirectionTooDeep, Net::OpenTimeout
                RakeHelper::rputs "Connection refused or SSL error encountered, trying HTTP" if level > 1
                response = HTTParty.get(website.sub!(/^https/,"http"), {:verify => false, :follow_redirects => true, :timeout => 5, headers: {"User-Agent" => ua}})
            end

            begin
                response.blank? # seems to be the only way around UTF-8 Errors....! 
            rescue # seems to be the only way around UTF-8 Errors....!
                response = '' 
            end

            if response.present? && response.code == 200 && response.match(/(web)?site not found/i).blank? && response.match(/<\/?head>/) && response.size > 1024
                website_url = website
            end
        rescue

        end
        
        break if website_url.present?
    end
    
    intel = {
        :website_cms => '',
        :competitor => '',
        :domain => domain,
        :code => response.present? ? response.code : 404,
        :ssl_enabled => website_url.match(/^https/).present?,
        :url => website_url.to_s,
    }

    if website_url.blank?
        RakeHelper::rputs "No matching URL found for #{domain}" if level > 0
        return intel 
    end

    RakeHelper::pputs "Inspecting #{website_url} (#{response.code})" if level > 1

    generator = response.match(/name="(generator)" content="(.*?)"/);
    generator = response.match(/name="(platform|author)" content="(.*?)"/) if generator.blank?

    if (generator.present?)
        case generator[2]
        when /Go Daddy/i
        when /Starfield Technologies/i
            intel[:website_cms] = 'GoDaddy'
        when /vinSUITE/i
            intel[:competitor] = 'vinSuite'
        when /eWinery Solutions/
            intel[:competitor] = 'vinSuite (eWinery Solutions)'
        when /Wix/i
            intel[:website_cms] = 'Wix.com'
        when /simplyCMS/i
            intel[:website_cms] = 'simplyCMS'
            intel[:competitor]  = 'simplyCMS'
        when /WineDirect|vin65/i
            intel[:website_cms]  = 'WineDirect'
            intel[:competitor]  = 'WineDirect'
        when /Commerce by Figure/i
            intel[:competitor]  = 'Figure'
        when /Xudle\.com|X&uuml;dle/i
            intel[:competitor]  = 'Xudle'
            intel[:website_cms]  = 'Xudle'
        when /Drupal/i
            intel[:website_cms] = 'Drupal'
        when /SiteBuilder/i
            intel[:website_cms] = 'Y! SiteBuilder'
        when /Joomla/i
            intel[:website_cms] = 'Joomla'
        when /WordPress/i
            intel[:website_cms] = 'WordPress'
        else 
            if (response.match(/name="(generator)" content="(.*?)"/))
                intel[:website_cms] = generator[2]
                RakeHelper::yputs "Generator Not Handled: #{generator[2]} (#{website_url})" 
            end
        end
    end

    if website_url.match(/(store|shop)\./)
        tmp_response = nil;
        begin
            begin
                tmp_response = HTTParty.get(website_url.sub(/\/\/(store|shop)\./,"\/\/www."), {:follow_redirects => true, :timeout => 5, headers: {"User-Agent" => ua}})
            rescue Errno::ECONNRESET, Errno::ECONNREFUSED
                RakeHelper::rputs "Connection refused, trying without www" if level > 1
                tmp_response = HTTParty.get(website_url.sub(/\/\/(store|shop)\./,"\/\/"), {:verify => false, :follow_redirects => true, :timeout => 5, headers: {"User-Agent" => ua}})
            rescue OpenSSL::SSL::SSLError, HTTParty::RedirectionTooDeep, Net::OpenTimeout
                RakeHelper::rputs "SSL error encountered, trying HTTP" if level > 1
                tmp_response = HTTParty.get(website_url.sub(/^https/,"http"), {:verify => false, :follow_redirects => true, :timeout => 5, headers: {"User-Agent" => ua}})
            end
        rescue
                
        end
        
        begin
            tmp_response.blank? # seems to be the only way around UTF-8 Errors....! 
        rescue # seems to be the only way around UTF-8 Errors....!
            tmp_response = '' 
        end

        if tmp_response.present?
            response = tmp_response 
            RakeHelper::yputs("Detected different website and shop CMS!", "!!") if level > 0
            intel[:shop_url] = intel[:url]
            intel[:url] = response.request.last_uri.to_s.gsub(/(https?:\/\/[^\/\?#]*).*/,'\1')
        end
    end

    tests = {
        /([a-zA-Z0-9]*)\.securewinemerchant\.com/ => { :competitor => 'simplyCMS', :shop_url => 'https://\1.securewinemerchant.com'},
        /([a-zA-Z0-9]*)\.orderport\.net/ => { :competitor => 'OrderPort', :shop_url => 'https://\1.orderport.net'},
        /\?fuseaction/                      => { :competitor => 'eCellar' },
        /vin65\.com|winedirect\.com/        => { :competitor => 'WineDirect' },
        /\/cruclub\//                       => { :competitor => 'cruio' },
        /(wp99234|subscribility)/           => { :competitor => 'Troly' },
        /\/(wp-content|wp-login)\//         => { :website_cms => 'WordPress' },
        /cdn\.shopify\.com\//               => { :website_cms => 'shopify' },
        /cdn\d+\.bigcommerce\.com\//        => { :website_cms => 'BigCommerce' },
        /www\.web\.com/                     => { :website_cms => 'Custom - Web.com' },
        /Muse\.Assert\.fail|data-muse-uid/  => { :website_cms => 'Adobe Muse' },
        /cdn\.nexternal\.com\//             => { :competitor => 'Nexternal' },
        /static\d+\.squarespace\.com\//     => { :website_cms => 'Squarespace' },
        /www\.weebly\.com/                  => { :website_cms => 'Weebly' },
        /platform\.vinespring\.com/         => { :competitor => 'VineSpring' },
        /\.xudle\.(com|min)/                => { :competitor => 'Xudle' },
        /\.google-analytics\.com\/analytics\.js/ => { :ga => 'true' },
        /_gat\._getTracker\("([^"]*)"\)/    => { :ga => '\1' },
        /instagram\.com\/([^\/\"]*)/        => { :insta => 'https://instagram.com/\1' },
        /twitter\.com\/([^\/\"]*)/          => { :tw => 'https://twitter.com/\1' },
        /(fb\.com|facebook\.com)\/([^"]*)/  => { :fb => 'https://fb.com/\2' },
    }
    
    tests.each do |t, new_intel|
        RakeHelper::pputs "Testing for regexp #{t}" if level > 2
        if (match = response.match(t)).present?
            new_intel.each do |k,v|
                intel[k] = match[0].sub(t,v)
                #intel = intel.merge(new_intel)
            end
        end
    end

    #intel[:website_cms] = intel[:competitor] if intel[:website_cms].blank?

    return intel
end

session=add_website_intel_to_sheet 
get_website_intel(domain)

def is_wordpress(website)
    website = "http://#{website}" unless website.match(/^http/)
    begin
        response = HTTParty.get("#{website}/wp-login.php", {:verify => false, :follow_redirects => true, :timeout => 5})
    rescue
        return false
    end
    return response.code == 200
end

$agents = nil
def find_agent(id='', fname='', email='')

    if $agents.blank?
        $agents = ac_get("user_list",{"ids"=>"all"})
    end

    fname = fname.split(' ').first if fname.match(/ /)

    $agents.each do |k,x|
        if x.class == Hash && x["id"].present? && (x["id"] == id || x["email"] == email || x["first_name"] == fname || x["username"] == fname.downcase)
            return x;
        end
    end
    return nil;
end


$stages=nil
def find_stage(id)
	if $stages.blank?
		$stages=ac_get('deal_stage_list', {'filters[pipeline]' => '1'})
		$stages.delete("result_code")
		$stages.delete("result_message")
		$stages.delete("result_output")
	end

	stage=$stages.select{ |k,v| v["id"] == id.to_s}

	return stage ? stage.first[1]["title"] : stage
end

# finds a custom field by name (ie, personalisation tag) on given AC contact. returns nil when not found
def find_in_ac_contact_fields(ac_contact,field)
    
    field = field.upcase
    field = "%" + field + "%" if field[0] != "%"

    return ac_contact["fields"].select{ |k,v| v["tag"] == field}.first[1]["val"]
end

def import_new_tags doc_name, rand_sleep
    
    RakeHelper::gputs "Loading #{doc_name} gsheet.."
    
    session = RakeHelper::init_google_session 53339

    wsheet = RakeHelper::init_google_worksheet nil, doc_name, session


    columns=Hash[(0...wsheet.rows[0].size).zip wsheet.rows[0]]
    email_col=(RakeHelper::pick_from_array(columns, "What column are EMAILS stored in?").to_i + 1);
    new_tag_col=(RakeHelper::pick_from_array(columns, "What column are NEW TAGS stored in?").to_i + 1);
    acct_col=(RakeHelper::pick_from_array(columns, "What column are ACCOUNT MANAGERS stored in?").to_i + 1);

    i=2 #skip first row (header)
    while i <= wsheet.max_rows do

        if (wsheet[i,email_col].present?)
        
            new_tags_updates = []
            
            ac_contact = ac_get('contact_view_email', {"email" => wsheet[i,email_col]})
            new_tags = wsheet[i,new_tag_col]
            new_tags.split(',').each do |t|
                if !ac_contact["tags"].include?(t)
                    new_tags_updates << t
                end
            end
            if new_tags_updates.present?
                contact_updates = {}
                contact_updates["id"] = ac_contact["id"]
                contact_updates["overwrite"] = "0" # IMPORTANT!!!! 
                contact_updates["tags"] = (ac_contact["tags"] + new_tags_updates).join(',')
                ac_post("contact_edit", contact_updates)
                RakeHelper::pputs "Processing #{wsheet[i,email_col]} (https://troly.activehosted.com/app/contacts/" + ac_contact['id'] + ")"
            else
                RakeHelper::rputs "No new tags for #{wsheet[i,email_col]} (https://troly.activehosted.com/app/contacts/" + ac_contact['id'] + ")"
            end

            ac_deal = ac_get_deal({ 'filters[pipeline]' => '1', 'filters[contactid]' => ac_contact['id'], 'status' => '0' });
            agent = find_agent(nil,wsheet[i,acct_col].to_s)

            if ac_deal.blank?
                RakeHelper::rputs "Deal missing for #{wsheet[i,email_col]} (https://troly.activehosted.com/app/contacts/" + ac_contact['id'] + ")"
            elsif agent.blank?
                RakeHelper::rputs "Agent not found #{wsheet[i,acct_col]} (https://troly.activehosted.com/app/contacts/" + ac_contact['id'] + ")"
            elsif (agent["id"] != ac_deal["owner"])
                RakeHelper::pputs "Updating agent for deal #{ac_deal['id']} to #{agent["first_name"]}"
                ac_post('deal_edit',{'id' => ac_deal['id'],'userid'=>agent["id"]})
            end
        end
        
        i=i+1
        
        sleep(rand(rand_sleep)) if rand_sleep.present?
    end

end
import_new_tags 'Jules AC Call Worksheet', 2


def delete_deals

    page=1
    loop do

        res=ac_get('contact_list', {'filters[tagname]' => 'DELETE_DEAL', 'page' => page});
        res.delete("result_code")
        res.delete("result_message")
        res.delete("result_output")

        res.keys.each do |k|
            ac_contact = res[k]
            ac_deal = ac_get_deal({ 'filters[pipeline]' => '1', 'filters[contactid]' => ac_contact['id'], 'status' => '0' });

            if ac_deal.blank?
                RakeHelper::rputs "No Deal for contact https://troly.activehosted.com/app/contacts/" + ac_contact['id']
            else
                RakeHelper::gputs "Deleting Deal https://troly.activehosted.com/app/contacts/" + ac_contact['id'] + "/deal/"
            end
            sleep(1);
        end

        page=page+1

    end
end
##
## 
##
## UPDATING EMPTY fields to 'EMPTY'

def force_EMPTY_on_some_fields

    page=1
    loop do
            
        # note - it appears that some contacts are not pulled by this query - needs to be investigated as to why. 
        # todo with list membership?
        res=ac_get('contact_list', {'filters[id_greater]' => '0', 'page' => page});
        res.delete("result_code")
        res.delete("result_message")
        res.delete("result_output")

        if res.blank?
            RakeHelper::rputs "Page #{page} contains no contacts."
            break;
        end

        RakeHelper::yputs  "Processing #{res.count} records from page #{page}."

        res.keys.each do |k|
            ac_contact = res[k]
            contact_updates = {}

            #
            #
            t_user_id = find_in_ac_contact_fields(ac_contact,"TUSERID")
            if t_user_id.blank?
                contact_updates["field[%TUSERID%,0]"] = 'EMPTY'
            end

            #
            #
            t_company_id = find_in_ac_contact_fields(ac_contact,"TCOMPANYID")
            if t_company_id.blank?
                contact_updates["field[%TCOMPANYID%,0]"] = 'EMPTY'
            end

            #
            #
            gd_plan_key = find_in_ac_contact_fields(ac_contact,"GDPLANKEY")

            if gd_plan_key.blank?
                contact_updates["field[%GDPLANKEY%,0]"] = 'EMPTY'
            end

            #
            #
            gd_workspace_key = find_in_ac_contact_fields(ac_contact,"GDWORKSPACEKEY")
            if gd_workspace_key.blank?
                contact_updates["field[%GDWORKSPACEKEY%,0]"] = 'EMPTY'
            end

            if contact_updates.present?
                contact_updates["id"] = ac_contact["id"]
                contact_updates["overwrite"] = "0" # IMPORTANT!!!! 
                ac_post("contact_edit", contact_updates)
                RakeHelper::gputs "UPDATING https://troly.activehosted.com/app/contacts/" + ac_contact["id"]
            else
                RakeHelper::gputs "No updates to https://troly.activehosted.com/app/contacts/" + ac_contact["id"]
            end
        end

        page=page+1
    end
end




##
##





def deal_sync_w_gsheet(doc_name,sheet_name,rand_sleep=3)

    RakeHelper::gputs "Loading #{doc_name} gsheet.."
    session = RakeHelper::init_google_session 53339
    wsheet = RakeHelper::init_google_worksheet sheet_name, doc_name, session


    columns=Hash[(0...wsheet.rows[0].size).zip wsheet.rows[0]]
    acct_col=get_col(columns, "Where are the account managers stored in?", "ACCOUNT");

    ## Update all deals owner and contacts based on changes

    i=2 #skip first row (header)
    deals_rows = {} #stores the deal ids and associated row where it's stored, if found.
    RakeHelper::gputs "Reading rows from #{sheet_name}.. "
    while i <= wsheet.max_rows do
	   print "."
	   deal_id = wsheet[i,1]

    	if deal_id.present?

    		deals_rows[deal_id] = i;
if false
    		ac_deal = ac_post('deal_get',{'id' => deal_id})
    		agent = find_agent(nil,wsheet[i,acct_col].to_s)

    		if (agent.present? && agent["id"] != ac_deal["owner"])
    			RakeHelper::yputs "Updating agent for deal #{deal_id} to #{agent["first_name"]}"
    			ac_post('deal_edit',{'id' => deal_id,'userid'=>agent["id"]})

                sleep(rand(rand_sleep)) if rand_sleep.present?
    		end
end
    	end
    	i=i+1
    end

    # download deals and update sheet

    RakeHelper::gputs "Processing all deals from AC into #{sheet_name}.. "

    page=1
    loop do
    	res=ac_get('deal_list', {'filters[pipeline]' => '1', 'page' => page})
    	if res["deals"].blank?
    		RakeHelper::rputs "Page #{page} contains no deals."
    		break;
    	end

    	RakeHelper::yputs  "Processing #{res["deals"].count} from page #{page}."

    	res["deals"].each do |deal|

    		ac_deal = ac_post('deal_get',{'id' => deal["id"]})
    		agent = find_agent(ac_deal["owner"])
    		ac_contact = ac_get('contact_view_email', {"email" => deal["contact_email"]})

    		row = deals_rows[deal["id"]]
    		if row.present?
    			RakeHelper::pputs "Deal #{deal['id']} found on row #{row}. Updating"
    		else
    			row = wsheet.max_rows+1
    			RakeHelper::pputs "Deal #{deal['id']} NOT found. Adding at row #{row}."
    		end

    		wsheet[row,1] = deal["id"]
    		wsheet[row,2] = ac_contact["id"]
    		wsheet[row,3] = '=HYPERLINK("https://troly.activehosted.com/app/contacts/" & B'+row.to_s+', "Edit " & D'+row.to_s+')'
    		wsheet[row,4] = ac_contact["first_name"]
    		wsheet[row,5] = ac_contact["orgname"]
    		wsheet[row,6] = ac_contact["phone"]
    		wsheet[row,7] = ac_contact["fields"].select{ |k,v| v["tag"] == "%TCOMPANYCREATEDAT%"}.first[1]["val"]

    		gd_plan_key = ac_contact["fields"].select{ |k,v| v["tag"] == "%GDPLANKEY%"}.first[1]["val"]
    		wsheet[row,9] = (gd_plan_key.present? && !gd_plan_key.blank?) ? '=HYPERLINK("https://docs.google.com/document/d/'+gd_plan_key+'", "'+gd_plan_key+'")' : ''

    		#wsheet[row,10] = ac_contact["fields"].select{ |k,v| v["tag"] == "%BESTCONTACTTIME%"}.first[1]["val"]
    		wsheet[row,10] = ac_contact["email"]
    		wsheet[row,11] = agent["first_name"]

    		wsheet[row,20] = find_stage(ac_deal["stage"])
            wsheet[row,23] = ac_contact["tags"].join(", ")

            wsheet[row,26] = ac_contact["actions"].first["text"] + " (" + ac_contact["actions"].first["tstamp"] + ")"
            wsheet[row,27] = ac_contact["fields"].select{ |k,v| v["tag"] == "%TCOMPANYID%"}.first[1]["val"]
            wsheet[row,28] = ac_contact["fields"].select{ |k,v| v["tag"] == "%TMONTHLYSALES%"}.first[1]["val"]
            wsheet[row,29] = ac_contact["fields"].select{ |k,v| v["tag"] == "%T3MONTHLYSALES%"}.first[1]["val"]
            wsheet[row,30] = ac_contact["fields"].select{ |k,v| v["tag"] == "%T6MONTHLYSALES%"}.first[1]["val"]

    		wsheet.save
    		wsheet.reload

    		deals_rows[deal["id"]]=row

            sleep(rand(rand_sleep)) if rand_sleep.present?

    	end
    	page=page+1
    end
end;


deal_sync_w_gsheet 'Jules AC Call Worksheet','Master Call Sheet NEW', 0











def insert_deal_stage(doc_name,sheet_name)

    session = RakeHelper::init_google_session
    wsheet = RakeHelper::init_google_worksheet sheet_name, doc_name, session

    columns=Hash[(0...wsheet.rows[0].size).zip wsheet.rows[0]]
    email_col=(RakeHelper::pick_from_array(columns, "What column are EMAILS stored in?").to_i + 1);
    stage_col=(RakeHelper::pick_from_array(columns, "What column should STATUS be stored in?").to_i + 1);

    page=1
    loop do
        res=ac_get('deal_list', {'filters[pipeline]' => '1', 'page' => page})
        if res["deals"].blank?
            RakeHelper::rputs "Page #{page} contains no deals."
            break;
        end

        RakeHelper::yputs  "Processing #{res["deals"].count} from page #{page}."

        res["deals"].each do |deal|
            RakeHelper::pputs "Looking for #{deal["contact_email"]}"
            i=2
            ac_deal = nil
            while i <= wsheet.max_rows do
                if wsheet[i,email_col] == deal["contact_email"]
                    ac_deal = ac_post('deal_get',{'id' => deal["id"]}) if ac_deal.blank?
                    wsheet[i,stage_col] = find_stage(ac_deal['stage'])
                    RakeHelper::gputs  "#{deal["contact_email"]} at row #{i} was marked as #{wsheet[i,stage_col]}."
                    i = wsheet.max_rows
                end
                i=i+1
            end
        end
        wsheet.save
        page=page+1
    end

end

insert_deal_stage ('Jules AC Call Worksheet','export (8)')



doc_name = 'Jules AC Call Worksheet'
sheet_name = 'export (8)'

RakeHelper::gputs "Loading #{doc_name} gsheet.."
session = RakeHelper::init_google_session
wsheet = RakeHelper::init_google_worksheet sheet_name, doc_name, session

columns=Hash[(0...wsheet.rows[0].size).zip wsheet.rows[0]]
email_col=(RakeHelper::pick_from_array(columns, "What column are EMAILS stored in?").to_i + 1);
co_col=(RakeHelper::pick_from_array(columns, "What column are COMPANY IDs stored in?").to_i + 1);
plan_col=(RakeHelper::pick_from_array(columns, "What column are GD_PLAN_KEYs stored in?").to_i + 1);
wspace_col=(RakeHelper::pick_from_array(columns, "What column are GD_WORKSPACE_KEYs stored in?").to_i + 1);
action_col=(RakeHelper::pick_from_array(columns, "What column are ACTIONS stored in?").to_i + 1);
results_col=(RakeHelper::pick_from_array(columns, "What column should ACTIONS RESULTS be stored in?").to_i + 1);
website_col=(RakeHelper::pick_from_array(columns, "What column are WEBSITES stored in?").to_i + 1);

wsheet.reload
i=2
while i <= wsheet.max_rows do

    next if wsheet[i,email_col].blank?

    contact_updates = {}
    results = (wsheet[i,results_col] || '').split("\n")

    ac_contact = ac_get('contact_view_email', {"email" => wsheet[i,email_col]})
    ac_deal = ac_get_deal({ 'filters[pipeline]' => '1', 'filters[contactid]' => ac_contact['id'], 'status' => '0' })

    RakeHelper::pputs "Retrieved #{ac_contact['email']} with deal #{ac_deal ? ac_deal['id'] : 'nil'}"

    { 't_company_id' => co_col, 'gd_plan_key' => plan_col, 'gd_workspace_key' => wspace_col }.each do |k,col|
        field = k.gsub(/_/,'').upcase

        old_key = ac_contact["fields"].select{ |k,v| v["tag"] == "%"+field+"%"}.first[1]["val"]
        if (wsheet[i,col].present? && old_key != wsheet[i,col])
            contact_updates["field[%"+field+"%,0]"] = wsheet[i,col]
            results << "#{k}: updated to #{wsheet[i,col]}"
        elsif old_key.blank?
            contact_updates["field[%"+field+"%,0]"] = 'EMPTY'
            results << "#{k}: updated to EMPTY"
        end
    end

    contact_updates["tags"] = ac_contact["tags"] || []

    wsheet[i,action_col].gsub(/ /,'').split(',').each do |action|

        t = nil
        new_stage = nil
    
        case action
    
        when 'SETUP_INCOMPLETE'

            t = 'BEGINNER w SETUP_INCOMPLETE (Account Created)'
            new_stage = '2'

        when 'BACK_TO_PROSPECTS' #227

            t = 'BEGINNER w FORM_NOT_FILLED (Account Created)'
            new_stage = '1'

        when 'LEAVING'

            t = 'LEAVING'
            if (ac_deal.present?)
                ac_post("deal_edit",{"id" => ac_deal["id"],"userid"=>"1"})
            end

        when 'DELETE_DEAL'

            t = 'DELETE_DEAL'
            if ac_deal.present?
                ac_post('deal_delete',{"id"=>ac_deal["id"]})
                results << "deal_stage: deleted deal #{ac_deal['id']}"
            end

        when 'FAKE'

            t = 'FAKE'
            
            if ac_deal.present?
                ac_post('deal_delete',{"id"=>ac_deal["id"]})
                results << "deal_stage: deleted deal #{ac_deal['id']}"
            end

        when 'BACK_TO_QUALIFIEDS' #15

            t = 'BEGINNER w PLAN_NOT_DISCUSSED (Account Created)'
            new_stage = '3'

        else

            t = action
        end

        if t.present? && !ac_contact["tags"].include?(t)
            contact_updates["tags"] << t
            results << 'tag: added '+t
        end

        if ac_deal.present? && new_stage.present? && ac_deal["stage"] != new_stage
            ac_post("deal_edit",{"id" => ac_deal["id"],"stage" => new_stage})
            results << "deal_stage: changed to " + $stages.select{ |k,v| v["id"] == new_stage}.first[1]["title"]
        end

    end

    if wsheet[i,website_col].present?
        if !ac_contact["tags"].include?('Wordpress ✓') && !ac_contact["tags"].include?('Wordpress ✖')
            t = 'Wordpress ' + (is_wordpress(wsheet[i,website_col]) ? '✓' : '✖')
            contact_updates["tags"] << t
            results << 'tag: added '+t
        end
    end

    if contact_updates.present?
        contact_updates["id"] = ac_contact["id"]
        contact_updates["overwrite"] = "0"
        contact_updates["tags"] = contact_updates["tags"].join(',') if contact_updates["tags"].present?
        ac_post("contact_edit", contact_updates)
    end

    wsheet[i,results_col] = results.join("\n")
    wsheet.save
    i=i+1
end;





































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
