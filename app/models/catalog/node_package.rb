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

require 'open-uri'

module Catalog
  class NodePackage < CatalogEntry
    def check_remote_version
      case tag
      when 'latest'
        self.npm_version(name)
      else
        self.npm_version(name, scan_short_version(tag))
      end
    end

    def command_samples
      return Hash.new unless version
      {
          'install': "npm install -g #{name}",
      }
    end

    def self.reload_defaults!
    end

    protected

    def npm_version(name, filter = 'latest')
      if filter == 'latest'
        package = JSON.load(open("http://registry.npmjs.org/#{name}/#{filter}"))
        scan_version(package['version']) if package.is_a?(Hash)
      else
        packages = JSON.load(open("http://registry.npmjs.org/#{name}/"))
        match_requirement(packages['versions'].keys.compact, "~>#{filter}.0")
      end
    end
  end
end
