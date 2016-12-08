class HelpController < ApplicationController
  def index
    cache_this!
  end

  def api
    cache_this!
  end
end
