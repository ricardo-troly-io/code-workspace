t = 6.weeks.ago
check = "cc_number"

Company.find(10225).members.each do |m|
	changes = m.versions.where("created_at >= ?", t).where("object_changes LIKE '%cc_number%'")
	changes.each do |c|
		puts ""
		puts m
		details = c.object_changes.split(/\n#{check}:\n- (.*)\n- (.*)/)
		puts "\t changed #{check} from #{details[1]} to #{details[2]} on #{c.created_at}"
	end
end;