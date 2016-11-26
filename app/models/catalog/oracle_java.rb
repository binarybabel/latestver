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
    def vendor_urls
      @vurls ||= {
          'jdk8' => 'http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html',
          'jre8' => 'http://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html',
          'jdk7' => 'http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html',
          'jre7' => 'http://www.oracle.com/technetwork/java/javase/downloads/jre7-downloads-1880261.html',
      }
    end

    def check_remote_version
      case tag
        when /jdk[0-9]|jre[0-9]/
          major = scan_number(tag)
          raise "Unknown Java tag (#{tag})" unless vendor_urls.include?(tag)
          html = open(vendor_urls[tag]) { |f| f.read }
          m = html.match(%r{/java/jdk/(#{major}u[0-9]+-b[0-9]+)})
          m && m[1]
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
      }
    end

    def default_links
      links = []
      if (url = vendor_urls[tag])
        links << %(<a href="#{url}"><i class="fa fa-coffee"></i> Releases</a>)
      end
      links
    end

    def download_links
      return Hash.new unless version
      {
          'rpm': "http://download.oracle.com/otn-pub/java/jdk/#{version}/#{java_type}-#{version_segments[0]}u#{version_segments[1]}-linux-x64.rpm",
          'tgz': "http://download.oracle.com/otn-pub/java/jdk/#{version}/#{java_type}-#{version_segments[0]}u#{version_segments[1]}-linux-x64.tar.gz",
          'dmg': "http://download.oracle.com/otn-pub/java/jdk/#{version}/#{java_type}-#{version_segments[0]}u#{version_segments[1]}-macosx-x64.dmg",
          'exe': "http://download.oracle.com/otn-pub/java/jdk/#{version}/#{java_type}-#{version_segments[0]}u#{version_segments[1]}-windows-x64.exe",
      }
    end

    def command_samples
      return Hash.new unless version
      {
          'curl_download': "curl -LOH 'Cookie: oraclelicense=accept-securebackup-cookie' '#{download_links[:rpm]}'",
          'wget_download': "wget --no-check-certificate --no-cookies --header 'Cookie: oraclelicense=accept-securebackup-cookie' '#{download_links[:rpm]}'",
      }
    end

    def self.reload_defaults!
      {
          'java' => %w(jdk8 jdk7)
      }.each do |name, tags|
        tags.each do |tag|
          find_or_create_by!(name: name, tag: tag)
        end
      end
    end
  end
end
