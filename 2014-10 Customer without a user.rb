
#
# Make sure all customers have a user object attached.
# WARNING - this resets the password of existing users if not a new_record. code commented out was not tested.
#
#Customer.where(:id => CompanyCustomer.where(:company_id => 10035).pluck(:customer_id)).each do |c|
Customer.all.each do |c|
  if c.user.blank? && c.email.present?
    p = SecureRandom.base64
    u = User.find_or_initialize_by(:email => c.email)
    #if u.new_record?
    u.fname = c.fname
    u.lname = c.lname
    u.password = p
    u.password_confirmation = p
    end
    u.customer_id = c.id
    if u.valid?
      u.save!
      puts "#{c} was fixed".yellow
    else
      puts u
      puts c
      puts "CRAP".red
    end
    puts "#{c} was fixed".green
  else
   # puts "#{c} was correct".green
  end
end; nil

