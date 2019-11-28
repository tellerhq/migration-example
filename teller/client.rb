require "net/https"
require "json"

module Teller
  class Client
    BASE = "https://api.teller.io".freeze

    def initialize(token)
      @token = token
    end

    def get(path)
      uri  = URI(BASE).tap { |u| u.path = path }
      req  = Net::HTTP::Get.new(uri).tap { |req| req.basic_auth(@token, "") }
      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true

      res = http.request(req)

      JSON.parse(res.body)
    end
  end
end