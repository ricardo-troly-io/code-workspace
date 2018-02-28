require 'HTTParty'

MERCHANT_BASE = 'https://www.wine-searcher.com/merchant/'
PRODUCERS_BASE = 'https://www.wine-searcher.com/biz/producers?s='

PRODUCER_INCREMENT_AMOUNT= 26
#PRODUCER_MAX_COUNT = 61576
PRODUCER_MAX_COUNT = 26

USER_AGENTS = File.readlines('lib/useragents.txt')

##
# Wine Titles has a bot prevent mechanism
# If we encounter the below, we have to abort as they are on to us!
# They also throw out a Google reCaptcha if the IP access the site
# too many times (rate not yet determined)
##
USAGE_VIOLATION_XPATH = '*[@id="colheader"]/div/div/div/div[1]/div/div/h1'

# pricelist_xpath = '//*[@id="content-block"]/div/div/div/div[1]/div/div[2]'
# services_xpath = '//*[@id="content-block"]/div/div/div/div[1]/div/div[4]'
# address_info_xpath = '//*[@id="content-block"]/div/div/div/div[2]/div/div/div[5]/div[2]/ul/li/span[2]/span'

###
# Winescrape engine requirements
###

def block_check record
  if record.css(USAGE_VIOLATION_XPATH).text.strip == 'Usage Violation'
    raise "Usage violation encountered, stopping..."
  end
  
  if record.text.match?("To keep Wine-Searcher running smoothly, we've added some extra security measures to make sure you are a")
    $stderr.puts "Encountered captcha!"
    raise "Encountered captcha!"
  end
end

$WEBSITES[:winesearcher] = {
  :label => "Wine-Searcher",
  :fetch => lambda {|url| puts url; fetch_winesearcher(url)},
  :l1 => {
    :query => PRODUCERS_BASE,
    :loops => (0..PRODUCER_MAX_COUNT).step(PRODUCER_INCREMENT_AMOUNT).map{|a| a},
    :record_split => lambda{|doc| block_check(doc); doc.css('#merchantsearch > tr.wlrwdt')},
    :record_id => lambda{|record|
      
      block_check(record)
      
      link = record.css('td.wlrwdt.wlbdrl.vtop > a')[0].attributes["href"].value.gsub(/.*?(\d{1,6})$/,"\\1").to_i
      
      return link
    }
  },
  :l2 => {
    :subs => false,
    :query => MERCHANT_BASE,
    :record_breakdown => lambda{|doc| record_breakdown_winesearcher(doc)}
  }
  
}

def fetch_winesearcher(url)
  page = nil
  # if type == 'merchant'
  #   page = HTTParty.get("#{MERCHANT_BASE}#{}", { :headers => {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/11.1 Safari/605.1.14'}})
  # end

  page = HTTParty.get(url, { :headers => {'User-Agent': USER_AGENTS.sample}})
  
  return Nokogiri::HTML(page)
end


def record_breakdown_winesearcher doc
#content-block > div > div > div > div.fwidth-block-l-auto > div > div:nth-child(1) > div:nth-child(3) > span
#content-block > div > div > div > div.fwidth-block-l-auto > div > div:nth-child(1) > div:nth-child(3) > span > a
#content-block > div > div > div > div.fwidth-block-l-auto > div > div:nth-child(1) > div:nth-child(4) > span a
  record = {
    'name' => doc.css('//*[@id="content-block"]/div/div/div/div[1]/div/div[1]/h1').text,
    'website' => (doc.css("//a[@rel='nofollow']/@onmouseover")[0].value).sub('this.href=', '').gsub("'",''),
    'email' => '', # need to visit their site
    'wines' => doc.css('//*[@id="content-block"]/div/div/div/div[1]/div/div[2]/div[1]/div[2]/div[2]').text,
    'phone' => doc.css('//*[@id="content-block"]/div/div/div/div[2]/div/div/div[4]/div[3]/ul/li/span[2]/span').text,
    'address' => doc.css('//*[@id="content-block"]/div/div/div/div[2]/div/div/div[4]/div[2]/ul/li/span[2]/span').text,
    'country' => doc.css('//*[@id="content-block"]/div/div/div/div[2]/div/div/div[5]/div[1]/ul/li/span[2]').text,
    'shipping' => doc.css('//*[@id="content-block"]/div/div/div/div[1]/div/div[4]/div/div[1]/div').text,
    'services' => doc.css('//*[@id="content-block"]/div/div/div/div[1]/div/div[4]/div/div[3]').text.sub('Services',''),
    'tags' => doc.css().text,
  }
  
  record['email'] = get_email_from_site(record['website'])
  
  return record
end

def get_email_from_site site
  unless site.match?(/http:\/\/|https:\/\//)
    site = "https://#{site}"
  end
  
  page = nil
  options = {:headers => {'User-Agent': USER_AGENTS.sample, follow_redirects: true}}
  
  begin
    page = HTTParty.get(site, options)
  rescue SocketError
    site.sub!('https', 'http')
    page = (HTTParty.get(site, options) rescue nil)
  rescue HTTParty::RedirectionTooDeep
    page = nil
  end
  
  return '' if page.nil?
  
  doc = Nokogiri::HTML(page)
  
  # We can't do anything if we find an age gate
  return nil if doc.text.match?(/age gate/i)
  
  email = doc.text.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,20}/i).to_s
  
  contact_us = ['contact-us', 'contactus', 'contact', 'about', 'about-us', 'kontact', 'kontact-us'];

  contact_us.each do |path|
    next unless email == ''
    page = HTTParty.get("#{site}/#{path}", {:headers => {'User-Agent': USER_AGENTS.sample}})
    email = doc.text.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,20}/i).to_s
  end if email == ''
  puts "Found email #{email}" if email != ''
  return email
end
