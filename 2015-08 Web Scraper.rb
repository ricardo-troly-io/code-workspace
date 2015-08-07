require 'net/http'
require 'nokogiri'
require 'colorize'
require 'csv'
require 'FileUtils'
require 'active_support/all'

# 'http://burrundulla.com.au/'

websites = ['http://www.bridgeroadbrewers.com.au']

def web_scraper (urls)
  urls.each do |i|
    single_site_scraper(i)
  end
end

def single_site_scraper (url)

  data = {}

  i = 0
  urls = [url]

  loop do
    doc = fetch_to_doc(urls[i])
    urls = scrape_urls(doc, urls)

    if data['email_1'].blank?
      data = data.merge( email_from_doc(doc, data.select { |x| x =~ /email/ }.count) )
    end

    if data['phone_1'].blank?
      data = data.merge( phone_from_doc(doc, data.select { |x| x =~ /phone/ }.count) )
    end

    # Break loop
    break if ((i += 1) > urls.count-1) || (data['email_1'].present? && data['phone_1'].present?)
  end

  # ran out of urls, or I have emails and phones (or at least one)
  save_to_csv(data, './scraper.csv')

end

def fetch_to_doc(url)
  url = URI.parse(url)
  # puts url.to_s.yellow

  req = Net::HTTP::Get.new(url.to_s, {'User-Agent' => 'Mozilla/5.0 (compatible; Googlebot/2.1; 
                                      +http://www.google.com/bot.html)'})

  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }

  htmlBody = Nokogiri::HTML(res.body)

  return htmlBody
end

def scrape_urls (doc, previousUrls)
  output = []

  foundUrls = doc.scan( /href=["'].*["']/ )

  foundUrls.each do |thisUrl|
    thisUrl[0..5] = ''
    thisUrl[thisUrl.length-1] = ''
    if (!(previousUrls.include? thisUrl))
      output << thisUrl
    end
  end

  return output
end

def email_from_doc (doc, start)

  i = start

  output = {}

  # Perform the scane to a results array
  results = doc.scan( /[:alnum:._-]+@[:alnum:.-_]+\..+/)

  results.each do |str|
    i += 1
    # Look for up to maxCheck emails in the results array
    output["email_#{i}"] = str
  end

  return output
end

def phone_from_doc (doc, start) 
  
  i = start + 1

  output = {}

  # Perform the scane to a results array
  # results = doc.scan ( /^(\([0-9]{3}\)|[0-9]{3}-)[0-9]{3}-[0-9]{4}$/ )
  results = doc.scan ( /^\(?(?:\+?61|0)(?:(?:2\)?[ -]?(?:3[ -]?[38]|[46-9][ -]?[0-9]|5[ -]?[0-35-9])
                      |3\)?(?:4[ -]?[0-57-9]|[57-9][ -]?[0-9]|6[ -]?[1-67])|7\)?[ -]?(?:[2-4][ -]?
                      [0-9]|5[ -]?[2-7]|7[ -]?6)|8\)?[ -]?(?:5[ -]?[1-4]|6[ -]?[0-8]|[7-9][ -]?
                      [0-9]))(?:[ -]?[0-9]){6}|4\)?[ -]?(?:(?:[01][ -]?[0-9]|2[ -]?[0-57-9]
                      |3[ -]?[1-9]|4[ -]?[7-9]|5[ -]?[018])[ -]?[0-9]|3[ -]?0[ -]?[0-5])(?:[ -]?
                      [0-9]){5})$/ )

  results.each do |str|
    i += 1
    # Look for up to maxCheck emails in the results array
    output["phone_#{i}"] = str
  end

  return output
end


# Function to write to csv once 
def save_to_csv(data, file)
  
  if File.file?(file)
    headers = CSV.read(file, :headers => true).first.headers
  else
    headers = data.keys
  end
  
  needs_rewrite = false
  
  if headers != data.keys
    data.keys.each do |k|
      if !headers.include?(k)
        puts " New HEADER found (#{k})".green
        headers << k 
        needs_rewrite = true
      end
    end
  end

  if needs_rewrite
    CSV.open("#{file}.tmp", "ab", :write_headers => true, :headers => headers) do |csv|
      CSV.foreach(file, :headers => true) do |old_record|
        csv << old_record
      end
    end
    FileUtils.move("#{file}.tmp",file,:force => true)
  end

  new_record = []
  headers.each do |h|
    new_record << data[h].to_s
  end

  CSV.open(file, "ab", :write_headers => !File.file?(file), :headers => headers) do |csv|
    csv << new_record
  end

  # $current_record_ids << data['ID']
end

web_scraper (websites)

# def record_breakdown(rec)
#   record = {}
#   name = rec.at_css('#content2 h3').children.first.text
#   print "  #{name}  ".black.on_white

#   record["Record Name"] = name

#   maps = ['Winery Location','Vineyard Location','Cellar Door Location', 'Location']
#   matches = {
#     /CEO|Executive/ => "CEO", 
#     /Managing|Assistant Manager|Business Manager|General Manager|^Director/ => "Managment", 
#     /Production Manager/ => "Prod Mgr", 
#     /Chef|Restaurant|Cafe|Café/ => "Restaurant", 
#     /Sales/ => "Sales",
#     /Event|Function/ => "Events", 
#     /Secretary/ => "Board", 
#     /Consumer|Customer|Promotion|Visitation|Marketer|Marketing|Brand/ => "Marketing", 
#     /Viticultur|Master|Winemak|Vigneron/ => "Winemaker", 
#     /Owner|owner|Proprietor|Principal|Partner|License/ => "Owner"
#   }

#   next_is = ''
#   rec.at_css('p.wid-details-p1').children.each do |data|
#     next if data.name == "text" && data.content.to_s == "\r\n"
#     next if data.name == "br"
#     next if data.content.match(/^\s+$/) && data.name != 'script'

#     if ['Wine is made off site','Wine is made on site','Wine is made on site, off site'].include?(data.content.strip)
#       next_is = 'Production'
#     end

#     if data.name == "strong" #&& next_is == ''
#       next_is = data.children.first.content.gsub(/:\s?$/,'').strip

#       if ['Click here to order online'].include?(next_is)
#         next_is = ''
#       end

#     elsif data.name == "script" && maps.include?(next_is) && data.attributes["src"] != nil
      
#       # Skip the 'script' tags which have a src element.
#       next 

#     elsif next_is != ''
#       if maps.include?(next_is) && (latLng = data.content.match(/LatLng\((-?[\d\.]*,[\d\.]*)\)/)) != nil
#         record[next_is] = latLng[1]
#       else
#         value = data.content.strip

#         matches.keys.each do |k|
#           if next_is.match(k) != nil
#             new_key = "All #{matches[k]}"
#             record[new_key] = '' if record[new_key] == nil
#             record[new_key] = "#{record[new_key]}, " if record[new_key].size > 0
#             record[new_key] = "#{record[new_key]}#{value} (#{next_is})"
#           end
#         end
#         record[next_is] = value
#       end
#       #puts " (".white + record.count.to_s.yellow + ") #{next_is}: ".white + "#{record[next_is][0..15]}...".light_blue
#       next_is = ''

#     else
#       puts "WOT?".red
#       puts data
#     end
#   end

#   puts " (".white + record.keys.size.to_s.yellow + ") data points".white

#   return record
# end

# $current_record_ids = []
# def record_exists?(id, file)

#   if $current_record_ids.size == 0 && File.file?(file)
#     CSV.foreach(file, :headers => true) do |r|
#       $current_record_ids << r['ID'].to_i
#     end
#   end

#   return $current_record_ids.include?(id)
# end




# chars.length.times do |i|
#   doc = fetch_to_doc("#{url_root}?qs=#{chars[i]}")
#   #doc = fetch_to_doc("#{url_root}?Winery_Name=#{chars[i]}")

#   if (rows = doc.css('table.wid-search-results tr'))
#     rows.each do |row|
#       link = row.at_css('td a')
#       next if link == nil

#       record_id = link.attributes["href"].value.gsub(/.*?(\d{1,6})$/,"\\1").to_i

#       if record_exists?(record_id,"#{filename}.csv")
#         puts "❯ record already exists; #{record_id}".red
#         next
#       end

#       doc = fetch_to_doc("#{url_root}#{link.attributes["href"].value}")
#       #doc = fetch_to_doc("http://www.winebiz.com.au/widonline/wineries/details.asp?ID=4590")
      
#       data = record_breakdown(doc)
#       data["URL"] = "#{url_root}#{link.attributes["href"].value}"
#       data["ID"] = record_id

#       save_to_csv(data, "#{filename}.csv")
      
#       sleep=rand(3)
#       loop do
#         print "."
#         sleep(1)
#         break if (sleep -= 1) <= 0
#       end
#       puts ""
#     end
#   end
#   puts "\n\nAll records processed for '#{chars[i]}'.\n".black.on_yellow
  
# end

