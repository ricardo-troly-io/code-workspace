

###
###
###
def debug(str,level=0)
  if level == 0 || $output_level >= level
    puts str
  end
end

def debug_data_item(record)
  label = record.keys.last
  debug(" (".white + record.count.to_s.yellow + ") #{label}: ".white + "#{record[label][0..25]}...".light_blue,1)
end

def debug_data_start(record)
  if $output_level > 0
    debug("  #{record[record.keys.first]}  ".black.on_white,1)
  end
end

def debug_data_end(record)
  
  if $output_level == 0
    debug("  #{record[record.keys.first]}  ".black.on_white + " (".white+ record.keys.size.to_s.yellow + ") data points".white)
  end
end

def cprint(str,positive=true)

  if positive
    str = "\n ⇒ ".yellow + str.white
  else
    str = " ✘ ".yellow + str.red + "\n"
  end

  puts str
  print ' > ' if /\?[\s\n]/.match(str)
end


###
### URL Fetching
###
def fetch(url, req)

  debug("Fetching #{url}".yellow,2)
  
  url = URI.parse(url)

  #Net::HTTP::Get.new(url

  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }

  #if $output_level
  #  File.open('debug.log', 'w+') do |f|  
  #    f.puts "#{url}\n\n#{res.body}"
  #  end
  #end

  return res
end


###
### CSV handling
###
$current_record_ids = []
def record_exists?(id, file)

  if $current_record_ids.size == 0 && File.file?(file)
    CSV.foreach(file, :headers => true) do |r|
      $current_record_ids << r['ID'].to_i
    end
  end

  return $current_record_ids.include?(id)
end

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
        debug(" New CSV HEADER found (#{k})".green,2)
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

  $current_record_ids << data['ID']

end


###
### User Interaction
###

###
## Given a question, will ask (commandline) operator to enter input to match a 
## regular expression as requested.
##
## Should be turned into a gem: http://guides.rubygems.org/make-your-own-gem/
##
## @returns string captured
def stdin_for_regex(regexp, question, default = nil)
  
  value = nil
  
  loop do
    
    cprint(question)
    
    value = STDIN.gets.strip

    value = default if default != nil && value == ''

    break if value != '' && regexp.match(value) != nil

    cprint("Invalid. Try again",false)
    
  end

  return value
end


###
###
###
def pick_from_array(values, question)

  regexp = []
  values.each do |k,v|
    regexp << k
    question << "\n   #{k}: #{v[:label]}"
  end

  return stdin_for_regex(Regexp.new(regexp.join('|')),question)

end
