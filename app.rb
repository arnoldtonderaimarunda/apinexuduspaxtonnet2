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

    unless payload_body.empty?
        status 200
        system "bundle exec pallets -r ./workflow/watermoorbooking"
    else
        status 400
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
    status 404
end

error do
    status 500
end
