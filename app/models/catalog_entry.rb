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
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'mixlib/versioning'

class CatalogEntry < ActiveRecord::Base
  validates :name, :type, :tag, presence: true
  validates :tag, uniqueness: {scope: :name}

  has_many :catalog_log_entries, dependent: :destroy
  has_many :catalog_webhooks, dependent: :destroy
  has_many :instances, dependent: :destroy

  def label
    "#{name}:#{tag}"
  end

  def refresh!
    begin
      v = check_remote_version
      unless v.kind_of?(FalseClass)
        if v.nil? or not v.kind_of?(String) or v.empty?
          raise 'Remote failed to return new version.'
        else
          CatalogEntry.transaction do
            self.refreshed_at = DateTime.now
            if version != v
              self.version_date = DateTime.now
              CatalogLogEntry.create!({
                                          catalog_entry: self,
                                          version_from: version,
                                          version_to: v
                                      })
            end
            self.version = v
            self.last_error = nil
            save!
          end
        end
      end
    rescue => e
      reload
      self.last_error = e.message
      save
      raise e
    end
  end

  def version_parsed
    parts = {
        'major': '',
        'minor': '',
        'patch': '',
        'build': '',
        'prerelease': '',
    }
    begin
      if (v = Mixlib::Versioning.parse(version))
        parts['major'] = v.major
        parts['minor'] = v.minor
        parts['patch'] = v.patch
        parts['build'] = v.build || v.prerelease.sub(/^[a-z]+/, '')
        parts['build'] = build
      end
    rescue
      # Failed to parse version.
    end
    parts
  end

  def version_segments
    return [] unless version
    version.gsub(/[^0-9]+/, '-').split('-')
  end

  def check_remote_version
    false
  end

  def default_links
    []
  end

  def download_links
    {}
  end

  def command_samples
    {}
  end

  def self.reload_defaults!
    if (self == ::CatalogEntry)
      ::CatalogEntry.descendants.each do |klass|
        klass.reload_defaults!
      end
    end
  end

  #store :data, accessors: [ :another_field ], coder: JSON

  protected

  after_create do
    links = default_links
    if links.any?
      self.external_links = links.join("\n") + "\n" + external_links.to_s
      save!
    end
    begin
      refresh!
    rescue
      # Ignore refresh errors on create.
    end
  end

  def is_version?(input)
    Gem::Version.correct?(input) != nil
  end

  def match_requirement(list, requirement)
    cache = Hash.new
    list = list.map do |y|
      begin
        scan_version_cache(y, cache, true)
      rescue ArgumentError
        nil
      end
    end.compact.sort.uniq.reverse
    gr = Gem::Requirement.new(requirement)
    list.each do |gv|
      if gr.satisfied_by?(gv) and (prereleases or not gv.prerelease?)
        return cache[gv]  # return actual list entry, not just the parsed version
      end
    end
    nil
  end

  def scan_version(input, as_obj=false)
    m = input.to_s.match(/[0-9]+([\.-][0-9A-Za-z_]+)+/)
    if m
      v = m[0]
      if is_version?(v)
        as_obj && Gem::Version.new(v) || v
      end
    end
  end

  def scan_version_cache(input, cache, as_objs=false)
    if (v = scan_version(input, as_objs))
      cache[v] = input
    end
    v
  end

  def scan_short_version(input)
    m = input.to_s.match(/[0-9]+([\.-][0-9A-Za-z_]+)?/)
    if m
      v = m[0]
      if is_version?(v)
        v
      end
    end
  end

  def scan_number(input)
    m = input.to_s.match(/[0-9]+/)
    m && m[0]
  end

  def self.configure_admin(klass)
    klass.rails_admin do
      label klass.to_s.demodulize.titleize
      object_label_method do
        :label
      end
      list do
        sort_by :name, :tag
        field :name do
          sort_reverse false
        end
        field :type
        field :tag
        field :version
        field :version_date
        field :last_error
      end
      create do
        group :default do
          field :name
          field :tag do
            default_value 'latest'
          end
        end
        group :other do
          label 'More Options'
          field :prereleases
          field :type do
            read_only true
            help ''
          end
          field :external_links do
            help 'HTML links <a></a>, (one per line). Type may also auto-add links on create.'
          end
        end
      end
      edit do
        group :default do
          field :name
          field :tag
        end
        group :other do
          label 'More Options'
          field :type do
            read_only true
            help ''
          end
          field :prereleases
          field :version
          field :version_date
          field :external_links do
            help 'HTML links <a></a>, (one per line)'
          end
        end
      end
    end
  end

  def self.inherited(subclass)
    super(subclass)
    subclass.configure_admin(subclass)
  end

  configure_admin(self)
end
