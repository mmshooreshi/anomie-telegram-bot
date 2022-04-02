require 'telegram/bot'
require 'openssl'
require_relative 'text2png'

require 'dotenv'
Dotenv.load

require 'net/http'
require 'uri'

require 'json'
require "RMagick"


def text2png(text)
    api_key_imgbun='5edb5140b96e2bac3e76a585c466566d'
    url = URI("https://api.imgbun.com/png?key=#{api_key_imgbun}&text=#{text}&color=FF0000&size=16")
    puts "url: #{url} #{url.host}"
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
     
  
    request = Net::HTTP::Get.new(url)
    
    response = http.request(request)
    puts "response #{response}"
    puts response.body
end



text2png_arabic "سلامممم بچه‌"
