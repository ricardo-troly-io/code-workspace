# Define the membership type as a constant
MEMBERSHIP_TYPE = 10223

# Get all membership ids, to get then, the orders related.
# Filter with scope "pending_or_current" to get only those pending memberships or current with no pending membership
membership_ids = Membership.where(:membership_type_id =>MEMBERSHIP_TYPE_ID).pending_or_current.pluck(:id);

# Get all the order id's that have been created related to that memberships
orders_ids = Order.where(:membership_id => membership_ids).pluck(:id)

# Get all customers belonging to the desired membership type
customers = Customer.joins(:memberships).where("memberships.membership_type_id = #{MEMBERSHIP_TYPE}")

customers.each do |c|
    # Get all the shipments for the current customer that matches orders for the memberships
    shp = c.shipments.where(:order_id => orders_ids)
    shp = shp.map {|s| {shipment_date: s.shipment_date, order_id: s.order.id}}

    # Check inside the shipments collection (shp) for March/2019 
    if shp.none? {|s| s[:shipment_date].month == 3 && s[:shipment_date].year == 2019}
        # If no shipment fo March/2019, set for the next month from now

        # Ask james how to reschedule shipment for this set of orders 
    end
end