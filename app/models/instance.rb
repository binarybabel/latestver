# == Schema Information
#
# Table name: instances
#
#  id               :integer          not null, primary key
#  group_id         :integer          not null
#  catalog_entry_id :integer          not null
#  description      :string
#  version          :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_instances_on_catalog_entry_id  (catalog_entry_id)
#  index_instances_on_group_id          (group_id)
#

class Instance < ActiveRecord::Base
  validates_presence_of :catalog_entry, :group
  before_validation :use_latest_version

  belongs_to :group
  belongs_to :catalog_entry

  def group_enum
    Instance.select(:group).distinct.map {|x| [x.group, x.group]}.sort
  end

  def name
    catalog_entry.try(:name)
  end

  def tag
    catalog_entry.try(:tag)
  end

  def update!(v=nil)
    if v
      raise "Invalid version: #{v}" unless is_version?(v)
      self.version = v
    else
      self.version = catalog_entry.version
    end
    save!
  end

  def up_to_date?
    self.version == catalog_entry.version
  end

  def latest_version
    catalog_entry.version
  end

  after_create do
    update! if version == 'latest'
  end

  def self.model_help
    I18n.t 'admin.help.models.instance'
  end

  protected

  def is_version?(value)
    Gem::Version.correct?(value) != nil
  end

  def use_latest_version
    if version === true and catalog_entry
      self.version = catalog_entry.version
    end
  end

  rails_admin do
    navigation_label I18n.t 'app.nav.groups'
    list do
      sort_by :group
      field :group do
        sortable 'groups.name, catalog_entries.name, catalog_entries.tag'
        sort_reverse false
      end
      field :catalog_entry
      field :version
      field :description
    end
    create do
      field :group
      field :catalog_entry
      field :version do
        help 'Optional. Current version of this instance. Enter "latest" for most recent version.'
      end
      field :description
    end
    edit do
      field :group
      field :catalog_entry
      field :version do
        help 'Optional. Current version of this instance. Enter "latest" for most recent version.'
      end
      field :description
    end
  end
end
