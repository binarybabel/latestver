class CatalogController < ApplicationController

  def index
    @catalog = CatalogEntry.order('name, tag DESC').visible
  end

  def view
    @entry = CatalogEntry.find_by(name: params[:name], tag: params[:tag])

    @external_links = []
    Nokogiri::HTML("<html>#{@entry.external_links}</html>").css('a').each do |link|
      @external_links << {
          name: link.inner_text.strip,
          href: link['href']
      }
    end

    respond_to do |format|
      data = {
          name: @entry.name,
          tag: @entry.tag,
          version: @entry.version,
          version_parsed: @entry.version_parsed,
          version_segments: @entry.version_segments,
          version_updated: @entry.version_date,
          version_checked: @entry.updated_at.strftime('%Y-%m-%d'),
          download_links: @entry.download_links,
          external_links: @external_links,
          command_samples: @entry.command_samples,
          catalog_type: @entry.type,
          api_revision: 1
      }.deep_stringify_keys

      if (path = params['p'])
        segments = path.split('.')
        r = data
        while segments.length > 0 and r
          r = r[segments.shift]
        end
        format.text { render text: r.to_s }
      else
        format.json { render json: data }
      end
    end
  end

end
