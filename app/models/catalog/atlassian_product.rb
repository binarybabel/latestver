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
  class AtlassianProduct < CatalogEntry

    def vendor_urls
      @vurls ||= {
        'bamboo' => 'https://my.atlassian.com/download/feeds/current/bamboo.json',
        'bitbucket' => 'https://my.atlassian.com/download/feeds/current/stash.json',
        'confluence' => 'https://my.atlassian.com/download/feeds/current/confluence.json',
        'crowd' => 'https://my.atlassian.com/download/feeds/current/crowd.json',
        'jira' => 'https://my.atlassian.com/download/feeds/current/jira-software.json',
      }
    end

    def get_remote_data
      jsonp = open(vendor_urls[name]).read()
      JSON.load(jsonp.gsub(/downloads\((.*)\);?/, '\1'))
    end

    def check_remote_version
      raise "Unknown product (#{name})" unless vendor_urls.include?(name)
      data = get_remote_data

      {
        version: data[0]['version']
      }
    end

    def default_links
      [ %(<a href="https://www.atlassian.com/software/#{name}/download"><i class="fa fa-download"></i> Download-Page</a>) ]
    end

    def downloads
      data = get_remote_data
      data.map { |e| { :description => e['description'], :url => e['zipUrl'] } }
    end

    def self.reload_defaults!
      [
        'confluence',
        'jira',
      ].each do |name|
        find_or_create_by!(name: name, tag: "latest")
      end
    end

  end
end
