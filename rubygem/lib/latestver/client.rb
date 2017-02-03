require 'json'
require 'faraday'

module Latestver
  class Client
    REGEX_NAME_TAG = /\A([a-z0-9][a-z0-9_\.-]+[a-z0-9]):([a-z0-9][a-z0-9_\.-]+[a-z0-9])\z/i

    attr_reader :server_url

    def initialize(server_url)
      @server_url = server_url.to_s.sub(/\/\z/, '')
    end

    def catalog_get(name_tag)
      if name_tag.index(':').nil?
        name_tag = name_tag + ':latest'
      end

      raise ArgumentError, "Invalid NAME:TAG, #{name_tag}" unless name_tag.match(REGEX_NAME_TAG)

      name, tag = name_tag.split(':')
      response = ::Faraday.get "#{server_url}/catalog-api/#{name}/#{tag}.json"

      if response.status == 200
        JSON.parse(response.body)
      else
        raise ClientError, "Failed to get entry from catalog. #{response.reason_phrase}"
      end
    end
  end
end
