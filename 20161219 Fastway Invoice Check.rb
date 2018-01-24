Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper

session = RakeHelper::init_google_session
col=nil;

loop do

	wsheet = RakeHelper::init_google_worksheet nil, "Fastway Invoices Reconciliation", session

	row=4
	
	if col.nil?
		col=(RakeHelper::pick_from_array(Hash[(0...wsheet.rows[row-1].size).zip wsheet.rows[row-1]], "What column is the Label Number stored in?").to_i + 1)
	end

	while (row+=1) <= wsheet.num_rows
		l = wsheet[row,col]

		s=Shipment.where("provider_data LIKE '%#{l}%'")
		if s.count > 1
			puts "#{l} appears twice??"
		else
			s=s.last

			name = s.name.split(' - ').first.gsub("'",'\'')
			range = (s.created_at - 2.weeks)..(s.created_at + 2.weeks)
			ledger = s.company.ledgers.where(:ref => 'shpf', :fees => (s.shipping_cost * -1), :created_at => range).where("description LIKE '%#{name}%'")

			charged = ledger.present? ? "(charged ".white + "✓".green + ")".white : "(charged ".white + "✘".red + ")".white

			if s.provider_data[:final].blank?
				RakeHelper::rputs "#{l} was not shipped? #{charged}"
			elsif s.provider_data[:final].select{ |f| f["base_label_number"] == l }.present?
				RakeHelper::pputs "#{l} found, BASE label #{charged}"
			elsif s.provider_data[:final].select{ |f| f["excess_label_numbers"].include? l }.present?
				RakeHelper::pputs "#{l} found as EXCESS #{charged}"
			else
			
				#s.provider_data[:final].each do |pd|
				#	next if pd[:final].nil?; 
				#	pd[:final].each{|f| puts f["base_label_number"] }
				#	pd[:final].each{|f| puts f["excess_label_numbers"] }
				#end
			
				RakeHelper::rputs "#{l} was not found? #{charged}" 
			end
		end
	end;

	## ask to push to xero if no problem found
	
	break unless 'y' == RakeHelper::stdin_for_regex(/y|n/,"Do you wish to process another tab? (y|n)");
end;nil






