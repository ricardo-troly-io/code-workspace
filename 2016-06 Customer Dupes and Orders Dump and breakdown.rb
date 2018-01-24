
def hash_to_s h, lpad=10
	maxlen = 0
	h.keys.each do |k|
		maxlen = [maxlen,k.to_s.length].max
	end

	res = ''
	h.keys.each do |k|
		label = k.to_s.rjust(maxlen+lpad, padstr=' ')
		res = res + " #{label} => #{h[k]}\n"
	end
	return res
end

def print_versions o
	o.versions.each do |version|
		changes = version.object_changes.split("\n")
		puts "#{version.created_at}: ".white + "#{changes[1]}".yellow + " changed from ".white + "#{changes[2]}".yellow + " ▶▶ to ▶▶ ".white + "#{changes[3]}".yellow
	end
end

##
## Amber from SLW - Duped customers?
##

cid = 10091

all_customer_ids = CompanyCustomer.where(:company_id => cid).pluck(:customer_id).uniq
checked_customer_ids = []

all_customer_ids.each do |customer_id|
	
	puts customer_id.to_s.green

	c = Customer.find customer_id

	checked_customer_ids << customer_id

	dupes = Customer.where(:id => all_customer_ids, :lname => c.lname, :fname => c.fname, :email => c.email).where.not("email LIKE '%empireone%'").where.not(:id => checked_customer_ids)

	if dupes.count >= 2

		puts "\n#{c} x#{dupes.count}".yellow

		dupes.each do |dupe|
			#next if checked_customer_ids.include? dupe.id

			#memb = Membership.where(:customer_id => dupe.id, :status => "current").last
			#puts "▶   #{dupe.id}, created: #{dupe.created_at}, updated: #{dupe.updated_at}, membership: #{memb.id}, #{memb.ends_at)}"
			puts "▶   #{dupe.id}, created: #{dupe.created_at}, updated: #{dupe.updated_at}"

			data = {
				"ProviderData" => dupe.provider_data,
				"Orders" => dupe.orders.pluck(:number,:created_at,:total_value),
				"Emails" => dupe.emails.pluck(:sent_at,:subject)
			}

			print_hash data

			checked_customer_ids << dupe.id
		end
	end
end;




## 
## EXPORT all sales with taxes and shipping breakdown. 
## Not properly tested with taxable products.
##


cid = 10107

puts [  'Order Number',
		'Customer',
		'Non Taxable total',
		'Taxable total',
		'Picked up / Shipped',
		'Shipping',
		'Taxes Applied',
		'Order Total',
		'Invoice',
		'Date'
	].join("\t")

pids = Product.for_company(cid).pluck(:id)

# tax applicable products
ta_pids = Product.where(:id => ProductsTag.where.not(:tag_id => TAG_ID_TAX_EXEMPT).where(:product_id => pids).pluck(:product_id))
pids = Product.for_company(cid).pluck(:id)

# tax free products
tf_pids = Product.where(:id => ProductsTag.where(:tag_id => TAG_ID_TAX_EXEMPT, :product_id => pids).pluck(:product_id))

Order.where(:company_id => cid,:payment_status =>'paid').where.not(:customer_id => nil).each do |o|
	if o.invoice.document.blank?
		#puts "#{o.invoice.number}".red
		next
	end

	taxable_ols = o.orderlines.where(:product_id => ta_pids)
	taxable_total = taxable_ols.sum(:subtotal) - taxable_ols.sum(:tax1)
#    non_taxable_total = o.orderlines.where(:product_id => tf_pids).sum(:subtotal)

	puts [  o.number,
			o.customer.name,
#            non_taxable_total,
			0,
			taxable_total,
			o.shipment.present? ? 'Shipped' : 'Picked up',
			o.shipment ? o.shipment.shipping_price : 0,
			o.total_tax1,
			o.total_value,
			o.invoice.document.data.url,
			o.invoice.issued_at
	].join("\t")
end;