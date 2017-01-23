class LogController < ApplicationController
  def index
    cache_this!
    @catalog_log = CatalogLogEntry.order('created_at DESC').all
    respond_to do |format|
      # Default view passthrough.
      format.html

      # Default view passthrough.
      format.rss { render :layout => false }
    end
  end
end
