

Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") { |file| require file }
include RakeHelper



c=Company.find(10225)
ci = Integration.where(:company_id => c.id, :processor => 'Accounting', :status => 'ready').first
apiName = "Integrations::#{ci.provider}::Gateway"
api = apiName.constantize.new
api.init(ci, ci.params || {})
api.provider = ci.provider

range=Date.new(2017,2,1)..Date.new(2017,2,28)

while range.first < range.last
	do_date = range.first
	api.push_eod_invoice date:do_date
	do_date = do_date + 1.day
	range = do_date..range.last
	sleep 5
end


t=Tag.find(101)
c=Company.find(10332)
c.products.each do |p|
	if p.tags.select{|x| x.id == t.id}.blank?
		puts "✖ #{p.name} has no Wine Tax applied.".red 
		#p.tags << t
	else
		puts "✓ #{p.name} already has Wine Tax applied".green 
	end
end;nil


c.products.select{ |x| /20\d{2}/.match(x.name).blank? }.each do |p|
	puts "#{p.name}"
end;nil