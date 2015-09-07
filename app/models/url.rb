require 'uri'

class Url < ActiveRecord::Base
  has_many :payloads
  has_one :source, through: :payloads
  has_many :responses, through: :payloads
  has_many :referrers, through: :payloads
  has_many :browsers, through: :payloads

  validates :url, presence: true, uniqueness: true

  def average_response_time
    responses.average(:responded_in)
  end

  def full_path(source, partial_path)
    (source.root_url + "/" + partial_path)
  end

  def most_requested(source)
    # require 'pry'
    # binding.pry
    slugs = source.urls.group(:url).count
    slugs.map do |slug|
      slug[0]
    end
  end

  def path_parser(source)
    source.urls.map do |url|
      URI(url.url).path
    end
  end
end
