Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper

Pipedrive.authenticate('f5daf99190a7cbe95b1c4b2169196ea4b76d438b')

loop do

	cid = RakeHelper::stdin_for_regex(/\d/,"What is the Contact ID to push?").to_i
	break if cid == 0

	contact = Pipedrive::Person.find(cid)
	org = Pipedrive::Organization.find(contact.org_id['value'])

	mob = contact.phone.select{ |x| /\+614/.match(x['value']) || x['label'] == 'mobile' }
	email = contact.email.select{ |x| x['label'] == 'work' || x['label'] == 'Work' || x['primary'] == true }
	www = org['7cb50b016f38c13d57389d26b5d66b1de12bab13']

	headers = {"autopilotapikey" => "2adc4e64e4c34820ab6e7df587aa482d", "Content-Type" => "application/json"}
	data={
		'Email' => email.last['value'],
		'FirstName' => contact.first_name,
		'LastName' => contact.last_name,
		'Company' => org.name,
		'MailingCountry' => 'Australia',
		'custom' => {
			"integer--pipedrive_id" => contact.id,
			"string--WorkshopCode" => 'TASN1703'
		},
		'_autopilot_list​' => 'contactlist_C3A606A0-9ABA-4DE7-BAE2-7E47FA9E1AFD',
		'autopilot_list​' => 'contactlist_C3A606A0-9ABA-4DE7-BAE2-7E47FA9E1AFD',
		'__autopilot_list​' => 'contactlist_C3A606A0-9ABA-4DE7-BAE2-7E47FA9E1AFD',
	}

	data['MobilePhone'] = mob.last['value'] if mob.present?

	response = HTTParty.post('https://api2.autopilothq.com/v1/contact', :body => {"contact" => data}.to_json, :headers => headers) 

	puts response

end


