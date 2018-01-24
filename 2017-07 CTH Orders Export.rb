Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper

session = RakeHelper::init_google_session

c=RakeHelper::company_lookup

sheet_name = "#{c.business_name} (#{c.id}) - Finances & Investigations"
sheet_name = RakeHelper::stdin_for_regex(/y|n/,"Use standard Google Sheet (#{sheet_name})?") == "y" ? sheet_name : nil

sheet =  RakeHelper::init_google_sheet(sheet_name, session)
wsheet = RakeHelper::init_google_worksheet "#{c.id_s} - Orders recorded", sheet

start_date, end_date, row_offset = RakeHelper::append_range(wsheet,0)
     
i=row_offset
c.orders.where(:created_at => start_date..end_date).where.not(:customer_id => nil).order(:created_at => :asc).each do |o|
	RakeHelper::pputs o.created_at

	o.orderlines.each do |ol|
	
		data = {
	  		'Date' => o.created_at.to_s,
	  		'Customer' => o.customer.to_s,
	  		'Status' => o.status,
	  		'Total' => o.total_value,
	  		'Qty' => ol.qty,
	  		'Product' => ol.name,
	  		'Product Code' => ol.product_id,
	  		'Line Total' => ol.subtotal.to_f,
		}
		wsheet = RakeHelper::set_wsheet_row(wsheet, i, data, row_offset)
		i += 1
	end;nil
end;nil