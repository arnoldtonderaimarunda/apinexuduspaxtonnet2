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

def findNet2User!(access_token,firstname,middlename,lastname)
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
        case "#{user['firstName']}#{user['middleName']}#{user['lastName']}".downcase
        when "#{firstname}#{middlename}#{lastname}".downcase
            return user['id']
        end
    end
    return nil
end