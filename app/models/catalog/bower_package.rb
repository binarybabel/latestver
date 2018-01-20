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
  class BowerPackage < GitRepo
    def check_remote_version
      case tag
        when 'latest'
          self.bower_version(name)
        else
          self.bower_version(name, scan_short_version(tag))
      end
    end

    def command_samples
      return Hash.new unless version
      {
          'install': "bower install #{name}##{version}",
      }
    end

    def self.reload_defaults!
      {
          'bootstrap' => %w(bootstrap3 bootstrap2)
      }.each do |name, tags|
        tags.each do |tag|
          find_or_create_by!(name: name, tag: tag)
        end
      end
    end

    protected

    before_validation do
      begin
        self.git_repo_url ||= bower_git_repo(name)
      rescue
        # Ignore errors.
      end
    end

    def bower_git_repo(name)
      package = JSON.load(open("https://registry.bower.io/packages/#{name}"))
      if package.is_a?(Hash)
        package['url']
      end
    end

    def bower_version(name, filter=nil)
      git_repo_url = bower_git_repo(name)
      repo_version(git_repo_url, filter)
    end
  end
end
