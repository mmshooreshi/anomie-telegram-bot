require 'sinatra'
get '/' do
  redirect 'http://t.me/anon_secure_bot', 303
end