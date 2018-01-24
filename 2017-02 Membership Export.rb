#### 
## MEMBERSHIP EXPORT
####

Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper

co=company_lookup

session = RakeHelper::init_google_session
wsheet = RakeHelper::init_google_worksheet nil, nil, session

i=-1
co.memberships.current.each do |m|

	cu = m.customer
	cc = CompanyCustomer.where(:company_id => co.id, :customer_id => m.customer_id)
	
	if (cc.count != 1)
		RakeHelper.rputs "#{cc.count} company customer found for customer_id #{m.customer_id}"
	else
		cc = cc.first
	end
	
	data = {
		"m.id" => m.id,
		"c.fname" => cu.fname,
		"c.lname" => cu.lname,
		"c.email" => cu.email,
		"c.mobile" => cu.mobile,
		"m.name" => m.name,
		"cc.membership_num" => cc.membership_num,
		"cc.membership_notes" => cc.membership_notes,
		"cc.payment_notes" => cc.payment_notes,
		"m.starts_at" => m.starts_at,
		"m.ends_at" => m.ends_at,
		"m.hold_until" => m.hold_until,
		"m.next_delivery_date" => m.next_delivery_date,
		"m.delivery_date_1" => m.delivery_date_1,
		"m.delivery_date_notes_1" => m.delivery_date_notes_1,
		"m.delivery_date_2" => m.delivery_date_2,
		"m.delivery_date_notes_2" => m.delivery_date_notes_2,
		"m.delivery_date_3" => m.delivery_date_3,
		"m.delivery_date_notes_3" => m.delivery_date_notes_3,
		"m.delivery_date_4" => m.delivery_date_4,
		"m.delivery_date_notes_4" => m.delivery_date_notes_4,
		"m.delivery_date_5" => m.delivery_date_5,
		"m.delivery_date_notes_5" => m.delivery_date_notes_5,
		"m.delivery_date_6" => m.delivery_date_6,
		"m.delivery_date_notes_6" => m.delivery_date_notes_6
	}

	wsheet = RakeHelper::set_wsheet_row(wsheet, i+=1, data)

end;nil

wsheet.save

#### 
## MEMBERSHIP REIMPORT
####


Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper

co=company_lookup

session = RakeHelper::init_google_session
wsheet = RakeHelper::init_google_worksheet nil, nil, session

headers=wsheet.rows[0]

identifier = "m.id"
changes={
	"m.starts_at" => DateTime,
	"m.ends_at" => DateTime,
	"m.next_delivery_date" => Date,
	"m.delivery_date_1" => Date,
	"m.delivery_date_2" => Date,
	"m.delivery_date_3" => Date,
	"m.delivery_date_4" => Date
}

i=0
loop do
	break if (i+=1) >= wsheet.num_rows
	row = wsheet.rows[i]

	m = Membership.find(row[headers.index(identifier)])
	RakeHelper.pputs(m.to_s)

	changes.each do |k,f|
		_old = eval(k).to_s
		_new = row[headers.index(k)]
		if _old != _new
			puts "    #{k[2..100]}: #{_old} → #{_new}"
			m.update_column(k[2..100].to_sym, _new)
		end

	end

end


# adjust all membership which seems to have more than 12 months runway..
co.memberships.current.where("ends_at > ?", 14.months.from_now).each do |m|
	m.ends_at = m.starts_at + 12.months
	m.save!
end