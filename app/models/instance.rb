# == Schema Information
#
# Table name: instances
#
#  id               :integer          not null, primary key
#  group            :string           not null
#  catalog_entry_id :integer          not null
#  description      :string
#  version          :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_instances_on_catalog_entry_id  (catalog_entry_id)
#

class Instance < ActiveRecord::Base
  validates_presence_of :catalog_entry, :group
  before_validation :use_latest_version

  belongs_to :catalog_entry

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
    list do
      field :group
      field :catalog_entry
      field :version
      field :description
    end
  end
end
