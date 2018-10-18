Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper

Google::APIClient.logger.level = 2

@api_endpoint = "https://troly.api-us1.com"
@api_token = "f8b7ef441352e9883df8a3bc93f2b86575bb35bf8f52237f0ee34e8f4a12e5f2abaa3efb"
@base_url = @api_endpoint + "/admin/api.php?api_output=json&api_key=" + @api_token + "&"
@headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
@for_real = true

def get_col(columns, question, regex_matches=nil)

    if regex_matches.present?

        match_cols = columns.select{ |k,v| v.match(Regexp.new("^(#{regex_matches})$")) }
        return match_cols.keys.first+1 if match_cols.size == 1

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
    website_col=get_col(columns, "Where is the website URL stored in?","website");
    intel_col=get_col(columns, "Where should we store results in?", "cms");

    i=2 #skip first row (header)
    pending_changes = 0
    last_saved_at = Time.now
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
            timestamp = Time.at(Time.now - last_saved_at).strftime("%M:%S")
            RakeHelper::gputs "Saving #{pending_changes} records (processed in #{timestamp})"
            wsheet.save
            pending_changes = 0
            last_saved_at = Time.now
        end
    end

    if pending_changes > 0
        timestamp = Time.at(Time.now - last_saved_at).strftime("%M:%S")
        RakeHelper::gputs "Saving the last #{pending_changes} records (processed in #{timestamp})"
        wsheet.save
    end

    return [session,wsheet]
end


def get_website_intel(domain, level=0)
    ua = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36'

    domain.gsub!(/^http(s)?:\/\//,"")
    domain.gsub!(/^w{1,3}\./,"")
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
            intel[:website_cms] = 'vinSuite'
            intel[:competitor] = 'vinSuite'
        when /eWinery Solutions/
            intel[:website_cms]  = 'vinSuite (eWinery Solutions)'
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
        /([a-zA-Z0-9]*)\.securewinemerchant\.com/   => { :competitor => 'simplyCMS', :shop_url => 'https://\1.securewinemerchant.com'},
        /([a-zA-Z0-9]*)\.orderport\.net/            => { :competitor => 'OrderPort', :shop_url => 'https://\1.orderport.net'},
        /\?fuseaction/                              => { :competitor => 'eCellar' },
        /vin65\.com|winedirect\.com/                => { :competitor => 'WineDirect' },
        /\/cruclub\//                               => { :competitor => 'cruio' },
        /(wp99234|subscribility)/                   => { :competitor => 'Troly' },
        /\/(wp-content|wp-login)\//                 => { :website_cms => 'WordPress' },
        /cdn\.shopify\.com\//                       => { :website_cms => 'shopify' },
        /cdn\d+\.bigcommerce\.com\//                => { :website_cms => 'BigCommerce' },
        /www\.web\.com/                             => { :website_cms => 'Custom - Web.com' },
        /Muse\.Assert\.fail|data-muse-uid/          => { :website_cms => 'Adobe Muse' },
        /cdn\.nexternal\.com\//                     => { :competitor => 'Nexternal' },
        /static\d+\.squarespace\.com\//             => { :website_cms => 'Squarespace' },
        /www\.weebly\.com/                          => { :website_cms => 'Weebly' },
        /platform\.vinespring\.com/                 => { :competitor => 'VineSpring' },
        /\.xudle\.(com|min)/                        => { :competitor => 'Xudle' },
        /\.google-analytics\.com\/analytics\.js/    => { :ga => 'true' },
        /_gat\._getTracker\(['"]([^"']*)['"]\)/     => { :ga => '\1' },
        /instagram\.com\/([^\/"']*)/                => { :insta => 'https://instagram.com/\1' },
        /twitter\.com\/([^\/'"]*)/                  => { :tw => 'https://twitter.com/\1' },
        /(fb\.com|facebook\.com)\/([^'"]*)/         => { :fb => 'https://fb.com/\2' },
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

add_website_intel_to_sheet