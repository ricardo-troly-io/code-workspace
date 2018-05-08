
Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper

b = 10405
w = 10390

check = ['phone','email']

range = Time.new(2018,2,28)..Time.new(2018,3,8);
#range = Time.new(2018,4,18)..Time.new(2018,4,30)

#range = Time.new(2010,02,28)..Time.now
stats = { }

c_ids = CompanyCustomer.where(:company_id => [b,w]).pluck(:customer_id);
records = Customer.where(:id => c_ids);

mode = "ALL" # "CREATED", "ALL", "DELETED", "UPDATED"
records.each do |record|

	most_recent_value = {}
	new_line = false

	check.each do |chk|

		changes = record.versions.where("object_changes LIKE '%#{chk}%'")
		
		if range.present?
			changes = changes.where("created_at > ?", range.begin).where("created_at < ?", range.end)
		end

		if changes.present?
			new_line = true

			RakeHelper::yputs "#{changes.count} changes to #{chk.yellow} for #{record}"
			changes.each do |chg|
				details = /#{chk}\:\n\-\s(.*)\n\-\s(.*)/.match(chg.object_changes)
				if details.present?

					most_recent_value[chk] = details[2] if (details[2].present? && details[2] != "''")

					op = "UPDATED"
					op = "CREATED" if (details[1].blank?)
					op = "DELETED" if (details[2].blank? || details[2] == "''")

					stats_index = chg.created_at.to_s[0..9]
					stats[op] = stats[op] || {}
					stats[op][stats_index] = stats[op][stats_index].present? ? stats[op][stats_index]+1 : 1;

					if mode == "ALL" || mode == op
						op = (op.present? && op[0] == 'C' ? op.green : (op.present? && op[0] == 'D' ? op.red : (op.present? && op[0] == 'U' ? op.yellow : "")))
						who = chg.whodunnit.present? ? User.find(chg.whodunnit).fname : "?"
						RakeHelper::pputs "on\t#{chg.created_at}: #{details[1].ljust(40,' ')} "+"→".green+" #{details[2].ljust(40,' ')} #{op} (#{who})"
					end
				else
				#	puts details.inspect
				end
			end
		end
	end

	restoring = false
	most_recent_value.each do |k,v|
		if v.present? && record[k] != v
			RakeHelper::gputs "Restoring #{k} for #{record} to _ #{v} _"
			#record.update_attribute(k => v)
			restoring = true
		end
	end

	#RakeHelper::rputs "No changes to restore for #{record}" unless restoring
	
	puts "" if new_line

end;nil