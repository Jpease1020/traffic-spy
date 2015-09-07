class Response < ActiveRecord::Base
  has_many :payloads
  has_many :urls, through: :payloads
  has_one :source, through: :payloads
  has_many :responses, through: :payloads

  validates :requested_at, presence: true
  validates :responded_in, presence: true
  validates :ip, presence: true

  def average_response_times(source)
    group = source.urls.uniq.map do |url|
      [url, url.average_response_time]
    end
    group.sort_by { |_, time| time }.reverse
  end

  def longest_response_time(source)
    source.responses.maximum(:responded_in)
  end

  def shortest_response_time(source)
    source.responses.minimum(:responded_in)
  end

  def average_response_time(source)
    source.responses.average(:responded_in)
  end

  def http_verbs(source)
    source.responses.map do |response|
      response.request_type
    end.uniq
  end
end
