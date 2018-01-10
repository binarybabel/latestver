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
  class OracleJavaNew < CatalogEntry
    store :data, accessors: [ :download_hash ], coder: JSON

    def vendor_urls
      @vurls ||= {
          'jdk9' => 'http://www.oracle.com/technetwork/java/javase/downloads/jdk9-downloads-3848520.html',
          'jre9' => 'http://www.oracle.com/technetwork/java/javase/downloads/jre9-downloads-3848532.html',
      }
    end

    def check_remote_version
      case tag
        when /jdk[0-9]|jre[0-9]/
          major = scan_number(tag)
          raise "Unknown Java tag (#{tag})" unless vendor_urls.include?(tag)
          html = open(vendor_urls[tag]) { |f| f.read }
          if (m = html.match(%r{/java/jdk/(#{major}[.][0-9][.][0-9][+][0-9]+)/?}))
            {
                version: m[1],
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
          'patch': version_segments[2],
          'build': version_segments[3],
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
      {
          'rpm': "http://download.oracle.com/otn-pub/java/jdk/#{version}/#{java_type}-#{version_segments[0]}.#{version_segments[1]}.#{version_segments[2]}_linux-x64_bin.rpm",
          'tgz': "http://download.oracle.com/otn-pub/java/jdk/#{version}/#{java_type}-#{version_segments[0]}.#{version_segments[1]}.#{version_segments[2]}_linux-x64_bin.tar.gz",
          'dmg': "http://download.oracle.com/otn-pub/java/jdk/#{version}/#{java_type}-#{version_segments[0]}.#{version_segments[1]}.#{version_segments[2]}_osx-x64_bin.dmg",
          'exe': "http://download.oracle.com/otn-pub/java/jdk/#{version}/#{java_type}-#{version_segments[0]}.#{version_segments[1]}.#{version_segments[2]}_windows-x64_bin.exe",
      }
    end

    def command_samples
      {
          'curl_download': "curl -LOH 'Cookie: oraclelicense=accept-securebackup-cookie' '#{downloads[:rpm]}'",
          'wget_download': "wget --no-check-certificate --no-cookies --header 'Cookie: oraclelicense=accept-securebackup-cookie' '#{downloads[:rpm]}'",
      }
    end

    def self.reload_defaults!
      {
          'java' => %w(jdk9)
      }.each do |name, tags|
        tags.each do |tag|
          find_or_create_by!(name: name, tag: tag)
        end
      end
    end
  end
end
