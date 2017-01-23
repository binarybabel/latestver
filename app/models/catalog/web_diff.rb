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

require 'digest/sha1'

module Catalog
  class WebDiff < WebScraper
    def check_remote_version
      text = fetch_remote_text
      iexp = Regexp.new(include_regex.to_s, Regexp::MULTILINE)

      if (m = text.match(iexp))
        return Digest::SHA1.hexdigest(m[0])[0..5]
      end

      nil
    end

    def self.reload_defaults!

    end

    rails_admin do
      create do
        field :web_page_url do
          help ::CatalogEntry.template_help
        end
        field :css_query
        field :xpath_query
        field :include_regex
      end

      edit do
        field :web_page_url do
          help ::CatalogEntry.template_help
        end
        field :css_query
        field :xpath_query
        field :include_regex
      end
    end
  end
end
