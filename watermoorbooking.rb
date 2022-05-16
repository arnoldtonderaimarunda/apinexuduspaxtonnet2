require 'dotenv/load'
require 'pallets'
require 'net/http'
require 'uri'
require 'json'
#require 'mail'

require_relative 'lib/nexudus'
require_relative 'lib/net2'

class MyLog
    def self.log
      if @logger.nil?
        @logger = Logger.new STDOUT
        @logger.level = Logger::DEBUG
        @logger.datetime_format = '%Y-%m-%d %H:%M:%S '
      end
      @logger
    end
  end



Pallets.configure do |c|
  c.concurrency = 2
  c.backend = :redis
  c.pool_size = 5
  c.job_timeout = 600
  c.max_failures = 5
end

class ParseNexudusData < Pallets::Task
    def run
        #Parse fields from data object
        puts 'parsing...Nexudus Booking Data'
        JSON.parse(context['form']).select do |booking|
            puts context['coworker_id'] = booking["CoworkerId"]
            puts context['fullname'] = booking["CoworkerFullName"].split(' ')
            puts context['activatedate'] = booking["FromTime"]
            puts context['expirydate'] = booking["ToTime"]
            puts context['resource'] = booking["ResourceName"]
        end
        
        #Get user email address from Nexudus
        puts context['email'] = getNexudusMemberEmail!(authoriseNexudus!, context['coworker_id'])

        #Split Name
        case context['fullname'].count
        when 2
            puts context['firstname'] = context['fullname'][0].strip
            puts context['middlename'] = nil
            puts context['lastname'] =context['fullname'][1].strip
        when 3
            puts context['firstname'] = context['fullname'][0].strip
            puts context['middlename'] = context['fullname'][1].strip
            puts context['lastname'] = context['fullname'][2].strip
        end
      
    end 
end 


class AddNet2User < Pallets::Task
    def run
        puts 'Get authorisation to use Net2 API'
        #get authorisation to use Net2 API
        net2_token = authoriseNet2!
        userid = findNet2User!(
            net2_token, 
            context['firstname'],
            context['middlename'],
            context['lastname']
        )

        case userid.nil?
        when true
            #Add new user
            puts "Adding new user to Net2"
            user = addNet2User!(
                net2_token,
                context['firstname'],
                context['middlename'],
                context['lastname'],
                context['activatedate'],
                context['expirydate']
            )
            puts user.inspect
            puts userid = user["id"]
        when false
            #Update existing user
            puts "Update existing userId: #{userid}"
            user = updateNet2User!(
                net2_token,
                userid,
                context['firstname'],
                context['middlename'],
                context['lastname'],
                context['activatedate'],
                context['expirydate']
            )
            puts user.inspect
        end

        #Associate user with department i.e Watermoor Point
        puts "Associate Department"
        associateNet2Dept!(
            net2_token,
            userid,"2"
        )
  end 
end 

class GetNet2Token < Pallets::Task
  def run
        puts 'Get Net2 Door Token'
      
    end 
end 

class SendEmail < Pallets::Task
  def run
      puts "sending...token to #{context['email']}"
      sendEmail(
        context['email'],
        context['firstname'],
        context['lastname']
      )
  end
end


class WatermoorBookingnWorkflow < Pallets::Workflow
    task 'ParseNexudusData' 
    task 'AddNet2User' => 'ParseNexudusData'
#    task 'GeNet2Token' => ,'AddNet2User'
#    task 'SendEmail' => 'GetNet2Token'
 
end

=begin
ENV['booking'] = {
    "ResourceId": 1414925063,
    "ResourceName": "Small meeting room (120)",
    "ResourceHideInCalendar": false,
    "ResourceResourceTypeId": 1414984685,
    "ResourceResourceTypeName": "Meeting room",
    "FloorPlanDeskId": nil,
    "FloorPlanDeskName": nil,
    "CoworkerId": 1415914201,
    "CoworkerCoworkerType": "Individual",
    "CoworkerFullName": "Workflow Automation Expert",
    "CoworkerBillingName": nil,
    "CoworkerCompanyName": nil,
    "CoworkerTeamNames": nil,
    "ExtraServiceId": nil,
    "ExtraServiceName": nil,
    "FromTime": "2022-05-13T23:00:00Z",
    "ToTime": "2022-05-14T00:00:00Z",
    "Notes": nil,
    "InternalNotes": nil,
    "ChargeNow": false,
    "InvoiceNow": false,
    "DoNotUseBookingCredit": false,
    "PurchaseOrder": nil,
    "DiscountCode": nil,
    "Tentative": true,
    "Online": false,
    "TeamsAtTheTimeOfBooking": nil,
    "TariffAtTheTimeOfBooking": nil,
    "RepeatSeriesUniqueId": nil,
    "RepeatBooking": false,
    "Repeats": 2,
    "WhichBookingsToUpdate": 1,
    "RepeatEvery": nil,
    "RepeatUntil": nil,
    "RepeatOnMondays": false,
    "RepeatOnTuesdays": false,
    "RepeatOnWednesdays": false,
    "RepeatOnThursdays": false,
    "RepeatOnFridays": false,
    "RepeatOnSaturdays": false,
    "RepeatOnSundays": false,
    "OverridePrice": nil,
    "Invoiced": false,
    "InvoiceDate": nil,
    "CoworkerInvoiceId": nil,
    "CoworkerInvoiceNumber": nil,
    "CoworkerInvoicePaid": false,
    "CoworkerExtraServiceIds": nil,
    "CoworkerExtraServicePrice": nil,
    "CoworkerExtraServiceCurrencyCode": nil,
    "CoworkerExtraServiceChargePeriod": nil,
    "CoworkerExtraServiceTotalUses": nil,
    "IncludeZoomInvite": false,
    "CheckedInAt": nil,
    "CancelIfNotPaid": false,
    "CancelIfNotCheckedIn": false,
    "MinutesToStart": 124,
    "OverrideResourceLimits": true,
    "DisableConfirmation": false,
    "SkipGoogleCalendarUpdate": false,
    "EstimatedCost": nil,
    "EstimatedCostWithProducts": nil,
    "EstimagedCost": nil,
    "EstimatedProductCost": nil,
    "ChargedExtraServices": nil,
    "BookingProducts": nil,
    "BookingVisitors": [],
    "EstimatedExtraService": nil,
    "Invoice": nil,
    "AvailableCredit": 0,
    "IsEvent": false,
    "IsTour": false,
    "DiscountAmount": nil,
    "Id": 1418686279,
    "UpdatedOn": "2022-05-13T20:55:44.5515198Z",
    "CreatedOn": "2022-05-13T20:55:44.5405881Z",
    "UniqueId": "d7ac5d56-9286-41f7-81c2-b768748e76e0",
    "UpdatedBy": "hello@workflowautomation.expert",
    "IsNew": false,
    "SystemId": nil,
    "ToStringText": "Small meeting room (120)",
    "LocalizationDetails": nil,
    "CustomFields": nil
}.to_json
=end
WatermoorBookingnWorkflow.new(form: ENV['booking']).run