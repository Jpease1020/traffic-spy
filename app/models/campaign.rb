class Campaign < ActiveRecord::Base
  has_and_belongs_to_many :events

  validates :name, presence: true, uniqueness: true
end