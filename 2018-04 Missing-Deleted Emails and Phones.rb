
Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper

session = RakeHelper::init_google_session 53339

# b = 10405
# w = 10390

check = ['phone','email']
#range = Time.new(2018,02,28)..Time.new(2018,03,08)
#range = Time.new(2018,04,18)..Time.new(2018,04,30)
range = Time.new(2017,07,01)..Time.now
stats = { }

# cids = CompanyCustomer.where(:company_id => [b,w]).pluck(:customer_id);
records = Customer.where(:company => Company.active.joins(:integrations).where(:integrations => {:provider => 'Wordpress', :status => 'ready'}));

mode = "DELETION" # "CREATION", "ALL", "DELETION"
prev_id = records.first.company_id
changes_row = 1
sheet = {}
wsheet = {}
records.order(company_id: :asc, id: :asc).each_with_index do |record, rdx|
	check.each_with_index do |chk, cdx|

		changes = record.versions.where("object_changes LIKE '%#{chk}%'").where(:whodunnit => nil)
		
		if range.present?
			changes = changes.where("created_at > ?", range.begin).where("created_at < ?", range.end)
		end

		if changes.present?
			RakeHelper::yputs "#{changes.count} changes to #{chk.yellow} for #{record} (compid #{record.company_id})"
			changes.each_with_index do |chg, chgx|
				details = /#{chk}\:\n\-\s(.*)\n\-\s(.*)/.match(chg.object_changes)
				if details.present?

					op = "ALL"
					op = "CREATION" if (details[1].blank?)
					op = "DELETION" if (details[2].blank? || details[2] == "''")

					stats_index = chg.created_at.to_s[0..9]
					stats[op] = stats[op] || {}
					stats[op][stats_index] = stats[op][stats_index].present? ? stats[op][stats_index]+1 : 1;

					if mode == op && (details[1].to_s.strip != record.send(chk).to_s.strip) && (details[2].to_s.strip != record.send(chk).to_s.strip)
						# As our results are sorted by company id, only do this when it changes
						if prev_id != record.company_id
							wsheet.save unless wsheet.is_a?(Hash)
							sheet = RakeHelper::init_google_sheet "#{record.company_id} - Email and Phone Reconciliation", session
							wsheet = RakeHelper::init_google_worksheet "Sheet1", sheet
							puts "Created #{record.company_id} - Email and Phone Reconciliation"
							prev_id = record.company_id
							['Customer', 'Date', 'Old', 'New', 'Current Value', 'Whodunnit'].each_with_index{|dd,ddx| wsheet[1,ddx+1] = dd}
							changes_row = 2
						end
						op = (op.present? && op[0] == 'C' ? op.green : (op.present? && op[0] == 'D' ? op.red : ""))
						data = ['=HYPERLINK("https://app.troly.io/c/'+record.id.to_s+'", "'+record.id.to_s+'")', chg.created_at.strftime("%F %T"), details[1], details[2],record.send(chk),(User.find(chg.whodunnit) rescue '')]
						data.each_with_index{|d,ddx| wsheet[changes_row, ddx+1] = d}
						print "\n"
						RakeHelper::pputs "on\t#{chg.created_at}: #{details[1].ljust(40,' ')} "+"→".green+" #{details[2].ljust(40,' ')} #{op} (#{chg.whodunnit})"
						changes_row += 1
					end
				else
					# print chg.object_changes
				end
			end
			puts ""
		end
	end
	wsheet.save if (rdx % 50 == 0) && !wsheet.is_a?(Hash)
end;wsheet.save;

mode = "DELETION" # "CREATION", "ALL", "DELETION"
records.order(company_id: :asc, id: :asc).each do |record|
	check.each do |chk|

		changes = record.versions.where("object_changes LIKE '%#{chk}%'").where(:whodunnit => nil)
		
		if range.present?
			changes = changes.where("created_at > ?", range.begin).where("created_at < ?", range.end)
		end

		if changes.present?

			changes.each do |chg|
				details = /#{chk}\:\n\-\s(.*)\n\-\s(.*)/.match(chg.object_changes)
				if details.present?
					
					# RakeHelper::yputs "#{changes.count} changes to #{chk.yellow} for #{record} (compid #{record.company_id})"
					op = "ALL"
					op = "CREATION" if (details[1].blank?)
					op = "DELETION" if (details[2].blank? || details[2] == "''")

					stats_index = chg.created_at.to_s[0..9]
					stats[op] = stats[op] || {}
					stats[op][stats_index] = stats[op][stats_index].present? ? stats[op][stats_index]+1 : 1;

					if mode == "ALL" || mode == op
						op = (op.present? && op[0] == 'C' ? op.green : (op.present? && op[0] == 'D' ? op.red : ""))
						puts [chg.created_at, chg.item_id, Customer.find(chg.item_id).company_id, details[1], details[2], op, chg.whodunnit].join("\t")
					end
				else
					print chg.object_changes
				end
			end
			puts ""
		end
	end
end;nil


mode = "ALL"
stats = { }
recs = PaperTrail::Version.where(:created_at => timeframe, :item_type => 'Customer').where("object_changes LIKE '%email%' OR object_changes LIKE '%phone%'");
processed_ids = []
company_ids = []
recs.each do |chg|
	next if processed_ids.include?(chg.item_id)
	RakeHelper::yputs "Changes to customer #{chg.item_id}"
	['phone','email'].each do |chk|
		details = /#{chk}\:\n\-\s(.*)\n\-\s(.*)/.match(chg.object_changes)
		if details.present?

			op = "ALL"
			op = "CREATION" if (details[1].blank?)
			op = "DELETION" if (details[2].blank? || details[2] == "''")

			stats_index = chg.created_at.to_s[0..9]
			stats[op] = stats[op] || {}
			stats[op][stats_index] = stats[op][stats_index].present? ? stats[op][stats_index]+1 : 1;

			if mode == "ALL" || mode == op
				op = (op.present? && op[0] == 'C' ? op.green : (op.present? && op[0] == 'D' ? op.red : ""))
				RakeHelper::pputs "on\t#{chg.created_at}: #{details[1].ljust(40,' ')} "+"→".green+" #{details[2].ljust(40,' ')} #{op} (#{chg.whodunnit})"
			end
			processed_ids << chg.item_id
		else
			puts details.inspect unless details.nil?
		end
	end
	company_ids << Customer.find(chg.item_id).company_id
end;

