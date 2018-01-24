Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") { |file| require file }
include RakeHelper

url = "https://hooks.zapier.com/hooks/catch/2102406/ii1htd/"

cus = CompanyUser.where("is_admin = true OR is_billing = true OR is_sales_staff = true");

cus.where.not(:user_id => uids).each do |cu|

	if cu.user.email.match(/subscribility|troly|empireone/)
		RakeHelper::rputs "#{cu.user.email} skipped"
	else
		RakeHelper::gputs "processing #{cu.user.email}"
		HTTParty.post(url,
						:body => { :user => cu.user, :user__cu => cu, :user__co__id => cu.company_id, :user__co__business_name => cu.company.business_name }.to_json,
						:headers => { 'Content-Type' => 'application/json' } 
					);
		sleep(2);
	end
end


cus.each do |cu|


	case RakeHelper::stdin_for_regex(/s|y|n|d/,"Process #{cu.user.email} at #{cu.company.business_name}? (yes, no, stop or delete)")
		when 's'
			break;
		
		when 'y'

			HTTParty.post(url,
				:body => { :user => cu.user, :user__cu => cu, :user__co__id => cu.company_id, :user__co__business_name => cu.company.business_name }.to_json,
				:headers => { 'Content-Type' => 'application/json' } 
			);

		when 'd'
			cu.delete;
	end
end





doubles.each do |k,v|

	u = User.find(k)
	puts ""
	puts u
	puts u.companies.pluck(:business_name, :id)
end
