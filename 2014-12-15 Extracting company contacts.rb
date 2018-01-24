Company.where(:is_fake => false).each do |c|
  c.company_users.each do |cu|
    if cu.user.blank?
      cu.delete
    elsif cu.user.email.match(/craigwhealey|empireone|subscribility/).blank?
      cid = c.id
      cid *= -1 if [nil,''].include?(c.cc_number) 
      puts "#{cu.user.email}\t#{cu.user.fname}\t#{cu.user.lname}\t#{c.business_name}\t#{cid}\t#{c.cc_on_file}"
    end
  end
end;nil



CompanyUser.joins(:user).where("fname LIKE '% %'").each do |cu|
  print cu.user
    cu.user.lname = cu.user.fname.split(' ')[1]
    cu.user.fname = cu.user.fname.split(' ')[0]
  puts " - now #{cu.user.fname} AND #{cu.user.lname}"
  cu.user.save!
end;nil