new_users = [
  { :email => 'vanessa.neal@hungerfordhill.com.au',       :fname => 'Vanessa',    :lname => 'Neal' },
  { :email => 'mitchell.beattie@hungerfordhill.com.au',   :fname => 'Mitchell',   :lname => 'Beattie' },
  { :email => 'adrian.lockhart@hungerfordhill.com.au',    :fname => 'Adrian',     :lname => 'Lockhart' },
  { :email => 'james.kirby@hungerfordhill.com.au',        :fname => 'James',      :lname => 'Kirkby' },
  { :email => 'brad.russ@tullochwines.com',               :fname => 'Brad',       :lname => 'Russ' },
  { :email => 'loretta@thistlehill.com.au',               :fname => 'Loretta',    :lname => '' },
  { :email => 'wines@ernesthillwines.com.au',             :fname => 'Ross',       :lname => '' },
  { :email => 'wines@ernesthillwines.com.au',             :fname => 'Ross',       :lname => '' },
  { :email => 'info@burrundulla.com.au',                  :fname => 'Ted & Wendy',:lname => '' },
  { :email => 'marketing@huntingtonestate.com.au',        :fname => 'Nicole',     :lname => '' },
  { :email => 'mansfieldwines@bigpond.com',               :fname => 'Malcom',     :lname => '' },
  { :email => 'tom@vendhq.com',                           :fname => 'Tom',        :lname => 'Freeman' },
  { :email => 'mark@toppers.com.au',                      :fname => 'Mark',       :lname => 'Kirkby' },
  {}
]

company_ids = [ 1000 ]

new_users.each do |details|
  next if details[:email].blank?

  company_ids.each do |cid|

    c = Company.find(cid) # will crash if cid is not valid

    u = User.where("lower(email) = ?", details[:email].downcase).first

    if u.blank?
      pwd = SecureRandom.hex[0..16]
      u = User.create! :email => details[:email], :fname => details[:fname], :lname => details[:lname], :password => pwd, :password_confirmation => pwd, :companies => [c]
      u.send_reset_password_instructions
      puts "#{details[:fname]} was not found and created (#{u.id}).".yellow
    end
    
    cu = CompanyUser.find_or_initialize_by(:company_id => c.id, :user_id => u.id)
    if cu.new_record?
      puts "#{details[:fname]} was added as admin of #{c.business_name}"
    else
      puts "#{details[:fname]} was made an admin of #{c.business_name}"
    end
    cu.is_admin = true
    cu.save!
  end
end
