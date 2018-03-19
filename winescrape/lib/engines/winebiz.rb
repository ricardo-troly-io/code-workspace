
$WEBSITES[:winebiz_au] = { 
  
  :label => 'Winebiz Australia',

  #
  # Method used to fetch a url and return the response body. Use this to implement authentication
  :fetch => lambda { |url| fetch_winebiz(url) },
  :l1 => {
    :query => 'http://winetitles.com.au/widonline/wineries/?qs=%s',
    #:loops => ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'],
    :loops => ['w','x','y','z'],
    :record_split => lambda { |doc| doc.css('table.wid-search-results tr') },
    :record_id => lambda { |record| 
      link = record.at_css('td a') 
      if link != nil
        link = link.attributes["href"].value.gsub(/.*?(\d{1,6})$/,"\\1").to_i
      end
      return link
    }
  },
  :l2 => {
    :subs => true,
    :query => 'http://winetitles.com.au/widonline/wineries/details.asp?&crap=%s&ID=%d',
    :record_breakdown => lambda { |doc| record_breakdown_winebiz(doc) }
  }
}

#$WEBSITES[:NZ] => { 
#    :label => 'Winebiz New Zealand', 
  #  :l1 => {
  #    :query => 'http://www.winebiz.com.au/widonline/wineries/?qs=%1s'
  #    :loops => ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
  #  }
  #}

def fetch_winebiz(url)
  
  req = Net::HTTP::Get.new(URI.parse(url), {'User-Agent' => 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'})
  req['Cookie'] = 'widLoginID=georgewrem@nsw.agwa.edu.au;'
  
  res = fetch(url, req)

  doc = Nokogiri::HTML(res.body.gsub(/<p class='wid-details-p1'>\r\n<p>/,"<p class='wid-details-p1'>"))
end

def record_breakdown_winebiz(rec)
  record = {}
  name = rec.at_css('#content2 h3').children.first.text

  record["Record Name"] = name

  debug_data_start(record)

  maps = ['Winery Location','Vineyard Location','Cellar Door Location', 'Location']
  matches = {
    /CEO|Executive/ => "CEO", 
    /Managing|Assistant Manager|Business Manager|General Manager|^Director/ => "Managment", 
    /Production Manager/ => "Prod Mgr", 
    /Chef|Restaurant|Cafe|Café/ => "Restaurant", 
    /Sales/ => "Sales",
    /Event|Function/ => "Events", 
    /Secretary/ => "Board", 
    /Consumer|Customer|Promotion|Visitation|Marketer|Marketing|Brand/ => "Marketing", 
    /Viticultur|Master|Winemak|Vigneron/ => "Winemaker", 
    /Owner|owner|Proprietor|Principal|Partner|License/ => "Owner"
  }

  next_is = ''
  rec.at_css('p.wid-details-p1').children.each do |data|
    next if data.name == "text" && data.content.to_s == "\r\n"
    next if data.name == "br"
    next if data.content.match(/^\s+$/) && data.name != 'script'

    if ['Wine is made off site','Wine is made on site','Wine is made on site, off site'].include?(data.content.strip)
      next_is = 'Production'
    end

    if data.name == "strong" #&& next_is == ''
      next_is = data.children.first.content.gsub(/:\s?$/,'').strip

      if ['Click here to order online'].include?(next_is)
        next_is = ''
      end

    elsif data.name == "script" && maps.include?(next_is) && data.attributes["src"] != nil
      
      # Skip the 'script' tags which have a src element.
      next 

    elsif next_is != ''
      if maps.include?(next_is) && (latLng = data.content.match(/LatLng\((-?[\d\.]*,[\d\.]*)\)/)) != nil
        record[next_is] = latLng[1]
      else
        value = data.content.strip

        matches.keys.each do |k|
          if next_is.match(k) != nil
            new_key = "All #{matches[k]}"
            record[new_key] = '' if record[new_key] == nil
            record[new_key] = "#{record[new_key]}, " if record[new_key].size > 0
            record[new_key] = "#{record[new_key]}#{value} (#{next_is})"
          end
        end
        record[next_is] = value
      end

      debug_data_item(record)

      next_is = ''

    else
      puts "WOT?".red
      puts data
    end
  end

  debug_data_end(record)

  return record
end
