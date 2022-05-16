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
