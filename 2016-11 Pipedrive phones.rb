contact_id=7203
token='f5daf99190a7cbe95b1c4b2169196ea4b76d438b'

url="https://api.pipedrive.com/v1/persons/#{contact_id}?api_token=#{token}"

new_phones=[{"label"=>"home","value"=>"029 938 2891","primary"=>false},{"label"=>"work", "value"=>"+14158413802", "primary"=>true}]

HTTParty.put(url, :body => { :phone => new_phones }.to_json, :headers => { 'Content-Type' => 'application/json'} )

HTTParty.put(url, :body => { :phone => new_phones }.to_json, :headers => { "User-Agent"    => "Ruby.Pipedrive.Api", "Accept"        => "application/json", "Content-Type"  => "application/x-www-form-urlencoded" } )



Pipedrive.authenticate(token)
p=Pipedrive::Person.find(contact_id)
p.update({:phone => new_phones}.to_json)