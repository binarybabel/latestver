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
  class WebScraper < CatalogEntry
    validates :web_page_url,
              presence: true,
              format: {:with => /\Ahttp(s)?:\/\/.+/}
    validates_presence_of :include_regex

    store :data, accessors: [:web_page_url, :css_query, :xpath_query, :include_regex, :exclude_regex], coder: JSON

    def check_remote_version
      url_params = ::CatalogEntry.all.map { |y| [y.label, y.version] }.to_h
      url_params.merge!({
        name: name,
        tag: tag,
        tag_version: scan_version(tag),
        tag_major: scan_number(tag)
      })
      url = web_page_url.to_s % url_params.symbolize_keys
      text = open(url) { |f| f.read }

      unless [css_query, xpath_query].all? { |v| v.to_s.empty? }
        n = Nokogiri::HTML(text)
        unless css_query.to_s.empty?
          n = n.at_css(css_query)
        end
        unless xpath_query.to_s.empty?
          n = n.at_xpath(xpath_query)
        end
        text = n.text
      end

      iexp = Regexp.new(include_regex.to_s)
      xexp = Regexp.new(exclude_regex.to_s)

      text.split("\n").each do |line|
        if (m = line.match(iexp)) and (exclude_regex.to_s.empty? or not line.match(xexp))
          if m.names.include?('ver')
            return m['ver']
          elsif prereleases
            return scan_short_version(m[0].to_s)
          else
            return scan_version(m[0].to_s)
          end
        end
      end
      nil
    end

    def default_links
      [
          %(<a href="#{web_page_url}"><i class="fa fa-globe"></i> Website</a>)
      ]
    end

    def self.reload_defaults!
      create_with(
          web_page_url: 'http://fontawesome.io/',
          css_query: 'div.shameless-self-promotion',
          xpath_query: 'text()',
          include_regex: '.+'
      ).find_or_create_by!(name: 'fontawesome', tag: 'latest')

      create_with(
          web_page_url: 'https://gitlab.com/gitlab-org/gitlab-ce/raw/master/CHANGELOG.md',
          include_regex: '## (v)?[0-9]',
          exclude_regex: 'unreleased'
      ).find_or_create_by!(name: 'gitlab', tag: 'latest')

      create_with(
          web_page_url: 'https://docs.gradle.org/current/release-notes',
          css_query: 'h3.releaseinfo',
          include_regex: '.+'
      ).find_or_create_by!(name: 'gradle', tag: 'latest')
    end

    protected

    rails_admin do
      create do
        field :web_page_url do
          help '%{name} %{tag} %{tag_version} %{tag_major} %{NAME:TAG}'
        end
        field :css_query
        field :xpath_query
        field :include_regex
        field :exclude_regex
      end

      edit do
        field :web_page_url do
          help '%{name} %{tag} %{tag_version} %{tag_major}'
        end
        field :css_query
        field :xpath_query
        field :include_regex
        field :exclude_regex
      end
    end
  end
end
