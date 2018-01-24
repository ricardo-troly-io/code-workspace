Company.where(:is_fake => false, :is_locked => false).where.not(:cc_number => ['',nil]).count



##
## Company First Payment timeframe
##


puts "company_id\tbusiness_name\tcreated_at\tfirst_payment_at"
Company.where(:is_fake => false, :is_locked => false).where.not(:cc_number => ['',nil]).each do |c|
    p = c.payments.where.not(:customer_id => nil).where(:trx => 'charge', :status =>'success').first
    p = p ? p.created_at : 'N/A'
    puts "#{c.id}\t#{c.business_name}\t#{c.created_at}\t#{p}"
end;nil