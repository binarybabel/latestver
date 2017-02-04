require 'uri'
require 'net/http'

class CatalogController < ApplicationController

  def index
    cache_this!
    @catalog = CatalogEntry.order('name, tag DESC').visible
  end

  def view
    cache_this!
    @entry = CatalogEntry.find_by!(name: params[:name], tag: params[:tag])

    @data = @entry.api_data
    @external_links = @data['external_links'] || []
    @has_links = @external_links.size > 0

    respond_to do |format|
      # Default view passthrough.
      format.html

      # Output whole entry as JSON.
      format.json { render json: @data }

      # Output single field value from entry.
      format.text do
        if (path = params['p'])
          segments = path.split('.')
          x = @data
          while segments.length > 0 and x
            x = x[segments.shift]
          end
          render plain: x.to_s
        else
          render plain: 'ERROR: Path not provided.', status: :bad_request
        end
      end

      # Render entry as status badge.
      #   Optionally providing a remote version to
      #   compare and colorize the result, as follows:
      #   * BLUE   (No version)
      #   * GREEN  (Version given is up-to-date)
      #   * RED    (Version given is out-of-date)
      format.svg do
        badge_label = params['label'] || params['l'] || @entry.label
        badge_version = @entry.version
        badge_color = 'blue'
        if (version = params['v'])
          badge_version = URI.encode(version)
          badge_color = (version == @entry.version) && 'brightgreen' || 'red'
        end
        badge_label = badge_label.to_s.gsub('-', '--')
        badge_version = badge_version.to_s.gsub('-', '--')
        badge_url = "https://img.shields.io/badge/#{badge_label}-#{badge_version}-#{badge_color}.svg"

        if Rails.env.development? or ENV['PROXY_BADGES']
          max_redirects = 5
          loop do
            raise 'Too many redirects' if max_redirects < 1
            uri = URI.parse(badge_url)
            req = Net::HTTP::Get.new(uri.path, { 'User-Agent' => 'Wget/1.9.1' })
            rsp = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }
            if rsp.code.to_i.between?(300,307)
              max_redirects -= 1
              puts rsp['location']
              badge_url = r['location']
              next
            end
            rsp.value # raise error on bad response
            send_data rsp.body, type: rsp['content-type'], disposition: 'inline'
            break
          end
        else
          redirect_to badge_url, status: :found
        end
      end
    end
  end

end
