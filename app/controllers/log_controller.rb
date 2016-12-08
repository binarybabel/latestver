class LogController < ApplicationController
  def index
    cache_this!
    @catalog_log = CatalogLogEntry.order('created_at DESC').all
  end
end
