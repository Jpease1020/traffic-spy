class Source < ActiveRecord::Base
  has_many :payloads

  validates :root_url, presence: true, uniqueness: true
  validates :identifier, presence: true, uniqueness: true
end