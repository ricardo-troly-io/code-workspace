require 'net/http'
require 'nokogiri'

#
# Extract Australia post last update on shipments. For some reason the tracking code 
# has to be taken out of the email sent... bug has been raised #393
Shipment.for_company(10044).where(:ship_carrier_pref => 'Auspost').where(:created_at => 2.months.ago..Time.now).each do |s|

  email = s.customer.emails.where(:template_name => 'shipment_dispatch').last
  if email.blank?
    puts "Shipment #{s.id} doesn't have an email ??"
  else
    tracking_code_emailed = s.customer.emails.where(:template_name => 'shipment_dispatch').last.options[:vars][:tracking_number]

    #url = URI.parse("http://auspost.com.au/track/track.html?id=#{s.tracking_code}")
    #url = URI.parse("http://auspost.com.au/track/track.html?id=#{tracking_code_emailed}")
    #url = URI.parse("https://digitalapi.auspost.com.au/track/v3/search?q=#{tracking_code_emailed}")
    req = Net::HTTP::Get.new(url.to_s)
    req.basic_auth "prod_trackapi","Welcome@123"
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }

    doc = Nokogiri::HTML(res.body)

    if doc.at_css('.ed-details-row.bolder').blank?
      emailed = s.customer.emails.where(:template_name => 'shipment_dispatch').last.options[:vars][:tracking_number]
      puts "Shipment #{s.to_s} doesn't have a status update ??\t#{url.to_s}"
    else
      last_date = doc.at_css('.ed-details-row.bolder').at_css('.ed-date p').text.strip
      last_update = doc.at_css('.ed-details-row.bolder').at_css('.ed-activity p').text.strip
      last_location = doc.at_css('.ed-details-row.bolder').at_css('.ed-location p').text.strip

      puts "#{s.customer.to_s}\t#{s.customer.contact_phone}\t#{s.customer.email}\t#{tracking_code_emailed}\t#{url.to_s}\t#{last_date}\t#{last_update}\t#{last_location}"
    end
  end
end


Shipment.for_company(10044).where(:ship_carrier_pref => 'Auspost').where(:created_at => 1.months.ago..Time.now).each do |s|
  if s.tracking_code.blank?
    puts "#{s.name} has no tracking code"
  else
    res = track(s.tracking_code)
    puts "#{s.customer.to_s}\t#{s.customer.contact_phone}\t#{s.customer.email}\t#{s.tracking_code}\t#{res}"
  end
  sleep(Random.rand(10))
end


def track(code)
  #puts "Tracking: of #{code}"
  body = ''
  url = URI.parse("https://digitalapi.auspost.com.au/track/v3/search?q=#{code}")

  Net::HTTP.start(url.host, url.port,
    :use_ssl => url.scheme == 'https', 
    :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|

    request = Net::HTTP::Get.new url
    request.basic_auth 'prod_trackapi', 'Welcome@123'

    response = http.request request # Net::HTTPResponse object
    begin
      body = JSON.parse(response.body)["QueryTrackEventsResponse"]["TrackingResults"][0]["Consignment"]["Articles"][0]["Events"].first
      return "#{body['Status']} to #{body['Location']} on #{body['EventDateTime']}"
    rescue
      puts "ERRO:#{code}"
      puts body
    end
  end
  return ''
end
#
#
Shipment.for_company(10044).where.not(:tracking_code => ['',nil],:created_at => 2.months.ago..Time.now).each do |s|

  email = s.customer.emails.where(:template_name => 'shipment_dispatch').last
  if email.blank?
    #puts "Shipment #{s.id} doesn't have an email ??"
  else
    tracking_code_emailed = s.customer.emails.where(:template_name => 'shipment_dispatch').last.options[:vars][:tracking_number]
    puts "s.id: #{s.id}, s.tracking_code: #{s.tracking_code}, emailed: #{tracking_code_emailed}"
  end
end




Net::HTTP.start(url.host, url.port,
  :use_ssl => url.scheme == 'https', 
  :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|

  request = Net::HTTP::Get.new url
  request.basic_auth 'prod_trackapi', 'Welcome@123'

  response = http.request request # Net::HTTPResponse object

  puts response
  puts response.body
end