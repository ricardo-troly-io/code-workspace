Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper
c=company_lookup



sheet_name = "#{c.business_name} (#{c.id}) - Management Reports"

RakeHelper::dputs "Google sheet dump as of #{sheet_name}"

wsheet = RakeHelper::init_google_worksheet("Transact [DO NOT EDIT]", sheet_name)

range = Date.new(2016,10,01)..Date.new(2016,10,31).end_of_day

groups = c.payments.where.not(:customer_id => nil).where(:trx => ['offline','charge'], :status => 'success', :created_at => range).group(:trx).count

groups.each do |k,v|
	oids = Invoice.where(:id => ).pluck(:order_id))
	Order.where(:invoice_id => c.payments.where(:trx => k, :status => 'success', :created_at => range).pluck(:invoice_id))
	c.orders.where(:where => od)
end


