require 'json'
require 'dotenv'
Dotenv.load
require 'faraday'
require 'faraday/net_http'
require 'dotenv'
require 'net/http'
require 'uri'

$json_url = "#{ENV["JSON_URL"]}"
$json_api = "#{ENV["JSON_API"]}"
puts $json_url,$json_api

def getJson
  uri = URI($json_url)

  Net::HTTP.start(uri.host, uri.port,use_ssl: true ) do |http|
    req = Net::HTTP::Get.new uri
    req['X-Master-Key'] = $json_api

    $response = http.request req # Net::HTTPResponse object
  end

  file= $response.body
  $data_hash = JSON.parse(file)['record']

  puts $data_hash.length
end
getJson


def sendJson(tosendJson)
  uri = URI($json_url)

  Net::HTTP.start(uri.host, uri.port,use_ssl: true ) do |http|
    req = Net::HTTP::Put.new(uri)
    req['Content-Type'] = 'application/json'
    req['X-Master-Key'] = $json_api
    req.body = tosendJson

    $response = http.request req # Net::HTTPResponse object
    puts "JSON sent"
  end

end


def FsendPhoto(chat_id,file_id,caption)
    # uri = URI($json_url)
  
    # Net::HTTP.start(uri.host, uri.port,use_ssl: true ) do |http|
    #   req = Net::HTTP::Put.new(uri)
    #   req['Content-Type'] = 'application/json'
    #   req['X-Master-Key'] = $json_api
    #   req.body = tosendJson
  
    #   $response = http.request req # Net::HTTPResponse object
    #   puts "JSON sent"
    # end


    uri = URI("https://api.telegram.org/bot#{$token}/sendPhoto")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "multipart/form-data"
    
    request.set_form_data(
        "chat_id" => "#{chat_id}",
        #"photo" => "#{file_id}",
        "photo" => Faraday::UploadIO.new(url, 'image/jpeg'),
        "caption" => "#{caption}",
        "protect_content" => "true",
    )
      
    req_options = {
      use_ssl: uri.scheme == "https",
    }
    res=0
    Net::HTTP.start(uri.host, uri.port,use_ssl: true ) do |http|
        response = http.request(request)
        puts response,uri,uri.host, uri.port
        res= response
    end
end
     
#   $c=0
#   last=res["result"].values
#   b = last.last(3)
#   last.each { |x| 
#     puts x
#     $c=x
#     # if x[0]
#     #   c=x[0]
#     # end
#     }
  
#   puts "res:",b,last
#   $data_hash["#{$codeVar_generated}"][3]=$c

  
