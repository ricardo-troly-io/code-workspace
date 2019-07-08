###################
# We are going to pluck id's and subtract those ids with orders created form 
# the total ids for the membership
###################

# memberships types we are interested in
membs = [10160, 10159, 10161]

# All membership ids for the membership types above
all_memb_ids = Membership.where(:membership_type_id => membs).pluck(:id)
all_memb_ids = Membership.for_company(10068).pending_or_current.where(:membership_type_id => membs).pluck(:id)
#outputs 261 memberhip id's

# Orders created for those memberships
orders_created = Order.where(:membership_id => all_memb_ids, :created_at => 8.days.ago..7.days.ago)

# Given that the number returned by the sentence above is 185
# (we are looking for 184 orders created at that date) and it's near enough, 
# we continue with the search

# Memberships with orders created
membs_with_orders = orders_created.pluck(:membership_id)

# Memberships without orders created
membs_without_orders = all_memb_ids - membs_with_orders

# Customer ids without orders created
cust_ids = Membership.where(:id => membs_without_orders).pluck(:customer_id);

# final customer data to be converted to csv mannualy
membs_without_orders_data =
  Customer.where(:id => cust_ids)
    .map {|c| {
        :id => c.id,
        :name => c.fname + ' ' + c.lname,
        :email => c.email,
        :mobile => c.mobile,
        :delivery_address => c.delivery_address,
        :delivery_area => c.delivery_area
    }
}
