# == Schema Information
#
# Table name: groups
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Group < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_many :instances, dependent: :destroy

  def to_param
    name
  end

  def self.model_help
    I18n.t 'admin.help.models.group'
  end

  rails_admin do
    navigation_label I18n.t 'app.nav.groups'
    list do
      sort_by :name
      field :name do
        sort_reverse false
      end
    end
    create do
      field :name do
        help 'Please enter a short title, id or code for your project group.'
      end
    end
    edit do
      field :name
    end
  end
end
