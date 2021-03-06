class Event < ActiveRecord::Base
  has_many :payloads
  has_one :source, through: :payloads
  has_many :responses, through: :payloads
  has_and_belongs_to_many :campaigns

  validates :event_name, presence: true, uniqueness: true

  def visits_per_hour(event)
    responses_by_hour = Hash.new(0)
    event.responses.find_each do |response|
      responses_by_hour[response.requested_at.hour] += 1
    end
    responses_by_hour
  end

  def most_received_events(source)
    source.events.group(:event_name).count
  end

  def breakdown_word(word)
    word.chars.map do |letter|
      if letter == letter.upcase
        letter = " " + letter
      else
        letter
      end
    end
  end

  def make_new_words(word)
    breakdown_word(word).join.split(" ").map do |word|
      word.capitalize
    end
  end
end
