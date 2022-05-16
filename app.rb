require "dotenv/load"
require "sinatra"
require "json"
require "logger"

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

configure do
    set :environment, :production
    set :server, :puma
    set :bind, '0.0.0.0'
    set :port, 9292
    set :protection, :except => [:json_csrf]
end

helpers do
    def json_status(code, reason)
        status code
        {
          :status => code,
          :message => reason
        }.to_json
      end
end

def verify_signature(payload_body)
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), ENV['NEXUDUS_SECRET'], payload_body).downcase
    return halt 403, "Signatures don't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_NEXUDUS_HOOK_SIGNATURE'].downcase)
end

#Endpoints
get "/" do
    {"Status": "Watermoor Point Workflow Automation is running!"}.to_json
end


post "/nexudus/webhook/:event" do
    request.body.rewind
    payload_body = request.body.read
    verify_signature(payload_body)

    ENV["booking"] = payload_body

    begin
        unless payload_body.empty?
           #Trigger workflow
           Process.fork do
            system "bundle exec pallets -r ./workflow/watermoorbooking"
              Process.exit
           end 
           json_status 200, "OK" 
        else 
           json_status 400, "Bad Data"
        end 
     rescue 
        json_status 400, "Bad Request"
     end 
end

get "*" do
    status 404
 end
 
 put "*" do
    status 404
 end
 
  post "*" do
    status 404
 end
 
  delete "*" do
    status 404
 end
 
 not_found do
    json_status 404, "Not found"
 end
 
 error do
    json_status 500, env['sinatra.error'].message
 end
 