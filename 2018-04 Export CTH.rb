Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper
Google::APIClient.logger.level = 3

def export_memberships company_id
	prods = ["CTHBOTRIE12, 375ML", "CTHCABMER05, 750ML", "CTHCABMER06, 750ML", "CTHCABMER09, 750ML", "CTHCABMER10 STV", "CTHCABMER10, 3000ML", "CTHCABMER10, 375ML", "CTHCABMER10, 750ML", "CTHCABMER10, U/L", "CTHCABMER11, 750ML CORK", "CTHCABMER11, 750ML STV", "CTHCABMER11, MAGNUM", "CTHCABMER11, U/L", "CTHCABMERFLIGHTSIX", "CTHCABMMER10 MAG CLARET", "CTHCABSAUV08,  3000ML", "CTHCABSAUV10, 1500ML BURG", "CTHCABSAUV10, 1500ML CLARET", "CTHCABSAUV10, 3000ML", "CTHCABSAUVTRIPLEPK", "CTHCCABMER10, MAG BURG", "CTHCHARD15", "CTHCHARDTRIPLEPACK", "CTHCSAUV10, 750ML", "CTHDIANA09, 750ML", "CTHDIANA11, 3000ML", "CTHDIANA11, 750ML", "CTHDIANA13, 750ML", "CTHDIANA14", "CTHDIANA15", "CTHHAYDEN15", "CTHLH13, 375ML", "CTHMER09, 750ML", "CTHMER09HALLE, 3000ML", "CTHMER11, 750ML", "CTHMER11HALLE, 3000ML", "CTHMER11HALLEFUTURA", "CTHMER13, 750ML", "CTHMER13MAGNUMCLARET", "CTHMERHALLEMAG, 1500ML", "CTHMMER13MAGFUTURA", "CTHPLATINUMCASE", "CTHRESCAB08,", "CTHRESCAB11, 750ML", "CTHRIE05, 750ML", "CTHRIE06, 750ML", "CTHRIE08, 750ML", "CTHRIE09, 750ML", "CTHRIE10, 750ML", "CTHRIE11, 750ML", "CTHRIE12, 1500ml", "CTHRIE12, 750ML", "CTHRIE13, 1500ml", "CTHRIE13, 750ML", "CTHRIE14, 1500ml", "CTHRIE14,750ML", "CTHRIE15, 750ML", "CTHRIE16", "CTHRIEMIXEDDOZEN", "CTHRIEMIXEDSIX", "CTHROSE10, 750ml", "CTHROSE11, 750ML", "CTHSB08, 750ML", "CTHSB09, 750ML", "CTHSB10, 750ML", "CTHSB11, 750ML", "CTHSB12. 750ML", "CTHSB13, 750ML", "CTHSB15", "CTHSB16", "CTHSBMIXEDSIXPACK", "CTHSPKROSE15", "CTHSPKWH16", "CTHWEDDING, 1500ML", "CTHWEDDING11 3000ML", "CTHWEDDING11, 1500ml CLARET", "CTHWEDDING13, 1500ML CLARET", "CTHWEDDING13, 3000ML", "CTHWEDDING13, 750ML", "CTHWEDDING13, MAGNUM FUT", "NA12022016", "SPKRED16", "cthrose15"];
	
	session = RakeHelper::init_google_session 53339
		
	sheet = RakeHelper::init_google_sheet 'CTH Member Templates (Mid 2018)', session
	
	wsheet = RakeHelper::init_google_worksheet "Member Export", sheet
	
	psheet = RakeHelper::init_google_worksheet "Pending", sheet
	
	psheet_count = 7
	
	comp = Company.find(company_id)
	
	products = comp.products.where(:variety => 'wine').pluck(:id)
	
	comp.customers.joins(:memberships).merge(Membership.current).order("memberships.membership_type_id ASC, customers.fname ASC, customers.lname ASC").each_with_index do |customer, cdx|
		
		template_order_exists = customer.orders.where(:status => 'template').exists? ? "Yes" : "No"
		
		order_to_be_used = CompanyCustomer.template_order(customer.id, customer.company_id)
		
		contents_is_template = ((order_to_be_used.status == 'template') ? 'Yes' : 'No') rescue 'No'
		
		membership = customer.memberships.current.first
		
		ols = order_to_be_used.orderlines.map{|ol| next unless ol.product.variety == membership.membership_type.min_order_variety && PRODUCT_IDS_PRICE_LOCKED.exclude?(ol.product_id); "#{ol.qty} x #{ol.name}"}.join("\n") rescue "No Orderlines"
		
		
		dates = (1..(membership.deliveries)).map{|dd| membership.send("delivery_date_#{dd}").strftime("%F")}
		ndd = membership.next_delivery_date.strftime("%F") rescue "No Next Delivery Date"
		
		
		[customer.id, customer.name, membership.membership_type.name, (customer.orders.where.not(:status => 'cancelled').last.created_at.strftime("%F") rescue nil),(order_to_be_used.total_qty rescue nil), template_order_exists, ols, contents_is_template, ndd, dates].flatten(2).each_with_index{|datum,ddx| wsheet[cdx+4, ddx+1] = datum}
		
		if ols == 'No Orderlines'
			['Order', customer.id, customer.email, membership.membership_type.name].each_with_index{|datum, ddx| psheet[psheet_count, ddx+3] = datum}
			psheet[psheet_count, 20] = customer.salutation
			psheet[psheet_count, 21] = customer.fname
			psheet[psheet_count, 22] = customer.lname
			psheet[psheet_count, 38] = 'template'
			psheet_count += 1
		elsif contents_is_template == 'No'
			ools = order_to_be_used.orderlines
			if (ools.pluck(:product_id) - products).count > 1
				# Make sure we only have Wine Products!
				['Order', customer.id, customer.email, membership.membership_type.name].each_with_index{|datum, ddx| psheet[psheet_count, ddx+3] = datum}
				psheet[psheet_count, 20] = customer.salutation
				psheet[psheet_count, 21] = customer.fname
				psheet[psheet_count, 22] = customer.lname
				psheet[psheet_count, 38] = 'template'
				# Our import template does not support packs!
				ools.each_with_index do |ool, oldx|
					next if ool.display_only?
					pn = ool.product.product_number
					next unless prods.include?(pn)
					psheet[psheet_count, 44+prods.find_index(pn)] = ool.qty
				end
				psheet_count += 1
			end
		end
		
		if (cdx % 50 == 0 && cdx > 0)
			puts "Saving #{cdx}... #{wsheet.save}" #{psheet.save}"
		end
	end
	wsheet.save
	# psheet.save
	return true
end
export_memberships 10225

#### Exporting wine prods
prods = Product.for_company(10225);
prods.where(:variety => 0).where.not(:id => PRODUCT_IDS_PRICE_LOCKED).order(:id => :asc).each do |pr|
  puts [pr.id, '=HYPERLINK("https://app.troly.io/p/'+pr.id.to_s+'", "'+pr.name+'")',('=HYPERLINK("https://app.troly.io/p/'+pr.fall_back_id.to_s+'", "'+Product.find(pr.fall_back_id).name+'")' rescue ''), pr.stock_total, (pr.archived_at.strftime("%F") rescue ''), pr.tags.where(:id => TAG_ID_OUT_OF_STOCK).count > 0].join("\t")  
end;
