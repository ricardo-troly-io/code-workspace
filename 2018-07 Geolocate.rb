# Pass a well-formatted address with street name, suburb, state
# Addresses use the same format and are an array in the format
# <data>,<data>,address (where <data> is optional)

[origin1, origin2].each do |origin|
	addresses.each do |row|
		if row.last.blank?
			puts [row[0],origin].join("\t")
			next
		end
		# Workout how long it will take _from_ the winery we want to target
		# _to_ the place we are hosting
		opts = {:key => Rails.configuration.integrations.google.api_key, :origin => row.last, :destination => origin}
		res = HTTParty.get("https://maps.googleapis.com/maps/api/directions/json?#{opts.to_param}")
		parsed = JSON.parse(res.body)
		parsed['routes'].each do |route|
			route['legs'].each do |leg|
				puts "#{row[0]}\t#{origin}\t#{row.last}\t#{leg['duration']['text']}\t#{leg['duration']['value']}"
			end
		end
		sleep(0.5)
	end;
end;