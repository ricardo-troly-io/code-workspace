Ledger.all.each do |line|
	date = line.date.strftime('%d-%m-%y %H:%M')
	company = left_pad(line.company_id, 6)
	ref = left_pad(line.ref ,5)
	description = left_pad(line.description, 15) + '  '
	debit = left_pad(line.debit.to_f, 10)
	credit = left_pad(line.credit.to_f, 10)
	recon_id = left_pad(line.recon_id,6) + line.company_id.to_s
	aba = line.aba.present? ? line.aba.strftime('%d-%m-%y %H:%M') : ''

	puts date + company + ref + description + credit + debit + recon_id + aba
end