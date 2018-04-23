
Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper

b = 10405
w = 10390

check = ['phone','email']
range = Time.new(2018,02,28)..Time.new(2018,03,08)
range = Time.new(2018,04,18)..Time.new(2018,04,30)
#range = Time.new(2010,02,28)..Time.now
stats = { }

c_ids = CompanyCustomer.where(:company_id => [b,w]).pluck(:customer_id);
records = Customer.where(:id => c_ids);

mode = "ALL" # "CREATION", "ALL", "DELETION"
records.each do |record|
	check.each do |chk|

		changes = record.versions.where("object_changes LIKE '%#{chk}%'")
		
		if range.present?
			changes = changes.where("created_at > ?", range.begin).where("created_at < ?", range.end)
		end

		if changes.present?

			RakeHelper::yputs "#{changes.count} changes to #{chk.yellow} for #{record}"
			changes.each do |chg|
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
				else
					puts details.inspect
				end
			end
			puts ""
		end
	end
end;nil
