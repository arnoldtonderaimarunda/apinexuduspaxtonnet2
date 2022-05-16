require 'json'
require 'logger'
require 'net/http'
require 'uri'
require 'dotenv/load'

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
  
  
def authoriseNexudus!()
    uri = URI.parse("https://spaces.nexudus.com/api/token")
    request = Net::HTTP::Post.new(uri)
    request.set_form_data(
    "username" => ENV["NEXUDUS_USERNAME"],
    "password" => ENV["NEXUDUS_PASSWORD"],
    "grant_type" => "password"
    )

    req_options = {
    use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
    end
  
    return JSON.parse(response.body)['access_token']
end

def getNexudusMemberEmail!(access_token,coworker_id)
    uri = URI.parse("https://spaces.nexudus.com/api/spaces/coworkers/#{coworker_id}")
    request = Net::HTTP::Get.new(uri)
    request.content_type = "application/json"
    request["Accept"] = "application/json"
    request["Authorization"] = "Bearer #{access_token}"

    req_options = {
    use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
    end

    # response.code
    return JSON.parse(response.body)['Email']
end



def authoriseNet2!()
    uri = URI.parse("http://localhost:8080/api/v1/authorization/tokens")
    request = Net::HTTP::Post.new(uri)
    request.set_form_data(
    "username" => ENV["NET2_USERNAME"],
    "password" => ENV["NET2_PASSWORD"],
    "grant_type" => "password",
    "client_id" => ENV["NET2_CLIENT_ID"]
    )

    req_options = {
    use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
    end
  
    return JSON.parse(response.body)['access_token']
end

def addNet2User!(access_token,firstname,middlename,lastname,activatedate,expirydate)
    uri = URI.parse("http://localhost:8080/api/v1/users")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{access_token}"
    request.body =  {
        "FirstName" => firstname,
        "MiddleName" => middlename,
        "LastName" => lastname,
        "ExpiryDate" => expirydate,
        "ActivateDate" => activatedate
    }.to_json

    req_options = {
    use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
    end

    return JSON.parse(response.body)
end

def updateNet2User!(access_token,id,firstname,middlename,lastname,activatedate,expirydate)
    uri = URI.parse("http://localhost:8080/api/v1/users/#{id}")
    request = Net::HTTP::Put.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{access_token}"
    request.body =  {
        "Id" => id,
        "FirstName" => firstname,
        "MiddleName" => middlename,
        "LastName" => lastname,
        "ExpiryDate" => expirydate,
        "ActivateDate" => activatedate
    }.to_json

    req_options = {
    use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
    end

    return JSON.parse(response.body)
end

def associateNet2Dept!(access_token,id,dept)
    uri = URI.parse("http://localhost:8080/api/v1/users/#{id}/departments")
    request = Net::HTTP::Put.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{access_token}"
    request.body =  {
        "Id" => dept
    }.to_json

    req_options = {
    use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
    end

end

def findNet2User!(access_token,fullname)
    #Get All Users
    uri = URI.parse("http://localhost:8080/api/v1/users")
    request = Net::HTTP::Get.new(uri)
    request.content_type = "application/json"
    request["Accept"] = "application/json"
    request["Authorization"] = "Bearer #{access_token}"

    req_options = {
    use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
    end

    # response.code
    JSON.parse(response.body).select do |user|
        case "#{user['firstName']} #{user['lastName']}".downcase
        when fullname.join(' ').downcase
            return user['id']
        end
    end
    return nil
end

booking = JSON.parse({
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
}.to_json)

puts coworker_id = booking["CoworkerId"]
puts fullname = booking["CoworkerFullName"].split(' ')
puts activatedate = booking["FromTime"]
puts expirydate = booking["ToTime"]
puts resource = booking["ResourceName"]

#Get user email address from Nexudus
email = getNexudusMemberEmail!(authoriseNexudus!,coworker_id)

#Split Name
case fullname.count
when 2
    firstname = fullname[0].strip
    middlename = nil
    lastname = fullname[1].strip
when 3
    firstname = fullname[0].strip
    middlename =fullname[1].strip
    lastname = fullname[2].strip
end

#get authorisation to use Net2 API
net2_token = authoriseNet2!
userid = findNet2User!(net2_token,fullname)
case userid.nil?
when true
    #Add new user
    puts "Adding new user to Net2"
    user = addNet2User!(net2_token,firstname,middlename,lastname,activatedate,expirydate)
    puts user.inspect
    puts userid = user["id"]
when false
    #Update existing user
    puts "Update existing userId: #{userid}"
    user = updateNet2User!(net2_token,userid,firstname,middlename,lastname,activatedate,expirydate)
    puts user.inspect

end

#Associate user with department i.e Watermoor Point
puts "Associate Department"
associateNet2Dept!(net2_token,userid,"2")

#Send token to user via email