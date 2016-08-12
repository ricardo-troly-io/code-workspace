Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper
ws = init_google_worksheet

############
# data starts at row 2, ws[2,1]

ws.rows.each_with_index do |row, index|
	# First row is headers, skip it
	next if index == 1
	puts row[0]
	# Find the shipment for that row's order
	s = Shipment.where(order_id: row[0]).first
	# row[3] has the barcode
	s.tracking_code = row[3]
	# if something was not saved, for one reason or another, place it at the end of the worksheet
	result = s.save.to_s
end