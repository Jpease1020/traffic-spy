class Event < ActiveRecord::Base
  has_many :payloads
  has_one :source, through: :payloads
  has_many :responses, through: :payloads

  validates :event_name, presence: true, uniqueness: true

  def visits_per_hour(event)
    responses_by_hour = Hash.new(0)
    event.responses.find_each do |response|
      responses_by_hour[response.requested_at.hour] += 1
    end
    responses_by_hour
  end

  def most_received_events(source)
    source.events.order(:event_name).uniq
  end
end
