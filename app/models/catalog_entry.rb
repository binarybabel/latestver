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

  ##
  ## =ABSTRACT FUNCTIONS=
  ## These should be overridden as necessary by actual catalog model.
  ##

  # Required.
  # Ex: return '0.0.1'
  def check_remote_version
    false
  end

  # Optional.
  # Ex: ['<a href="#"><i class="fa fa-star"> Hello</a>', ...]
  def default_links
    []
  end

  # Optional.
  # Ex: {'tgz': 'http://example.com/file.tgz', ...}
  def download_links
    {}
  end

  # Optional.
  # Ex: {'hello': 'echo Hello World'}
  def command_samples
    {}
  end

  # Create "factory" default entries for a catalog type.
  # Helps demonstrate how the :name and :tag fields are interpreted
  # ---------------------------------------------------------------
  # def self.reload_defaults!
  #   find_or_create_by!(name: name, tag: tag)
  # end

  # If your models need additional fields stored in the database...
  # ---------------------------------------------------------------
  # store :data, accessors: [ :field_a, :field_b ], coder: JSON

  ##
  ## =HELPER FUNCTIONS=
  ## Useful in parsing or determining latest version.
  ##

  # Is input 'exactly' parseable as a version?
  def is_version?(input)
    Gem::Version.correct?(input) != nil
  end

  # Parse a version number (Ex: 0.0.1) out of an input string.
  def scan_version(input, as_obj=false)
    m = input.to_s.match(/[0-9]+([\.-][0-9A-Za-z_]+)+/)
    if m
      v = m[0]
      if is_version?(v)
        as_obj && Gem::Version.new(v) || v
      end
    end
  end

  # Parse a version (as above), mapping it to the original
  #  input in a passed cache (Hash).
  def scan_version_cache(input, cache, as_objs=false)
    if (v = scan_version(input, as_objs))
      cache[v] = input
    end
    v
  end

  # Parse a version that may be just a single number.
  def scan_short_version(input)
    m = input.to_s.match(/[0-9]+([\.-][0-9A-Za-z_]+)?/)
    if m
      v = m[0]
      if is_version?(v)
        v
      end
    end
  end

  # Parse the first whole integer number.
  def scan_number(input)
    m = input.to_s.match(/[0-9]+/)
    m && m[0]
  end

  # Given a list of possible versions, meet a requirement.
  # Useful for matching partial versions pulled from the :tag field.
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

  ##
  ## =CALCULATED ATTRIBUTES=
  ## Can be overridden, but normally fend for themselves.
  ##

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
        parts['prerelease'] = v.prerelease
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

  ##
  ## =MAIN FUNCTIONS=
  ##

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

  def self.reload_defaults!
    if (self == ::CatalogEntry)
      ::CatalogEntry.descendants.each do |klass|
        klass.reload_defaults!
      end
    end
  end

  def self.autorefresh?
    ENV['REFRESH_ENABLED']
  end

  def self.autorefresh_interval
    ENV['REFRESH_INTERVAL'] || '1h'
  end

  protected

  after_create do
    links = default_links
    if links.any?
      self.external_links = links.join("\n") + "\n" + external_links.to_s
      save!
    end
    if CatalogEntry.autorefresh?
      begin
        refresh!
      rescue
        # Ignore refresh errors on create.
      end
    end
  end

  def self.configure_admin(klass)
    klass.rails_admin do
      label klass.to_s.demodulize.titleize
      object_label_method do
        :label
      end
      clone_config do
        custom_method :admin_clone
      end
      list do
        sort_by :name
        field :name do
          sortable 'name, tag'
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

  def admin_clone
    self.dup.tap do |entry|
      entry.tag = ''
      entry.version = ''
      entry.version_date = ''
      entry.last_error = ''
    end
  end

  def self.inherited(subclass)
    super(subclass)
    subclass.configure_admin(subclass)
  end

  configure_admin(self)
end
