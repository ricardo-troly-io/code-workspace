# For a given company, we will need to go ahead and check it's products
# Any outputted data needs to be reviewed

def check_encoding_for_company company
	coder = HTMLEntities.new
	pcs = Product.column_names.uniq!
	company.products.where(:archived_at => nil).each do |prod|
		pcs.each do |col|
			begin
				prod.send(col).to_s.encode('windows-1252') 
			rescue Encoding::UndefinedConversionError
				puts "#{prod.id} / #{col} / #{strip_tags(coder.decode(p1.description))}"
			end
		end
	end
end