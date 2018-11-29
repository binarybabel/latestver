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
  class OracleJava < CatalogEntry
    store :data, accessors: [ :download_uuid ], coder: JSON

    def vendor_urls
      @vurls ||= {
          'jdk11' => 'https://www.oracle.com/technetwork/java/javase/downloads/jdk11-downloads-5066655.html',
          'jdk8' => 'http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html',
          'jre8' => 'http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html',
          'jdk7' => 'http://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-javase7-521261.html',
          'jre7' => 'http://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-javase7-521261.html',
          'jdk6' => 'http://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-javase6-419409.html',
          'jre6' => 'http://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-javase6-419409.html',
      }
    end

    def check_remote_version
      case tag
      when /jdk[0-9]|jre[0-9]/
        raise "Unknown Java tag (#{tag})" unless vendor_urls.include?(tag)
        major = scan_number(tag)
        html = open(vendor_urls[tag]) { |f| f.read }
        # if (m = html.match(%r{/java/jdk/(#{major}u[0-9]+-b[0-9]+)/([a-f0-9]{32})?}))
        if (m = html.match(%r{/java/jdk/(#{major}[u\.][0-9]+[\.-]b?[0-9]+(\+[0-9]+)?)/([a-f0-9]{32})?}))
          {
              version: m[1],
              download_uuid: m[3]
          }
        end
      end
    end

    def java_type
      tag.sub(/[0-9]+/, '')
    end

    def version_parsed
      {
          'major': version_segments[0],
          'minor': version_segments[1],
          'build': version_segments[2],
          'uuid': download_uuid,
      }
    end

    def default_links
      links = []
      if (url = vendor_urls[tag])
        links << %(<a href="#{url}"><i class="fa fa-coffee"></i> Releases</a>)
      end
      links
    end

    def downloads
      return Hash.new unless version
      uuid = ''
      dver = "#{version_segments[0]}u#{version_segments[1]}-"
      dsfx = ''

      if version_segments[0].to_i >= 8
        uuid = download_uuid.to_s + '/'
      end

      if version_segments[0].to_i >= 11
        dver = version_segments[0..2].join('.') + '_'
        dsfx = '_bin'
      end

      {
          'rpm': "http://download.oracle.com/otn-pub/java/jdk/#{version}/#{uuid}#{java_type}-#{dver}linux-x64#{dsfx}.rpm",
          'tgz': "http://download.oracle.com/otn-pub/java/jdk/#{version}/#{uuid}#{java_type}-#{dver}linux-x64#{dsfx}.tar.gz",
          'dmg': "http://download.oracle.com/otn-pub/java/jdk/#{version}/#{uuid}#{java_type}-#{dver}macosx-x64#{dsfx}.dmg",
          'exe': "http://download.oracle.com/otn-pub/java/jdk/#{version}/#{uuid}#{java_type}-#{dver}windows-x64#{dsfx}.exe",
      }
    end

    def command_samples
      return Hash.new unless version
      {
          'curl_download': "curl -LOH 'Cookie: oraclelicense=accept-securebackup-cookie' '#{downloads[:rpm]}'",
          'wget_download': "wget --no-check-certificate --no-cookies --header 'Cookie: oraclelicense=accept-securebackup-cookie' '#{downloads[:rpm]}'",
      }
    end

    def self.reload_defaults!
      {
          'java' => %w(jdk11 jdk8)
      }.each do |name, tags|
        tags.each do |tag|
          find_or_create_by!(name: name, tag: tag)
        end
      end

      if Rails.env.development?
        {
            'java' => %w(jdk7 jdk6)
        }.each do |name, tags|
          tags.each do |tag|
            find_or_create_by!(name: name, tag: tag)
          end
        end
      end
    end
  end
end
