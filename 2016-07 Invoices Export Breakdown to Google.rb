sheet = init_google_sheet

Company.where(:is_fake => false, :is_locked => false).each do |c|

	invoices = c.invoices.where(:customer_id => nil, :issued_at => Time.parse("2016-01-01")..Time.parse("2016-06-01"))
	next if invoices.blank?

	ws_name = "#{c.id} - #{c.business_name}"
	ws = sheet.worksheet_by_title(ws_name) || sheet.add_worksheet(ws_name, max_rows = 100, max_cols = 20)

	ws[1,1] = "Date"
	ws[1,2] = "Number"
	ws[1,3] = "Breakdown"
	ws[1,4] = "Value"
	ws[1,5] = "Error"
	ws[1,6] = "Additional Details"

	i=2
	invoices.order(company_id: :asc, id: :asc).each do |invoice|		

		ws[i,1] = invoice.issued_at.strftime("%e %b '%y")
		ws[i,2] = "=HYPERLINK(\"https://my.subscribility.com.au/downloads/#{invoice.document.access_token}?disposition=inline\",\"#{invoice.number}\")"

		invoice.orderlines.where(display_only: :false).order(id: :asc).each do |ol|
			ws[i,3] = ol.name
			ws[i,4] = ol.base_price

			if Regexp.new("payments processed").match(ol.name)
				range = invoice.issued_at.last_month..invoice.issued_at
				payments = Payment.where(:company_id => c.id, :created_at => range).where.not(:customer_id => nil).sum(:amount)
				ws[i,5] = ol.base_price - (payments*0.01).round(2)
				ws[i,6] = "Should be labelled 'Platform usage fee (1% of $#{payments.round})'"
			end
			i = i + 1
		end

		ws[i,3] = "GST"
		ws[i,4] = invoice.orders.first.total_tax1
		ws[i+1,4] = "INVOICE TOTAL"
		ws[i+1,4] = invoice.orders.first.total_value

		i = i + 4
	end
	sum1 = "=IF(SUM(E$2:E$#{i})>0,ABS(SUM(E$2:E$#{i})),0)"
	sum2 = "=IF(SUM(E$2:E$#{i})<0,ABS(SUM(E$2:E$#{i})),0)"
	
	i = i + 2

	ws[i,3] = "Overcharged to #{c.business_name}"
	ws[i,4] = sum1
	ws[i+1,3] = "Undercharged by Subscribility"
	ws[i+1,4] = sum2
	ws.save
end