require 'dotenv/load'
require 'pallets'
require 'net/http'
require 'uri'
require 'json'
require 'mail'

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
            context['firstname'] = context['fullname'][0].strip
            context['middlename'] = nil
            context['lastname'] =context['fullname'][1].strip
        when 3
            context['firstname'] = context['fullname'][0].strip
            context['middlename'] = context['fullname'][1].strip
            context['lastname'] = context['fullname'][2].strip
        end
    end 
end 


class ManageNet2User < Pallets::Task
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
            
            userid = user["id"]
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


class WatermoorBookingWorkflow < Pallets::Workflow
    task 'ParseNexudusData' 
    task 'ManageNet2User' => 'ParseNexudusData'
#    task 'GetNet2Token' => ,'ManageNet2User'
#    task 'SendEmail' => 'GetNet2Token'
end


WatermoorBookingWorkflow.new(form: ENV['booking']).run