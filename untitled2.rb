errors = {}

Ledger.where(:ref => 'paid', :recon_id => nil).where.not(:aba => nil).where.not(:aba => '1999-01-01 00:00:00').pluck(:aba).uniq.each do |aba_date|

	next if aba_date.year < 2015
	doc = Document.where(:document_type => 'aba', :created_at => (aba_date - 1.hour)..(aba_date + 1.hour))

	if (doc.count != 1)
		#puts "more than one document??? #{aba_date} -> #{doc.count}"
		#next
	end

	doc.each do |d|
		aba_name = "#{d.data.file.public_id}"
		url = "#{d.data.url}"

		funds = Ledger.where(:aba => aba_date, :fees => nil).sum(:funds).to_f.abs
		fees = Ledger.where(:aba => aba_date).sum(:fees).to_f

		
		file = open(url){|f| f.read }
		aba_total = file.split("\n").last[22..29].to_f/100
		aba_lines = file.split("\n")

		aba_lines[1..aba_lines.count-2].each do |line|

			company_id = line[62..66]

			next if company_id == 'Fees '

			if Integration.where(:company_id => company_id, :provider => 'Commweb', :status => 'ready').blank?

				puts "#{line}\t#{company_id}\t#{aba_date}\t#{url}"
				co = line[30..61]
				desc = line[62..79]
				amt = line[22..29].to_f/100
				bank = "BSB #{line[1..7]}, ACCT #{line[8..16]}"

				errors[company_id] = [] if errors[company_id].nil?
				errors[company_id] << [line,url,amt]

			end
		end
	end
	
end