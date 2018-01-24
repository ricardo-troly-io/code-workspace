old = Company.find 10071
new = Company.find 10058

# Disassociate customers already associated with the new company from the old one
CompanyCustomer.delete(14252)
CompanyCustomer.delete(14249)
CompanyCustomer.delete(14248)
CompanyCustomer.delete(14250)
CompanyCustomer.delete(14251)

# Copy customers over to new company
old.company_customers.update_all(:company_id => new.id)

# Update membership types - Needs reviewing based on the companies memberships
new.company_customers.joins(:membership).pluck(:membership_type_id).uniq
# => [10101, 10094]
new.membership_types.pluck(:id, :name).uniq
# => [[10094, "Sanguine Wine Club"]]
new.company_customers.joins(:membership).where(:memberships => {:membership_type_id => 10101}).pluck(:membership_id)
Membership.where(:id => _).update_all(:membership_type_id => 10094)

# Update memberships
Membership.where(:company_id => old.id).update_all(:company_id => new.id)

# Update streams
Stream.where(:company_id => old.id).update_all(:company_id => new.id)

# Update the scheduled delivery dates
customer_ids = []
start_time = Time.now

Membership.where(:company_id => new.id).find_each do |m|
	m.from_mt(m.membership_type)
	m.save
	customer_ids << m.customer_id
end

end_time = Time.now

# Remove the streams for updating the delivery dates
Stream.where(:company_id => new.id, :customer_id => customer_ids, :created_at => start_time..end_time).delete_all


