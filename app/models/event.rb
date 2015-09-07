class Event < ActiveRecord::Base
  has_many :payloads
  has_one :source, through: :payloads

  validates :event_name, presence: true, uniqueness: true

  def most_received_events(source)
    source.events.order(:event_name).uniq
  end
end
