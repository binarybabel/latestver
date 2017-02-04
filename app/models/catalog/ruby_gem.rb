# == Schema Information
#
# Table name: catalog_entries
#
#  id             :integer          not null, primary key
#  name           :string           not null
#  type           :string           not null
#  tag            :string           not null
#  version        :string
#  version_date   :date
#  prereleases    :boolean          default(FALSE)
#  external_links :text
#  data           :text
#  refreshed_at   :datetime
#  last_error     :string
#  no_log         :boolean          default(FALSE)
#  hidden         :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'gems'

module Catalog
  class RubyGem < CatalogEntry
    def check_remote_version
      case tag
        when 'latest'
          self.gem_version(name)
        else
          self.gem_version(name, scan_number(tag))
      end
    end

    def default_links
      [
          %(<a href="https://rubygems.org/gems/#{name}"><i class="fa fa-diamond"></i> RubyGems</a>)
      ]
    end

    def downloads
      links = Hash.new
      if version
        links['gem'] = "https://rubygems.org/downloads/#{name}-#{version}.gem"
      end
      links
    end

    def self.reload_defaults!
      {
          'rails' => %w(latest rails5 rails4)
      }.each do |name, tags|
        tags.each do |tag|
          create_with(
              external_links: [
                  '<a href="http://weblog.rubyonrails.org/releases/"><i class="fa fa-list-ul"></i> Changelog</a>'
              ].join("\n")
          ).find_or_create_by!(name: name, tag: tag)
        end
      end
    end

    protected

    def gem_version(name, filter=nil)
      versions = Gems.versions(name)
      raise 'Failed to retrieve gem info.' unless versions
      raise versions.to_s unless versions.is_a?(Array)
      if filter
        match_requirement(versions.map { |y| y['number'].to_s }.compact, "~>#{filter}.0")
      else
        match_requirement(versions.map { |y| y['number'].to_s }.compact, '>0')
      end
    end
  end
end
