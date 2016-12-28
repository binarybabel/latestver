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
require 'git'

module Catalog
  class GitRepo < CatalogEntry
    validates :git_repo_url,
              presence: true,
              format: {:with => /\Ahttp(s)?:\/\/.+\z/}

    store :data, accessors: [ :git_repo_url ], coder: JSON

    def check_remote_version
      case tag
        when 'latest'
          self.repo_version(git_repo_url)
        else
          self.repo_version(git_repo_url, scan_short_version(tag))
      end
    end

    def default_links
      links = []
      if git_repo_url.match(/github/)
        links << %(<a href="#{git_repo_url}"><i class="fa fa-github"></i> GitHub</a>)
      else
        links << %(<a href="#{git_repo_url}"><i class="fa fa-code-fork"></i> Repository</a>)
      end
      links
    end

    def download_links
      links = Hash.new
      if version
        links['git'] = git_repo_url
        if (m = git_repo_url.match(%r{github.com/(.+)\.git}))
          links['tgz'] = "https://github.com/#{m[1]}/archive/#{version}.tar.gz"
          links['zip'] = "https://github.com/#{m[1]}/archive/#{version}.zip"
        end
      end
      links
    end

    def self.reload_defaults!
      create_with(
          git_repo_url: 'https://github.com/binarybabel/latestver.git'
      ).find_or_create_by!(name: 'latestver', tag: 'release')
    end

    protected

    def repo_version(repo_url, filter=nil)
      g = Git.ls_remote(repo_url)
      tags = g['tags'].keys.map do |tag|
        # Trim dereference markers https://www.kernel.org/pub/software/scm/git/docs/gitrevisions.html
        tag.sub(/\^.+\z/, '')
      end.uniq
      if filter
        match_requirement(tags, "~>#{filter}.0")
      else
        match_requirement(tags, '>= 0')
      end
    end

    rails_admin do
      create do
        field :tag do
          label 'Tag (Filter)'
        end
        field :git_repo_url
      end

      edit do
        field :tag do
          label 'Tag (Filter)'
        end
        field :git_repo_url
      end
    end
  end
end
