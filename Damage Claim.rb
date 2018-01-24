Dir.glob("#{Rails.root}/lib/tasks/helpers/*.rb") {|file| require file}
include RakeHelper

supported_providers = {
      "AuspostS99" => {
        :instructions => "Damaged goods must be presented in a post office to complete a damage report. The form, item and packaging must be left at the post office for processing. Some documents may be requested (statutory declaration, proof of identity, postage, point of sale receipt...). ",
        :pretty_name => "Australia Post (Community account)"
        },
     "Fastway" => {
      :instructions => "Please fill Fastway's form: http://www.fastway.com.au/courier-services/track-your-parcel/online-enquiry-form. ",
      :pretty_name => "Fastway (Postpaid)"
    }
   } 

session = RakeHelper::init_google_session
    # There is a dedicated folder for insurance claims: 
    # https://drive.google.com/drive/u/1/folders/0B1V-QHnRwtJPXzVjVElVd05FdW8
    insurance_claims_folder_id = "0B1V-QHnRwtJPXzVjVElVd05FdW8"
    
    loop do
      # Starting from the tracking code, since it is the most direct way to 
      # both a folder in Drive and a shipment record in the database
      tracking_code = RakeHelper::stdin_for_regex(//,"What is the tracking code for the damaged parcel? ").upcase

      # Find the shipment based on the tracking code
      shipments = Shipment.where("tracking_code like ?", "%#{tracking_code}%")

      if shipments.present? 

        if shipments.count == 1
          s = shipments.first
        else
          choices = shipments.pluck(:id, :name, :delivery_address, :delivery_area, :shipment_date).map do |s|
            [s[0], "#{s[1]}, #{s[2]} - #{s[3]} - Shipped on #{s[4]} - Order total: $#{s.order.total_value.to_f}"]
          end

          s_id = RakeHelper::pick_from_array(choices, "Multiple shipments with a matching tracking code found. Select one: ")
          s = Shipment.find(s_id) if s_id.present? 
        end

        # We might have had incomplete input of the tracking code earlier. 
        # Let's get the actual value now. 
        tracking_code = s.tracking_code
        company = s.company
        customer = s.customer
        shipment_date = s.shipment_date.strftime('%y%m%d')
        shipment_count = s.manifest.shipments.count

        RakeHelper::gputs "Shipment found. Here are the details: ", "\n"
        RakeHelper::pputs "Account name: " + "#{company.business_name}, shipping carrier: #{s.ship_carrier_pref}"
        RakeHelper::pputs "Delivery details: #{s.name}, #{s.delivery_address}, #{s.delivery_area}\n"

        # We have nothing to do if the shipping carrier isn't one of ours
        if supported_providers[s.ship_carrier_pref].blank? 
          RakeHelper::rputs "This shipping carrier is a private account. The claim must be lodged by the account holder (#{company.business_name}) directly. "
        else

          spreadsheet = RakeHelper::init_google_sheet("Shipping Damage Claim (Responses)", session)
          wsheet = RakeHelper::init_google_worksheet("Form responses 1", spreadsheet, session)
          # look for an existing row with the tracking code
          row_in_journal_of_claims = nil
          
          col=(RakeHelper::pick_from_array(Hash[(0...wsheet.rows[row-1].size).zip wsheet.rows[row-1]], "What column contains the Tracking Code stored in?").to_i + 1)

          wsheet.rows(skip=1).each_with_index do |row,index|
            # wsheet.list assumes the first row is a header
            row = wsheet.list[index] if (wsheet.list[index][col] == tracking_code)
          end

          if row.blank?
            RakeHelper::rputs("The Shipping damage claim form does not seem to have been filled yet. Get the form to be filled before continuing: https://goo.gl/forms/0Qhhu4E7Sgij3XpD2") 
            break
          end

          folder_name = "#{shipment_date}, damage claim case #: {case_number}, Provider: #{s.ship_carrier_pref}, Consignment number: #{tracking_code}, #{company.legal_name} (id: #{company.id}), #{customer.fullname} (id: #{customer.id})"
          folder = RakeHelper::init_google_folder folder_name, "0B1V-QHnRwtJPXzVjVElVd05FdW8", session, s.tracking_code #"Insurance Claims"           

          # We normally create the folder before the claim is lodged, 
          # so there is no case number yet. Let's add it to the folder name when we have it
          if folder.title.include?("{case_number}") && 'y' == RakeHelper::stdin_for_regex(/y|n/,"Do you have a case number for this claim? (y|n)")
            case_num = RakeHelper::stdin_for_regex(//,"Enter the case number: ")
            new_title = folder.title.gsub(/\{case_number\}/, case_num)
            folder.rename(new_title)
          end


          # PICK PRODUCTS w qty
          dam_ols = []
          
          dam_id=(RakeHelper::pick_from_array(s.order.orderlines.pluck(:id,:name), "What product was damaged?").to_i)
          dam_ol=Orderline.find(dam_id);
          dam_qty = dam_ol.qty.to_i
          if (dam_qty > 1) {
            dam_qty = RakeHelper::stdin_for_regex(/\d{1,2}/,"How many were damaged? (max #{dam_qty})")
          }
          dam_ol.qty = dam_qty
          dam_ols << dam_ol

          damage_breakdown = ''
          retail_value = dam_ols.map{ |ol| damage_breakdown += "#{ol.name} (#{ol.qty.to_i} @ $#{ol.price})\n"; ol.price * ol.qty }.sum

          damage_breakdown += "Shipping fee ($#{s.shipping_cost.to_f})"


          RakeHelper::gputs "Use the following folder: #{folder.title}"
          RakeHelper::gputs "Folder url: " + folder.human_url
          RakeHelper::yputs "\nIn the folder above, include the following documents: ", ""
          RakeHelper::pputs "\t- Photographs of damaged goods and labels. "
          RakeHelper::pputs "\t- Invoice for this shipment (should be automatically uploaded). "

          # UPLOAD INVOICE AUTOMATICALLY
          # #upload_from_io(io, title = 'Untitled', params = {}) ⇒ Object
          # FIXME: For some reason, the resulting file is not a pretty pdf, but an ugly Google doc
          invoice_pdf = s.order.invoice.document
          invoice_file = open(invoice_pdf.data.url) # an IO-like object
          uploaded_file = session.upload_from_io(invoice_file, s.order.invoice.document.filename, :content_type => "application/pdf")
          folder.add(uploaded_file)

          # We only need to email if that hasn't been done yet
          # Send email to help@subscribility, shipping provider, winery
          # Check if the claim has already been lodged
          if row_in_journal_of_claims["Claim lodged?"].blank?
            billing_users_ids = company.company_users.where(is_billing: true).pluck(:user_id)
            billing_users_emails = company.users.where(id: billing_users_ids).pluck(:email).join(", ")

            RakeHelper::gputs "Follow the instructions below for #{supported_providers[s.ship_carrier_pref][:pretty_name]}.\n"
            RakeHelper::yputs "", supported_providers[s.ship_carrier_pref][:instructions]

            # Set the Claim lodged? column to true
            row_in_journal_of_claims["Claim lodged?"] = Time.zone.now
            wsheet.save
          end
          
          if row_in_journal_of_claims["Company has been credited?"].blank?
            if 'y' == RakeHelper::stdin_for_regex(/y|n/,"Would you like to add a credit against #{company.legal_name}'s account regarding this claim? (y|n)")
              # TODO: Bring a while loop here to allow for fixing errors
              # The regex /^\d{1,}\.?\d{0,2}$/ is here to ensure we have a number as an input
              
              if "y" == RakeHelper::stdin_for_regex(/y|n/,"Credit of $#{total_refund_value} (Goods: $#{value_of_goods}, Postage: $#{value_of_postage}) for #{company.legal_name}. Confirm? (y|n)")
                ledger = Ledger::insurance_claim(company.id, "Refund for parcel damage (Goods: $#{value_of_goods}, Postage: $#{value_of_postage}) <a href=\"#{folder.human_url}\" target=\"_blank\">#{s.tracking_code}</a>", total_refund_value)
                if ledger
                  # Set the "Company has been credited?" column to true
                  row_in_journal_of_claims["Company has been credited?"] = Time.zone.now
                  RakeHelper::gputs("The adjustment was successfully created. ")
                else
                  row_in_journal_of_claims["Company has been credited?"] = "false"
                  RakeHelper::rputs("There was an error when creating the adjustment. ")
                end
                wsheet.save
              end
            end
          end
        end
      else
        RakeHelper::rputs "No shipment found. "
      end
      break if 'n' == RakeHelper::stdin_for_regex(/y|n/,"Search for another tracking code? (y/n)")
    end