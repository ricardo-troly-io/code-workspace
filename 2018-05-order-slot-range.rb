ct = Company.find 10225;

ct.memberships.current.order(membership_type_id: :asc, id: :asc).each do |mem|
	r1 = mem.customer.orders.where(:membership_id => [nil,mem.id]).where.not(:status => 'cancelled').order(id: :desc)
	recent = nil
	using_from = false
	r1.each do |rr|
		next unless rr.total_qty >= mem.delivery_size
		recent = rr
		break
	end
	if recent.nil?
		r1 = mem.customer.orders.where(:membership_id => [nil,mem.from_id], :created_at => (mem.customer.created_at..mem.starts_at)).where.not(:status => 'cancelled').order(id: :desc)
		recent = nil
		using_from = true
		r1.each do |rr|
			next unless rr.total_qty >= mem.delivery_size
			recent = rr
			break
		end
	end
	
	if recent.nil?
		puts [mem.id, mem.membership_type.name, mem.customer.name, " has no order"].join("\t")
		next
	elsif recent.status == 'template'
		puts [mem.id, mem.membership_type.name, mem.customer.name, " has template order"].join("\t")
		next
	elsif recent.membership_shipment_number.to_i > 0
		puts [mem.id, mem.membership_type.name, mem.customer.name, " has previous membership order"].join("\t")
		next
	elsif mem.next_delivery_date.blank?
		puts [mem.id, mem.membership_type.name, mem.customer.name, " has no next delivery date"].join("\t")
		next
	elsif mem.next_delivery_date.to_date > Date.parse('2018-06-07')
		puts [mem.id, mem.membership_type.name, mem.customer.name, " next delivery date beyond June 6"].join("\t")
		next
	end
	
	sr = mem.membership_type.slot_range.to_i
	if sr == 0
		puts [mem.id, mem.membership_type.name, mem.customer.name, " has range of zero"].join("\t")
		next
	end
	
	closest_n = (using_from ? Membership.find(mem.from_id) : mem).get_closest_shipment_number(recent.created_at.to_date)
	snum = (using_from ? Membership.find(mem.from_id) : mem).get_next_shipment_number
	# exo = mem.customer.orders.where(:membership_id => mem.id, :membership_shipment_number => closest_n).where.not(:status => ['cancelled', 'template']).last
	
	q = (mem.orders.where(:membership_shipment_number => snum).where.not(:status => 'cancelled').first)
	
	if q.present? && closest_n.to_i != snum.to_i 
		puts [mem.id, mem.membership_type.name, mem.customer.name, '=HYPERLINK("https://app.troly.io/c/'+mem.customer_id.to_s+'/o/'+recent.id.to_s+'/edit?from=activity", "'+recent.number.to_s+'")', " recent should have consumed #{closest_n} / #{snum}"].join("\t")
		next
	end
	
	if q.present? && q.number == recent.number
		puts [mem.id, mem.membership_type.name, mem.customer.name, '=HYPERLINK("https://app.troly.io/c/'+mem.customer_id.to_s+'/o/'+recent.id.to_s+'/edit?from=activity", "'+recent.number.to_s+'")', " next shipment has already been assigned"].join("\t")
		next
	end
	
	
	snum = mem.get_next_shipment_number
	
	if !using_from && mem.slot_skipped?(snum)
		puts [mem.id, mem.membership_type.name, mem.customer.name, " is skipped"].join("\t")
		next
	end

	ddate = mem.send("delivery_date_#{snum}")
	if !using_from && recent.created_at.between?(ddate - sr.weeks, ddate + sr.weeks) && recent.total_qty >= mem.membership_type.delivery_size
		# recent.update_columns({:membership_shipment_number => snum, :membership_id => mem.id})
		puts [mem.id, mem.membership_type.name, mem.customer.name, '=HYPERLINK("https://app.troly.io/c/'+mem.customer_id.to_s+'/o/'+recent.id.to_s+'/edit?from=activity", "'+recent.number.to_s+'")', snum].join("\t")
	else
		if recent.total_qty < mem.membership_type.delivery_size
			puts [mem.id, mem.membership_type.name, mem.customer.name, '=HYPERLINK("https://app.troly.io/c/'+mem.customer_id.to_s+'/o/'+recent.id.to_s+'/edit?from=activity", "'+recent.number.to_s+'")', '0', "Does not meet qty requirements #{recent.total_qty} / #{mem.membership_type.delivery_size}"].join("\t")
		elsif(recent.created_at.between?(ddate - sr.weeks, ddate + sr.weeks))
			#puts [mem.id, mem.membership_type.name, mem.customer.name, '=HYPERLINK("https://app.troly.io/c/'+mem.customer_id.to_s+'/o/'+recent.id.to_s+'edit/?from=activity", "'+recent.number.to_s+'")', "No change - created #{recent.created_at.to_date}, must be no earlier than #{ddate - sr.weeks})"].join("\t")
			# recent.update_columns({:membership_shipment_number => snum, :membership_id => (using_from ? mem.from_id : mem.id)})
			qld = (using_from ? 'Inside OLD Range' : 'Inside Range')
			puts [mem.id, mem.membership_type.name, mem.customer.name, '=HYPERLINK("https://app.troly.io/c/'+mem.customer_id.to_s+'/o/'+recent.id.to_s+'/edit?from=activity", "'+recent.number.to_s+'")', snum, qld, recent.membership_id].join("\t")
		else
			if using_from
				qld = 'OLD TIME ORDER'
			else
				qld = 'ANY TIME ORDER'
			end
			# recent.update_columns({:membership_shipment_number => snum, :membership_id => (using_from ? mem.from_id : mem.id)})
			puts [mem.id, mem.membership_type.name, mem.customer.name, '=HYPERLINK("https://app.troly.io/c/'+mem.customer_id.to_s+'/o/'+recent.id.to_s+'/edit?from=activity", "'+recent.number.to_s+'")', snum, qld, recent.membership_id].join("\t")
		end
	end
end;

ct.memberships.current.order(membership_type_id: :asc, id: :asc).each do |mem|
	mem.send("update_next_delivery_date")
	mem.save
end
