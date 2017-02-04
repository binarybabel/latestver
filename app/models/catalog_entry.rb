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

require 'mixlib/versioning'

class CatalogEntry < ActiveRecord::Base
  validates_presence_of :type
  validates :name, :tag, presence: true,
            format: {with: /\A[a-z0-9][a-z0-9_\.-]+[a-z0-9]\z/i, message: 'allows letters, numbers, hyphens, underscores, and full-stops.'}
  validates :tag, uniqueness: {scope: :name}

  has_many :catalog_log_entries, -> { order 'created_at DESC' }, dependent: :destroy
  has_many :catalog_webhooks, dependent: :destroy
  has_many :instances, dependent: :destroy

  scope :visible, -> { where('hidden != 1 AND hidden != "t"') }
  scope :hidden, -> { where('hidden = 1 OR hidden = "t"') }

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
  def downloads
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

  def templated(name)
    template = self.send(name)
    params = template_params
    counter = 0
    while params.size > counter
      counter = params.size
      begin
        return (template % params)
      rescue KeyError => e
        if (m = e.to_s.match(/key\{(.+)\}/))
          params[m[1].to_sym] = 'UNDEFINED'
        end
      end
    end
  end

  ##
  ## =CALCULATED ATTRIBUTES=
  ## Can be overridden, but normally fend for themselves.
  ##

  def version=(v)
    super(self.std_version(v))
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
      if (v = Mixlib::Versioning.parse version)
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

  def api_data
    external_links = []
    Nokogiri::HTML("<html>#{templated(:external_links)}</html>").css('a').each do |link|
      external_links << {
          name: link.inner_text.strip,
          href: link['href']
      }
    end

    {
        name: name,
        tag: tag,
        version: version,
        version_parsed: version_parsed,
        version_segments: version_segments,
        version_updated: version_date,
        version_checked: updated_at.strftime('%Y-%m-%d'),
        downloads: downloads,
        external_links: external_links,
        command_samples: command_samples,
        catalog_type: type,
        api_revision: 20170202
    }.deep_stringify_keys
  end

  def template_params
    params = ::CatalogEntry.all.map { |y| [y.to_param, y.version] }.to_h
    params.merge({
                          name: name,
                          tag: tag,
                          tag_version: scan_version(tag),
                          tag_major: scan_number(tag),
                          version: version,
                      }).symbolize_keys
  end

  def self.template_help
    '%{name} %{tag} %{tag_version} %{tag_major} %{NAME:TAG}'
  end

  def self.model_help
    I18n.t 'admin.help.models.catalog_entry'
  end

  ##
  ## =MAIN FUNCTIONS=
  ##

  def label
    if tag == 'latest'
      name
    elsif tag and name and tag.to_s.index(name) === 0
      tag
    else
      "#{name}:#{tag}"
    end
  end

  def to_param
    "#{name}:#{tag}"
  end

  def visible
    not hidden
  end

  def refresh!
    begin
      v = check_remote_version
      unless v.kind_of?(FalseClass)
        if (v.kind_of?(String) and not v.empty?) or (v.kind_of?(Hash) and not v[:version].to_s.empty?)
          v0 = version.presence
          v1 = std_version(v.kind_of?(Hash) && v[:version] || v)

          CatalogEntry.transaction do
            self.refreshed_at = DateTime.now

            if v0 != v1
              self.version_date = DateTime.now
              unless self.no_log
                CatalogLogEntry.create!({
                                            catalog_entry: self,
                                            version_from: v0,
                                            version_to: v1
                                        })
              end
            end

            if v.kind_of? Hash
              v.delete(:version)
              v.each do |k,v|
                self.send("#{k}=".to_sym, v)
              end
            end
            self.version = v1
            self.last_error = nil

            save!
          end

        else
          raise 'Remote failed to return new version.'
        end
      end
    rescue => e
      reload
      self.last_error = e.message
      ::Raven.capture_exception(e)
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

  def std_version(v)
    if v.presence
      v.to_s.sub(/\Av(?=[0-9])/, '')
    end
  end

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
      navigation_label I18n.t 'app.nav.catalog'
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
          pretty_value do
            v = bindings[:view]
            o = bindings[:object]
            am = ::RailsAdmin::AbstractModel.new(o.class)
            v.link_to(value, v.url_for(action: :edit, model_name: am.to_param, id: o.id), class: 'pjax').html_safe
          end
        end
        field :tag do
          pretty_value do
            v = bindings[:view]
            o = bindings[:object]
            am = ::RailsAdmin::AbstractModel.new(o.class)
            v.link_to(value, v.url_for(action: :edit, model_name: am.to_param, id: o.id), class: 'pjax').html_safe
          end
        end
        field :version
        field :type
        field :version_date
        field :last_error
        field :hidden, :boolean do
          hide
          filterable true
        end
      end
      create do
        group :default do
          field :name
          field :tag do
            default_value 'latest'
          end
        end
        group :more do
          active false
          label 'More Options'
          field :prereleases do
            visible do
              not bindings[:object].kind_of?(::CatalogEntry)
            end
          end
          field :version do
            visible do
              bindings[:object].kind_of?(::CatalogEntry)
            end
          end
          field :version_date do
            visible do
              bindings[:object].kind_of?(::CatalogEntry)
            end
          end
          field :type do
            read_only do
              not bindings[:object].kind_of?(::CatalogEntry)
            end
            default_value 'CatalogEntry'
            help ''
          end
          field :no_log do
            help "Don't post version changes to catalog log"
          end
          field :hidden
          field :external_links do
            help 'HTML links <a></a> (one per line). Type may also auto-add links on create.'
          end
          field :description
        end
      end
      edit do
        group :default do
          field :name
          field :tag
        end
        group :advanced do
          active true
          label 'Advanced'
          field :type do
            read_only true
            help ''
          end
          field :prereleases
          field :version
          field :version_date
          field :no_log do
            help "Don't post version changes to catalog log"
          end
          field :hidden
          field :external_links do
            help 'HTML links <a></a> (one per line) — Vars: ' + ::CatalogEntry.template_help
          end
          field :description
        end
      end
    end
  end

  def admin_clone
    self.dup.tap do |entry|
      entry.tag = ''
      entry.external_links = ''
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
