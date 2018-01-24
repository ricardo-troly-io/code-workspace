Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper

ref = '10064_112733_20170529'.split(/_\-/)


ref = RakeHelper::stdin_for_regex(/\d{5}[_\-]\d{5,6}[_\-]\d{8}/,"What is the payment reference number?").split(/[_\-]/)

c=Company.find(ref[0])
l_to_find=Ledger.find(ref[1])


xero = Xeroizer::PrivateApplication.new(Rails.application.config.subs_xero_key, Rails.application.config.subs_xero_secret, Rails.root.join('lib/integrations/xero/certs/privatekey.pem'))

c.ledgers.where(:date => (l_to_find.date-5.days)..(l_to_find.date)+5.days, :ref => 'paid').each do |l|
	
	RakeHelper::pputs "#{c.id}_#{l.id}_#{l.date.strftime('%Y%m%d')} ($#{l.funds.abs})"

	docs = Document.where(:created_at => l.transferred_at-10.seconds..l.transferred_at+10.seconds, :document_type => 'aba')

	docs.each do |doc|
		aba_name = doc.data.filename[0..-5].split("/")[1]

		bt = xero.BankTransaction.all(:where => {:reference => aba_name}).first

		if bt.present? 
			if bt.is_reconciled
				RakeHelper::gputs "Bank Transfer Confirmed as processed: #{aba_name}"
			else
				RakeHelper::yputs "Bank Transfer Received, but not processed: #{aba_name}"
				RakeHelper::pputs "Escalate to reprocess: #{doc.data.url}"
			end
		else
			RakeHelper::rputs "Bank Transfer Received, but on hold: #{aba_name}"
			RakeHelper::pputs "Escalate to reprocess: #{doc.data.url}"
		end
	end
end