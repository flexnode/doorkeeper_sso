require_dependency "api_auth"
require_dependency "rest-client"

module Sso
  class Notifier

    attr_accessor :url
    attr_reader   :data, :api_id, :api_secret

    def initialize(url, api_id, api_secret, data)
      @url = url
      @data = data
      @api_id = api_id
      @api_secret = api_secret
    end

    def call
      signed_request.execute
    end

    def request
      @request ||= ::RestClient::Request.new(url: url, method: :post, payload: data.to_json, headers: {:content_type => :json, :accept => :json})
    end

    def signed_request
      @signed_request ||= ::ApiAuth.sign!(request, api_id, api_secret)
    end
  end
end
