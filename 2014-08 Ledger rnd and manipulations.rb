2500.times do

  #
  # Generate Random Seeds/Ledger data for testing balance_ledger

  rand(15).times do
    Ledger::owed_to_subscribility [2,3].sample, rand(1356).to_f/100, 'shpf', 'shipping fee'
  end

  rand(15).times do
    l = Ledger::paid_into_subscribility [2,3].sample, rand(99999).to_f/100, 'payment received'
    Ledger::owed_to_subscribility l.company_id, l.funds*0.1, 'payf', 'payment fee'
  end

  rand(15).times do
    Ledger::owed_to_subscribility [2,3].sample, 0.10, 'smsf', 'sms fee'
  end
end


Ledger.where(:company_id => 10024).where("description LIKE '%Commweb%'").each do |l|
  l.description = l.description.gsub('Commweb', 'gateway')
  l.save!
end

# Adjust previous ledger entries to reflect the proper rate.
Ledger.where(:company_id => 10024, :ref => 'payf').where("description LIKE 'Master%2.95%'").each do |l|
  if matches = l.description.match(/2\.95[^\d]*(\d{3}\.\d{1,2})/)
    l.description = l.description.gsub('2.95', '1.90')
    fee = (0.30 + (matches[1].to_f * 0.019)) * -1
    puts " was '#{l.fees}', now '#{fee}'"
    l.fees = fee
    l.save!
  end
end