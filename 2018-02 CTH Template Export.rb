Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper
Google::APIClient.logger.level = 2
session = RakeHelper::init_google_session 53339
sheet =  RakeHelper::init_google_sheet(nil, session)

def print_member_orders cid, session, sheet
	export_sheet = RakeHelper::init_google_worksheet "Member Template Export", sheet
	import_sheet = RakeHelper::init_google_worksheet "Pending", sheet
	comp = Company.find cid;
	offset = 1
	t_offset = 6
	comp.customers.joins(:memberships).where(:memberships => {:status => 'current'}).order("memberships.membership_type_id ASC, customers.fname ASC, customers.lname ASC").each_with_index do |cus, cdx|
		template = CompanyCustomer.template_order(cus.id, cus.company_id)
		cus.orders.where(:status => ['completed', 'template']).order(created_at: :desc).each_with_index do |ord, odx|
			next if template.nil? || template.id != ord.id
			data = {
				'ID' => cus.id,
				'Name' => "#{cus.fname} #{cus.lname}",
				'Club' => (ord.membership.name rescue ''),
				'Value' => ord.total_value.to_f,
				'Total Qty' => ord.total_qty.to_f,
				'Template For Next Order' => ((template.id == ord.id ? 'TEMPLATE FOR NEXT ORDER ==>' : '') rescue ''),
				'Order Content (display only false) ' => ord.orderlines.where(:display_only => false).order(name: :asc).map{|ol| "#{ol.qty} x #{ol.name}"}.join("\n")
			}
			export_sheet = RakeHelper::set_wsheet_row(export_sheet, offset, data, 1)
			export_sheet.save
			puts "Saved #{cus.name} #{ord.id} #{cus.orders.where(:status => ['completed', 'template']).count} (#{offset+cdx+odx}) to sheet... #{offset}"
			offset += 1
		end
		if template.nil?
			data = {
				'Cust. Imp. Status' => '',
				'Order. Imp. Status' => '',
				'Import Scope' => 'Order',
				'troly_customer_id' => cus.id,
				'email' => cus.email,
				'membership' => cus.memberships.where(:status => 'current').last.name,
				'gender' => '',
				'cc_number' => '',
				'cc_name' => '',
				'cc_exp_month' => '',
				'cc_exp_year' => '',
				'birthday' => '',
				'billing_address' => '',
				'billing_suburb' => '',
				'billing_state' => '',
				'billing_postcode' => '',
				'billing_country' => '',
				'notify_newsletters' => '',
				'S' => '',
				'salutation' => '',
				'fname' => cus.fname,
				'lname' => cus.lname
			}
			import_sheet = RakeHelper::set_wsheet_row(import_sheet, t_offset, data, 1)
			import_sheet.save
			t_offset += 1
			data = {
				'ID' => cus.id,
				'Name' => "#{cus.fname} #{cus.lname}",
				'Club' => (cus.memberships.where(:status => 'current').last.name rescue ''),
				'Value' => '',
				'Total Qty' => '',
				'Template For Next Order' => 'Import Required - No Eligible Orders'
			}
			export_sheet = RakeHelper::set_wsheet_row(export_sheet, offset, data, 1)
			export_sheet.save
			puts "Saved #{cus.name} <nil> #{cus.orders.where(:status => ['completed', 'template']).count} (#{offset+cdx+0}) to sheet... #{offset}"
			offset += 1
		end
	end
	return true
end

def print_company_products comp, session, sheet
	product_sheet = RakeHelper::init_google_worksheet "Product SKUs", sheet
	comp.products.where(:archived_at => nil, :variety => [0, 2]).where.not(:product_number => nil).order(name: :asc).each_with_index do |prod, pdx|
		data = {
			'ID' => prod.id,
			'Name' => prod.name,
			'Vintage' => prod.vintage,
			'SKU' => prod.product_number,
			'Price (Retail)' => prod.price,
			'Price (6-pack)' => prod.price_6pk,
			'Price (Case)' => prod.price_case
		}
		product_sheet = RakeHelper::set_wsheet_row(product_sheet, pdx, data, 1)
		puts "Saved #{prod.name}"
	end
	product_sheet.save
end

company = RakeHelper::company_lookup 10225
print_member_orders company, session, sheet
print_company_products company, session, sheet

