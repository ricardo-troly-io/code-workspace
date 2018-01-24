def weekly_summary range = Time.now.beginning_of_week..Time.now.end_of_week

  res = ['']
  res << "New companies: " + Company.where(:created_at => range).count.to_s
  res << "Companies w cc: " + Company.where.not(:cc_number => [nil,'']).count.to_s
  res << "Companies LIVE: " + Company.where(:is_test => false).count.to_s
  res << "Total companies: " + Company.count.to_s
  res << ""
  res << "Payments: " + Payment.where(:created_at => range).count.to_s
  res << "Orders: " + Order.where(:created_at => range,:status => ['draft','in-progress','confirmed']).count.to_s
  res << "Shipments: " + Shipment.where(:created_at => range).where.not(:status => 'cancelled').count.to_s
  res << "Emails: " + Email.where(:created_at => range).count.to_s

  res << "Order value: " + Order.where(:created_at => range,:status => ['draft','in-progress','confirmed']).sum(:total_value).to_s
  res << "Customer signins: " + User.where.not(:customer_id => [nil,'']).where(:last_sign_in_at => Time.now.beginning_of_week..Time.now.end_of_week).count.to_s

end

puts weekly_summary