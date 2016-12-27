class HelpController < ApplicationController
  def index
    cache_this!
  end

  def api
    cache_this!
  end

  def version
    cache_this!
    render plain: Latestver::VERSION
  end
end
