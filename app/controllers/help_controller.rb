class HelpController < ApplicationController
  def index
    cache_this!
  end

  def api
    cache_this!

    # Attempt to use latest values for examples.
    begin
      if (entry = CatalogEntry.find_by(name: 'rails', tag: 'latest'))
        @ex_rails_latest = entry.version.presence
      end
      if (entry = CatalogEntry.find_by(name: 'java', tag: 'jdk8'))
        @ex_java_download = entry.downloads[:rpm].presence
        @ex_java_json = JSON.pretty_generate(entry.api_data) if entry.version
      end
    rescue
      # ignore
    end

    @ex_rails_latest ||= '5.0.0'
    @ex_java_download ||= 'http://download.oracle.com/otn-pub/java/jdk/8u111-b14/jdk-8u111-linux-x64.rpm'
  end

  def version
    cache_this!
    render plain: Latestver::VERSION
  end
end
