
#####
# COPY FROM HERE
#####

Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper

b = 10405
w = 10390

check = ['phone','email']


range = Time.new(2018,2,28)..Time.new(2018,3,8);
#range = Time.new(2018,4,18)..Time.new(2018,4,30)

records = Customer.where(:company => Company.active.joins(:integrations).where(:integrations => {:provider => 'Wordpress', :status => ['uninstalled','ready']}));

range = Time.new(2018,1,1)..Time.now
stats = { }


co_ids = Company.active.joins(:integrations).where(:integrations => {:provider => 'Wordpress', :status => ['uninstalled','ready']}).pluck(:id);

c_ids = CompanyCustomer.where(:company_id => co_ids).pluck(:customer_id);
c_ids = CompanyCustomer.where(:company_id => w).pluck(:customer_id);
records = Customer.where(:id => c_ids).where("updated_at >= ?", range.begin);

mode = "ALL" # "CREATED", "ALL", "DELETED", "UPDATED"
header_out = false
records.order(company_id: :asc, id: :asc).each do |record|

	check.each do |chk|
		header_out = false
		changes = record.versions.where("object_changes LIKE '%#{chk}%'")
		
		if range.present?
			changes = changes.where("created_at > ?", range.begin).where("created_at < ?", range.end)
		end

		if changes.present?

			changes.each do |chg|

				details = /#{chk}\:\n\-\s(.*)\n\-\s(.*)/.match(chg.object_changes)
				if details.present?
					
					d=[]
					[1,2].each do |k|
						d[k] = details[k].gsub(/^[\'\"\\]*/,"").gsub(/[\\\'\"]*$/,"")
					end

					if d[1].blank? && d[2].blank?
						next
					elsif !header_out
						header_out = true
						RakeHelper::yputs "#{changes.count} changes made to #{chk.yellow} for #{record}"
					end
					
					if chg.whodunnit.blank?
						if (d[2].present?)
							most_recent_value[chk] = d[2]
						elsif (d[1].present?)
							most_recent_value[chk] = d[1]
						end
					end

					op = "UPDATED"
					op = "CREATED" if (d[1].blank?)
					op = "DELETED" if (d[2].blank?)

					stats_index = chg.created_at.to_s[0..9]
					stats[op] = stats[op] || {}
					stats[op][stats_index] = stats[op][stats_index].present? ? stats[op][stats_index]+1 : 1;

					if mode == "ALL" || mode == op
						op = (op.present? && op[0] == 'C' ? op.green : (op.present? && op[0] == 'D' ? op.red : (op.present? && op[0] == 'U' ? op.yellow : "")))
						who = chg.whodunnit.present? ? User.find(chg.whodunnit).fname : "?"
						#RakeHelper::pputs "on\t#{chg.created_at}: #{details[1].ljust(40,' ')} "+"→".green+" #{details[2].ljust(40,' ')} #{op} (#{who})"
						RakeHelper::pputs "on\t#{chg.created_at}:\t#{d[1].ljust(40,' ')}\t#{d[2].ljust(40,' ')}\t#{op}\t(#{who})"
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
			RakeHelper::gputs "Restoring #{k} for #{record} to _#{v}_"
			#record.update_attribute(k => v)
			restoring = true
		end
	end

	puts "" if header_out
	header_out = false

end;nil