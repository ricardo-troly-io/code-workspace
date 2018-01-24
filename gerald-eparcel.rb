urls = ['https://res.cloudinary.com/subscribility-p/image/upload/v1417735516/u0upkkkncfeutxq9tfqa.pdf',
'https://res.cloudinary.com/subscribility-p/image/upload/v1417737902/x3izyii7u0jdh9ovbmty.pdf',
'https://res.cloudinary.com/subscribility-p/image/upload/v1417738904/e0fwe76qqlsfxodjbuts.pdf',
'https://res.cloudinary.com/subscribility-p/image/upload/v1417739228/mpddabrtgoujnh1fjvwj.pdf']


require 'open-uri'

results = []
urls.each do |url|
  puts "loading #{url}".yellow

  io = open(url)
  reader = PDF::Reader.new(io)
  reader.pages.each do |page|

    puts " processing page #{page.number}"

    next_is_to = false
    art_1 = art_2 = to_1 = to_2 = nil

    page.text.split("\n").each do |line|

      next if line.strip.blank?

      if to_1.blank? and next_is_to

        to_1 = line[0..59].strip
        to_2 = line[60..119].strip

        puts "  extracted tos for #{to_1} & #{to_2}".green

        next_is_to = false
        next
      end

      next_is_to = line.match(/DELIVER TO/).present?

      if to_1.present? and (data = line.split(/AP Article Id:\s/)).present? and data.length > 1
        begin
          if data[1][0..30].blank? or data[2][0..30].blank?
          art_1 = data[1][0..30].strip if to_1.present? and data.length > 1
          art_2 = data[2][0..30].strip if to_2.present? and data.length > 2
          puts "  extracted codes for #{art_1} & #{art_2}".green
        rescue
          puts line.red
        end
      end

      if (to_1.present? and art_1.present?)
        art_1 = art_2 = to_1 = to_2 = nil
      end
    end
  end
end
