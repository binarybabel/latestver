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

  rails_admin do
    list do
      sort_by :name
      field :name do
        sort_reverse false
      end
    end

    create do
      field :name
    end

    edit do
      field :name
    end
  end
end
