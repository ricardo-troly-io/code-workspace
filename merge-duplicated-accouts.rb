# Binding Process
orig_customer = Customer.find(306584)
dups = [318141, 308954, 317916, 317895]

dups.each |cid| do
    # find the old customer via id
    old_c = Customer.find(cid);

    # find old customer related orders
    o = Order.where(:customer_id => old_c.id);
    o.each {|o| o.customer_id = orig_customer.id };

    # find old customer related invoices
    i = Invoice.where(:customer_id => old_c.id);
    i.each {|i| i.customer_id = orig_customer.id };

    # find old customer related payments
    p = Payment.where(:customer_id => old_c.id);
    p.each {|p| p.customer_id = orig_customer.id };

    # find old customer related shipments
    s = Shipment.where(:customer_id => old_c.id);
    s.each {|s| s.customer_id = orig_customer.id };

    # archive the customer with an admins user id (in prod, 28090)
    old_c.archive! 28090
end