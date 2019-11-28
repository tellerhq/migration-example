require "sinatra"
require "./teller/client.rb"

get "/" do
  case request.params["provider"]
  when "teller"
    @client = Teller::Client.new(request.params["token"])
    @accounts = @client.get("/accounts")

    slim :teller
  when "plaid"
    slim :plaid
  else
    slim :index
  end
end

def institution_logo(account)
  id = account['institution']['id']
  if File.exist?("logos/#{id}.svg")
    File.read("logos/#{id}.svg")
  else
    account['institution']['name']
  end
end

def mask(string)
  string.gsub(/.(?=.{4})/, "•")
end

def transactions(account)
  uri = URI(account["links"]["transactions"])
  @client.get(uri.path).take(5)
end

