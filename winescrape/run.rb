require 'net/http'
require 'nokogiri'
require 'colorize'
require 'csv'
require 'FileUtils'
require 'io/console'


$WEBSITES = {}
Dir["lib/**/*.rb"].each {|file| load file }

print "\nWelcome!\n"

SITE = $WEBSITES[ARGV[0].to_sym] || $WEBSITES[pick_from_array($WEBSITES,"Which website are you interested in?").to_sym]

$output_level = ARGV[1]

if $output_level.nil?
  if ('y' == stdin_for_regex(/y|n/, "Would you like a verbose output? (y/n)", 'n'))
    $output_level = ('y' == stdin_for_regex(/y|n/, "..and include debug data? (y/n)",'n')) ? 2 : 1
  else
    $output_level ||= 0
  end
end


#sample_size = DEBUG ? stdin_for_regex(/\d/,"How many record to sample? (0 for all)",'0') : 0
filename = SITE[:label].downcase.gsub(/[^a-z0-9]/,"-") + ".csv"

if File.file?(filename) && 'y' == stdin_for_regex(/y|n/, "File ".white + filename.yellow + " already exist. Delete? (y/n)".white, 'n')
  File.delete(filename)
end

print "\nThanks, now, let's scrape :)\n\n"


SITE[:l1][:loops].each do |c|

  ## 
  ## First READ a page full of results, and 
  ## SPLIT on each of the results using css selection and
  ## EXTRACT a record id from a link to the detailed results
  ##

  ## READ ##
  doc = SITE[:fetch].call("#{SITE[:l1][:query]}#{c}" % c)
  #doc = fetch_to_doc("#{url_root}?Winery_Name=#{chars[i]}")

  ## SPLIT ##
  if (rows = SITE[:l1][:record_split].call(doc))
    rows.each do |row|

      ## EXTRACT 1 ##
      record_id = SITE[:l1][:record_id].call(row)
      
      if record_id == nil
        debug("❯ record_id missing".red,0)
        next
      end

      if record_exists?(record_id, filename)
        debug("❯ record already exists; #{record_id}".red)
        sleep(rand(1))
        next
      end

      ##
      ## Then READ the full details page before
      ## 
      url =SITE[:l2][:subs] ? "#{SITE[:l2][:query]}" % [c, record_id] : "#{SITE[:l2][:query]}#{record_id}"

      doc = SITE[:fetch].call(url)
      #doc = fetch_to_doc("http://www.winebiz.com.au/widonline/wineries/details.asp?ID=4590")
      
      data = SITE[:l2][:record_breakdown].call(doc)
      data["URL"] = url
      data["ID"] = record_id
      data["SRC"] = SITE[:label]

      save_to_csv(data, filename)
      
      sleep(rand(3))
      puts ""
    end
  end
  debug("\n\nAll records processed for '#{c}'.\n".black.on_yellow)
  
end

