require 'sinatra'
get '/' do
  redirect 'https://t.me/anon_secure_bot', 303
end