names = ["Jesus Leon Jr.", "Aaron McWilliams", "Jared Keers", "Brian Higelmire", "Michael Curling", "Stephen Sandberg", "Shane Carte", "John Powderly", "Steven Moran", "Brandon Sherron", "Jerry Kerr", "Michael Puin", "Michael O'Connell", "Daniel Fullerton"]


include RakeHelper
c=company_lookup

orders = []
names.each do |name|
	name = name.split(' ')
	customers = c.customers.where(:fname => name[0], :lname => name[1..5].join(" "))
	customer = nil
	
	case customers.count
		when 0
			puts "no customer named #{name} was found?".red
			next
		when 1
			customer=customers.last
		else
			puts "more than one #{name} (x #{customers.count})?".red
			next
	end

	if (customer.orders.blank?)
		puts "no active order for #{name}?".red
	else
		cust_orders = customer.orders.where(:payment_status => 'auth')
		if cust_orders.count == 1
			orders << cust_orders.last
			puts orders.last
		else
			puts "multimple orders for #{name} found".yellow
		end
	end
end

orders.each do |o|
	puts "Found #{o} for #{o.customer} with #{o.payment_status} payment of #{o.total_value}"
	o.update_columns(:payment_status => 'paid')
	puts " → now marked as '#{o.reload.payment_status}'"
end;



###### 
STEPHEN NOTES
######

Hi Stephen, 

As discussed this morning;

- Funds transfered to you over FY16 will be structured as employee. This will create a tax debt owed to the ATO and I will send you further details and exact numbers Can you please fill the last page of this; https://docs.google.com/document/d/1DnwtDSHSjSpLVqEHwCmi0M7leAKc7RjzHbdMsLlgolQ




2000
2000
500
1500
3000
1500


10500












