class LogController < ApplicationController
  def index
    @catalog_log = CatalogLogEntry.order('created_at DESC').all
  end
end
