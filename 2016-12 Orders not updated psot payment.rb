
c=company_lookup

c.payments.where.not(:customer_id => nil).where(:status => 'success').where("created_at >= ?",1.month.ago).each do |p|

	if p.invoice.orders.count > 0 && p.invoice.orders.last.payment_status != 'paid' && p.status != p.invoice.orders.last.payment_status
		puts "Order #{p.invoice.orders.last} marked as #{p.invoice.orders.last.payment_status}, although a #{p.status} #{p.trx} was recorded"

		p.post_processing

	end

end;



c.orders.where(:status => ['in-progress','confirmed']).each do |o|
puts "....."
	if o.payments.where(:status =>'success').present?
		p=o.payments.order(:created_at=>:desc).first
puts o.payments.order(:created_at).inspect
		if o.payment_status_details.blank? 
			puts "payment yea, status no"
		elsif p.status == 'success'
			puts o
			puts p.inspect
		end
	end
end;