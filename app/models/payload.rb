class Payload < ActiveRecord::Base
  belongs_to :source
  belongs_to :url
  belongs_to :response
  belongs_to :browser
  belongs_to :resolution
  belongs_to :event
  belongs_to :referrer

  validates :digest, presence: true, uniqueness: true
end
