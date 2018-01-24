require 'net/http'
require 'nokogiri'
require 'colorize'
require 'csv'
require 'FileUtils'
require 'json'



# http://www.winebiz.com.au/widonline/wineries/?qs=a

$log_level = 1

def interactive

	puts ""
	puts "     Welcome to Sebs web scraper     ".black.on_white
	puts ""
	
	loop do

		case stdin_for_regex(/^([slhq]{1})$/, "Would you like to (s)crape, some (h)elp, change the (l)og level or just (q)uit? [shlq]")
		
			when 'l'
				str = "Would you like little output (0), a lot more (2), or something in between (1)? Default: 1"
				$log_level = stdin_for_regex(/^([012]{1})$/, str, "No problem").to_i

			when 's'

				done = false
				
				str =  ["Which website should I scrape?","Winebiz [au]","Winebiz [nz]","Wines and Vines [usa]"]
				
				case stdin_for_regex(/^(au|nz|usa)$/, str, "Sweet")

					when 'au'
				
						str =  "What range should I go for? (enter a single letter or 'all')"
						range = stdin_for_regex(/^([a-z]{1}|all)$/, str, "Righto")

						range = 'abcdefghijklmnopqrstuvwxyz' if range == 'all'

						scrape_winebiz range, 'wineries-au.csv', 'au'
						done = true
				
					when 'nz'

						str =  "What range should I go for? (enter a single letter or 'all')"
						range = stdin_for_regex(/^([a-z]{1}|all)$/, str, "Beached as bro")

						range = 'abcdefghijklmnopqrstuvwxyz' if range == 'all'

						scrape_winebiz range, 'wineries-nz.csv', 'nz'
						done = true

					when 'usa'

						str =  "What state should I go for? (enter two letters or 'all')"
						state = stdin_for_regex(/^([A-Z]{2}|all)$/, str, "Yeehah")

						scrape_winesandvines state
						done = true

				end # case

				if done
					puts "All done. Moving on..\n"
				else
					puts "I don't speak cantonese. Let's try that again shall we..\n".red
				end

			when 'h'
				puts "\nRight! Go home, curl up in bed, and read code.\n"
				break

			when 'q'
				puts "\nOk. You're such a quitter!\n"
				break
		
		end # case

	end # loop

end # function


##############
##############
##############
##############


#
# Given a certain url, fetches said url and return the HTML document as a Nokogirl::HTML object
#
def fetch_html(url, request = {}, post = nil)

	url = URI.parse(url)

	puts "Fetching #{url.to_s}".yellow if $log_level >= 2

	ua = {'User-Agent' => 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'}
	if post == nil
		req = Net::HTTP::Get.new(url.to_s, ua)
	else
		req = Net::HTTP::Post.new(url.to_s, ua)
		req.set_form_data(post)
	end
	
	request.keys.each do |k|
		req[k] = request[k]
	end

	res = Net::HTTP.start(url.host, url.port) { |http|
		http.request(req)
	}

	return res.body

end

#
# 
#
def stdin_for_regex(regexp, label, prompt = "", utf = "⇒".yellow)
	
	value = nil
	
	prompt += ". " if prompt != ""
	label = label.join("\n    ") + "\n   " if label.class == Array
	
	loop do
		print " #{utf} #{prompt}#{label} > "
		value = STDIN.gets.strip
			
		break if value != nil && regexp.match(value)

		puts " ✘".red + " Invalid entry. Deep breath.".white + "\n"
		prompt = "Now try again. "
	end

	return value
end

def validate_filename filename
	if File.file?(filename)
		FileUtils.rm(filename) if stdin_for_regex(/[yn]/, "#{filename} already exists, delete it? [yn]") == "y"
	end
	puts "All records to be will be saved to #{filename}"
	$current_record_ids = []
end


#
#
#
def sleep_a_little max_secs = 3
	
	r = rand(max_secs * $log_level)
	print "Sleeping for #{r} seconds" if $log_level >= 2
	r.times do
		print "." if $log_level >= 2
		sleep(0.5)
	end
	puts "" if $log_level >= 2
end


#
#
#
def save_to_csv(data, file, id_column = 'id')

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

	$current_record_ids << data[id_column]

end

##############
##############
##############
##############

def scrape_winesandvines state = 'all', filename = 'wineries-usa.csv'
	
	url_root = 'http://www.winesandvines.com/ms/woms.cfm'
	req = { 'Cookie' => 'CFID=51027021;CFTOKEN=71275111;' }

	puts "Processing WinesAndVines for '#{state}', saving into #{filename}"

	if state == 'all'
		state = ['AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA','HI','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY' ]
	else
		state = [state]
	end

	validate_filename filename

	state.each do |state_abbr|

		puts " > #{state_abbr} < ".black.on_yellow

		post = {'pathName'=>'name','q'=>'a','pathGeo'=>'state','state'=>state_abbr,'btnFind'=>'Search'}

		doc = Nokogiri::HTML(fetch_html(url_root, req, post))

		entity_ids = doc.css('blockquote script').to_s.scan(/entityId\":(\d{2,6})/)

		entity_ids.each do |entityId|

			if record_exists?(entityId[0], filename, 'entityId')
				puts "❯ record already exists; #{entityId[0]}".red
				next
			end

			doc = Nokogiri::HTML(fetch_html("http://www.winesandvines.com/ms/msDetail.cfm?context=winery&listEntityIds=#{entityId[0]}", req))
			entity = doc.css('blockquote script').to_s.scan(/\$scope\.detailResults\s=\s(\{.*\})\s\}/).pop


			data = breakdown_winesandvines entity[0]

			save_to_csv(data, filename, 'entityId')

			sleep_a_little
		end
	end
end

def breakdown_winesandvines rec

	record = JSON.parse(rec)
	record = record['data']

	print " #{record['companyName']} ❯".black.on_white


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

	record['contacts'].each do |c|
		(1..15).each do |i|
			if record["contact-#{i}"] == nil
				record["contact-#{i}"] = c['functionList']
				['fName','lName','email','phone'].each do |att|
					record["contact-#{i} #{att}"] = c[att]
				end
				break
			end
		end

		matches.keys.each do |k|
			if c['functionList'].match(k) != nil
				
				value = "#{c['fName']} #{c['lName']}, #{c['email']}, #{c['phone']}"

				new_key = "All #{matches[k]}"
				record[new_key] = '' if record[new_key] == nil
				record[new_key] = "#{record[new_key]}, " if record[new_key].size > 0
				record[new_key] = "#{record[new_key]}#{value}"
			end
		end
	end
	
	record['contacts'] = record['strCorpHierarchy'] = record['arrCorpHierarchy'] = nil

	puts " (".white + record.keys.size.to_s.yellow + ") data points".white

	return record

end

def scrape_winebiz chars = 'abcdefghijklmnopqrstuvwxyz', filename = 'wineries-au.csv', site= 'au'

	puts "Processing WineBiz - #{site} for '#{chars}', saving into #{filename}"

	validate_filename filename

	url_root = 'http://winetitles.com.au/widonline/wineries/'
	req = { 'Cookie' => 'widLoginID=georgewrem@nsw.agwa.edu.au;' }

	chars.length.times do |i|
		
		if (site == 'nz')
			doc = fetch_html("#{url_root}?Winery_Name=#{chars[i]}", req)
		else
			doc = fetch_html("#{url_root}?qs=#{chars[i]}", req)
		end

		doc = Nokogiri::HTML(doc.gsub(/<p class='wid-details-p1'>\r\n<p>/,"<p class='wid-details-p1'>"))

		if (rows = doc.css('table.wid-search-results tr'))
		
			rows.each do |row|

				link = row.at_css('td a')
				next if link == nil

				record_id = link.attributes["href"].value.gsub(/.*?(\d{1,6})$/,"\\1").to_i

				if record_exists?(record_id, filename, 'ID')
					puts "❯ record already exists; #{record_id}".red
					next
				end

				if site == 'nz'
					doc = fetch_html("#{url_root}#{link.attributes["href"].value}", req)
				else 
					doc = fetch_html("#{url_root}details.asp?ID=#{record_id}", req)
				end

				data = breakdown_winebiz(doc)

				data["URL"] = "#{url_root}#{link.attributes["href"].value}"
				data["ID"] = record_id

				save_to_csv(data, filename, 'ID')
				
				sleep_a_little

			end # each rows
		end #if
		
		puts "\n\nAll records processed for '#{chars[i]}'.\n".black.on_yellow

	end # each chars
	
end

def breakdown_winebiz rec
	
	rec = Nokogiri::HTML(rec) if rec.class == String
	record = {}

	name = rec.at_css('#content2 h3').children.first.text

	print " #{name} ❯".black.on_white

	record["Record Name"] = name

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
			#puts " (".white + record.count.to_s.yellow + ") #{next_is}: ".white + "#{record[next_is][0..15]}...".light_blue
			next_is = ''

		else
			puts "WOT?".red
			puts data
		end
	end

	puts " (".white + record.keys.size.to_s.yellow + ") data points".white

	return record
end

#
#
#
def record_exists? id, file, id_column = 'id'

	if $current_record_ids.size == 0 && File.file?(file)
		CSV.foreach(file, :headers => true) do |r|
			$current_record_ids << r[id_column].to_i
		end
	end

	return $current_record_ids.include?(id.to_i)
end

##############
##############
##############
##############

interactive()

