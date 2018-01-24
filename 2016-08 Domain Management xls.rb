require 'google_drive'

config = {
	"client_id" => '977100031004-4499te7k5o3brtcqf8b7ecf9iabnksn7.apps.googleusercontent.com',
	"client_secret" => 'qOWPAd9h4Q-FyQ11GhXKT4Ia'
}

session = GoogleDrive.saved_session(config.to_json)

def whois_to_hash(url)
	whois = {}
	res = `whois #{url}`

	mode = res.split("\n\n").count ? "multi-line" : "single-line"
	
	res = (mode == "single-line" ? res.split("\n") : res.split("\n\n"))

	res.each do |line|
		next if line[0] == "" || line[0] == nil

		if mode == "multi-line"
			line = line.gsub("\n","").strip
		end

		line = line.split(":")

		next if line[1] == nil
		
		case whois[line[0]]
			when NilClass
				whois[line[0]] = ""
			when String
				whois[line[0]] = [whois[line[0]]]
		end
		
		puts line[0]
		
		if mode == "multi-line"
			#whois[line[0]] << line[1].gsub(/\s+/,"\n").split("\n")
		else
			whois[line[0]] << line[1].strip
		end
	end
	return whois
end

sheet = session.spreadsheet_by_key("1CGwdw5lXZ3-lt5rLzNb6zSxZ8ncVvMrIXNHk_OpFqIM")
ws = sheet.worksheet_by_title("Domains")

ws.rows.each do |row|
	next if row[1] == ""
	puts row[1]
	whois = whois_to_hash(row[1])

	if whois["Registrar Name"] != row[7]
		puts whois["Registrar Name"]
		puts row[7]
	end
end