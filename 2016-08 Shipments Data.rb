Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper

ws = init_google_worksheet 'Sheet1'
current_row = 1
## init

ws[current_row,1] = 'source'
ws[current_row,2] = 'destination'
ws[current_row,3] = 'parcels'
ws[current_row,4] = 'month'


#all_sources = Company.where(:id => shipments.pluck(:company_id).uniq).where.not(:postcode => nil).where.not(:postcode => '').pluck(:postcode).uniq;
all_sources = Company.where.not(:postcode => ['',nil]).map{|c| c.postcode[0..1]}.uniq

from = Date.new(2015,7,1)
#to = DateTime.now.beginning_of_month
to = Date.new(2016,6,1)

while (src = all_sources.pop)
	print "\n\nProcessing #{src}xx ".yellow

	cids = Company.where("postcode LIKE :prefix", prefix: "#{src}%").pluck(:id)
	
	from_clean = from
	while (from_clean <= to)
		mth = from_clean.strftime('%B')
		print "(as of #{mth})".yellow

		range = from_clean.beginning_of_month..from_clean.end_of_month

		sql = "SELECT		SUBSTR(delivery_postcode, 1, 2) AS shipments_source, COUNT(id) AS shipments_count 
				 FROM			shipments 
				 WHERE 		delivery_postcode <> '' AND company_id IN (#{cids.to_s[1..-2]}) 
				 		  AND created_at >= '#{range.begin}' AND created_at <= '#{range.end}'
				 GROUP BY 	SUBSTR(delivery_postcode, 1, 2);"

		ActiveRecord::Base.connection.execute(sql).each do |result|
			current_row += 1

			ws[current_row,1] = "#{src}xx"
			ws[current_row,2] = "#{result["shipments_source"]}xx"
			ws[current_row,3] = result["shipments_count"]
			ws[current_row,4] = mth

			if current_row % 50 != 0
				print "."
			else
				print "\nsaving!\n".yellow
				ws.save
			end
		end
	from_clean += 1.month
	end 
end
