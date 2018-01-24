
Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}

include RakeHelper
c=company_lookup

session = RakeHelper::init_google_session
wsheet = RakeHelper::init_google_worksheet "#{c.id_s} - Payments captured", "#{c.business_name} (#{c.id}) - Finances & Investigations", session



i = 1
loop do 
	break if (i+=1) >= wsheet.num_rows
	next if wsheet[i,7].blank?

	old_meth = wsheet[i,3]
	new_meth = wsheet[i,7]

	t = Time.parse(wsheet[i,1])
	p=c.payments.where(:created_at =>  t-5.seconds..t+5.seconds, :company_id => c.id, :amount => wsheet[i,4])

	if p.count != 1
		RakeHelper::rputs "#{p.count} payments were found"
		puts p
	elsif p.first.meth == new_meth
		RakeHelper::yputs "PID #{p.first.id} was already changed from #{old_meth} to #{new_meth}"
	elsif ['cash','eftpos'].include?(new_meth)
		RakeHelper::gputs "PID #{p.first.id} now changed from #{p.first.meth} to #{new_meth}"
		p.first.meth = new_meth
		p.first.save!
	else
		RakeHelper::yputs "Invalid new_meth #{new_meth}. skipping"
	end
end