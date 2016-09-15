c = Company.find 10280

groups = [
	{ label: "White", product_ids: [13138,13241,13240,13238,13139,13237,13141,13236] }, 
	{ label: "Red", product_ids: [13142, 13248, 13243, 13247, 13246, 13242, 13245, 13249, 13244] }, 
	{ label: "Rose",  product_ids: [13140,13239] }, 
	{ label: "Others", product_ids: [13252, 13253, 13250, 13251, 13143] }
]


('A'..'D').each_with_index do |letter, index|
	prods = c.products.where(id: groups[index][:product_ids]).order(:name)
	prods.each do |p|
		p.te_divider = groups[index][:label]
		p.sort_weight = letter + "%03d" % index
		p.save
	end
end
