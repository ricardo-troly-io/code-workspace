require 'holidays'
require 'colorize'

staffs = {
   "Abraham" =>    { :start => '2013-05-01', :end => '2099-01-01', :dpw => 5, :role => :dev },
   "Atif" =>       { :start => '2011-03-01', :end => '2099-01-01', :dpw => 3, :role => :mgmt },
   "Benjamin" =>   { :start => '2014-05-19', :end => '2099-01-01', :dpw => 5, :role => :mgmt },
   "Craig" =>      { :start => '2012-09-01', :end => '2099-01-01', :dpw => 2, :role => :mgmt },
   "Daniele" =>    { :start => '2013-04-23', :end => '2099-01-01', :dpw => 1, :role => :dev },
   "Daisy" =>      { :start => '2013-11-13', :end => '2099-01-01', :dpw => 5, :role => :dev },
   "Evan" =>       { :start => '2014-05-19', :end => '2099-01-01', :dpw => 5, :role => :dev },
   "Hengdi" =>     { :start => '2012-07-23', :end => '2013-04-30', :dpw => 1, :role => :dev },
   "Jeremie" =>    { :start => '2012-04-20', :end => '2012-09-17', :dpw => 5, :role => :dev },
   "Nicolas" =>    { :start => '2013-01-14', :end => '2013-04-26', :dpw => 5, :role => :dev },
   "Mathieu" =>    { :start => '2012-09-03', :end => '2013-02-28', :dpw => 5, :role => :dev },
   "Karine" =>     { :start => '2013-09-03', :end => '2013-12-13', :dpw => 5, :role => :dev },
   "Vincent" =>    { :start => '2012-09-03', :end => '2013-12-14', :dpw => 5, :role => :dev },
   "Mora" =>       { :start => '2012-08-06', :end => '2099-01-01', :dpw => 2, :role => :mgmt },
   "Nishat" =>     { :start => '2012-07-01', :end => '2014-01-31', :dpw => 3, :role => :dev },
   "Sebastien" =>  { :start => '2011-03-01', :end => '2099-01-01', :dpw => 3, :role => :mgmt }
}

staffs.each do |name,details|
   details[:start] = Date.parse(details[:start])
   details[:end] = Date.parse(details[:end])
   staffs[name] = details
end
activities = {
   :dev => 
      [  { :from => 0, :to => 70, :task => "Development / Research" },
         { :from => 71, :to => 100, :task => "Business Analysis / Documentation" }],
   :mgmt =>
      [  { :from => 0, :to => 70, :task => "Business Analysis / Documentation" },
         { :from => 71, :to => 100, :task => "Product Development / Project Management" }]
}

FY = 14

def day_split()
   hours = rand(4..10)
   result = []
   while hours > 0
      result << rand(1..5)
      hours = hours - result.last
   end
   return result
end

(Date.civil(2000 + FY - 1,7,1)..Date.civil(2000 + FY,6,30)).each do |date|
   if date.holiday?(:au_nsw)
      #puts "#{date} is a holiday, skipping".red
      next
   elsif [0,6].include?(date.wday)
      #puts "#{date} is a weekend, skipping".white
      next
   end

   rnd = rand(5)
   staffs.select { |name,details| details[:start] <= date && details[:end] >= date && details[:dpw] >= rnd }.each do |name,details|
      rnd = rand(100)
      activities[details[:role]].select { |act| act[:from] <= rnd && act[:to] >= rnd }.each do |activity|
         day_split().each do |hours|
            puts "Subscribility\t#{name}\t#{date}\t#{activity[:task]}\t#{hours}"
         end
      end
   end
end