require 'net/http'
require 'nokogiri'

# http://www.winebiz.com.au/widonline/wineries/?qs=a

chars = 'abcdefghijklmnopqrstuvwxyz'

chars.length.times do |i|
  url = URI.parse("http://www.winebiz.com.au/widonline/wineries/?qs={chars[i]")

  req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }

    doc = Nokogiri::HTML(res.body)
  
  break;

  #if doc.at_css('table.wid-search-results-row.bolder').blank?
end


