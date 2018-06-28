# header => 'Basic amFtZXNAdHJvbHkuaW86ckR1LTVtMy1MOUctWFlr'

cats = JSON.parse(HTTParty.get('https://troly.kayako.com/api/v1/categories.json?limit=1000', {:headers => {'Content-Type': 'application/json', 'Authorization' => 'Basic amFtZXNAdHJvbHkuaW86ckR1LTVtMy1MOUctWFlr'}}).response.body);
cids = cats["data"].map{|a| a["id"]};

sects = JSON.parse(HTTParty.get("https://troly.kayako.com/api/v1/sections.json?category_ids=#{cids.join(',')}&limit=300", {:headers => {'Content-Type': 'application/json', 'Authorization' => 'Basic amFtZXNAdHJvbHkuaW86ckR1LTVtMy1MOUctWFlr'}}).response.body);
sids = sects["data"].map{|a| a["id"]}.sort!;

article_ids = [];
sids.each do |ss|
    arts = JSON.parse(HTTParty.get("https://troly.kayako.com/api/v1/articles.json?section_id=#{ss}&limit=300", {:headers => {'Content-Type': 'application/json', 'Authorization' => 'Basic amFtZXNAdHJvbHkuaW86ckR1LTVtMy1MOUctWFlr'}}).response.body)
    arts["data"].each do |datum|
        datum["titles"].each do |tt|
            titles = JSON.parse(HTTParty.get("https://troly.kayako.com/api/v1/locale/fields/#{tt['id']}.json", {:headers => {'Content-Type': 'application/json', 'Authorization' => 'Basic amFtZXNAdHJvbHkuaW86ckR1LTVtMy1MOUctWFlr'}}).response.body)
            article_ids << {
                :id => datum["id"],
                :status => datum["status"],
                :title => titles["data"]["translation"],
                :views =>  datum["views"],
                :upcount => datum["upvote_count"],
                :downcount => datum["downvote_count"]
            }
        end
    end
end;

article_ids.sort_by!{|a| a[:id]};

article_ids.each do |art|
    puts [art[:title], art[:status], art[:views], art[:upcount], art[:downcount], "https://troly.kayako.com/articles/#{art[:id]}"].join(',')
end;

channels =JSON.parse(HTTParty.get("https://troly.kayako.com/api/v1/insights/cases/channel.json?start_at=2018-01-01T00:00:00.000Z&end_at=2018-01-31T23:59:59.000Z&interval=MONTH", {:headers => {'Content-Type': 'application/json', 'Authorization' => 'Basic amFtZXNAdHJvbHkuaW86ckR1LTVtMy1MOUctWFlr'}}).response.body);
channels["data"]["channel_series"].each do |chan|
    puts [chan["channel"].titlecase, chan["series"]["data"].sum].join(',')
end

metrics = JSON.parse(HTTParty.get("https://troly.kayako.com/api/v1/insights/cases/metrics?start_at=2018-01-01T00%3A00%3A00.000Z&end_at=2018-01-30T23%3A59%3A59.999Z&interval=MONTH&include=*", {:headers => {'Content-Type': 'application/json', 'Authorization' => 'Basic amFtZXNAdHJvbHkuaW86ckR1LTVtMy1MOUctWFlr'}}).response.body);
metrics["data"]["metric"].each do |datum|
    puts [datum["name"], datum["value"]].join(',')
end;


cases = JSON.parse(HTTParty.get("https://troly.kayako.com/api/v1/cases.json?start_time=2018-01-01T00:00:00.000Z&end_at=2018-01-31T23:59:59.000Z&interval=MONTH&limit=10000", {:headers => {'Content-Type': 'application/json', 'Authorization' => 'Basic amFtZXNAdHJvbHkuaW86ckR1LTVtMy1MOUctWFlr'}}).response.body);
cases_ids = cases["data"].map{|a| a["id"]}.sort;
tags = {}
cases_ids.each do |datum|
    case_req = JSON.parse(HTTParty.get("https://troly.kayako.com/api/v1/cases/#{datum}/tags.json?start_time=2018-01-01T00:00:00.000Z&end_at=2018-01-31T23:59:59.000Z&interval=MONTH&limit=10000", {:headers => {'Content-Type': 'application/json', 'Authorization' => 'Basic amFtZXNAdHJvbHkuaW86ckR1LTVtMy1MOUctWFlr'}}).response.body);
    case_req["data"].each do |datum_tag|
        tags[datum_tag['name']] ||= 0
        tags[datum_tag['name']] += 1
    end
end;

outside = 0
cases["data"].each do |datum|
    t = Time.parse(datum["created_at"])
    outside += 1 if t.hour < 9 || t.hour > 18
end;







def download_images(urls,destination)

    urls.each do |img|
        img_parts = img.split("/")
        Dir.mkdir(destination) unless File.exists?(destination)

        if !File.exists?("#{destination}/#{img_parts.last}.png")
            open("#{destination}/#{img_parts.last}.png", 'wb') do |file| 
                file << HTTParty.get(img, :verify => false).response.body; 
            end
        end
    end
end

require 'open-uri'
require 'json'
require 'httparty'
reg_article = /<article[^>]*>(.*)<\/article>/mi
reg_script = /<script(.*)script>/mi
reg_src = /src="([^"]*)"/mi

values_to_remove=['nofollow','display--heading','display--description','dropzone-previews','dz-preview-container','article__content','color--texthead','u-mbottombig','dz-area dz-area--large','u-muted','u-clickable','u-hidden','article__vote__options','article__vote__tip',"article__content','color--texthead','u-mbottombig", 'fr-dib','fr-draggable', "dz-area','dz-area--large','u-muted','u-clickable','u-hidden", "dz-message", "button','u-textsmall','u-inlineblock u-mright", "dz-area__msg", "article__tags','u-mtopbig','u-mbottombig", "text-core','u-mbottom','js-tags", "u-hidden", "u-mtop','u-mbottomsmall','u-textregular", "textfield','textfield--tags", "u-clear','color--textpale", "article__vote','u-textcenter','u-mtopxbig','u-mbottomxbig", "article__vote__options", "u-inlineblock','u-mright','u-vmiddle", "article__vote__option','u-inlineblock','u-clickable','js-vote-option", "article__vote__tip", "icon icon-thumbs-up", "article__vote__option','u-inlineblock','u-clickable','js-vote-option", "article__vote__tip", "icon icon-thumbs-down", "article__vote__msg", "pagination"].uniq
empty_attributes_to_remove=['id','class','alt','rel']
empty_tags_to_remove=['div','p','span']

(1..175).each do |i|
    url = "https://troly.kayako.com/api/v1/articles/#{i}";
    puts url
    sleep(rand(5));
    meta = JSON.parse(HTTParty.get(url, {:headers => {'Content-Type': 'application/json', 'Authorization' => 'Basic amFtZXNAdHJvbHkuaW86ckR1LTVtMy1MOUctWFlr'}}).response.body);
    next if meta["status"] == 404

    html_url = meta["data"]["helpcenter_url"]

    html = HTTParty.get(html_url, :verify => false ).parsed_response

    article = html.match(reg_article)
    next if article == nil
    article = article[1]

    article.gsub!(reg_script,"")

    values_to_remove.each do |rem|
        article.gsub!(Regexp.new(rem + "\s?"),"")
        article.gsub!(Regexp.new("\s?" + rem),"")
    end
    empty_attributes_to_remove.each do |attr|
        article.gsub!(Regexp.new("\s?" + attr + "=\"\s?\""),"")
        article.gsub!(Regexp.new(attr + "=\"\s?\"\s?"),"")
    end
    empty_tags_to_remove.each do |tag|
        article.gsub!(Regexp.new("<#{tag}>\s*</#{tag}>"),"")
    end
    #article.gsub!(/\s+/,"\s")
    #article.gsub!(/\n+/,"\n")

    images = article.scan(reg_src).flatten

    download_images(images,"images-#{i}")

    File.open(File.join('dump.csv'), 'a') do |f|
        f.puts "#{meta["data"]["slugs"][0]["translation"]}\t#{meta["data"]["keywords"]}\t#{meta["data"]["helpcenter_url"]}\t" + article.rpartition(/<\/p>/).first.gsub(/\t|\r?\n|\r/mi,'') + "</p>\t#{images.join(',')}"
    end
    
end;