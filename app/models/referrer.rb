class Referrer < ActiveRecord::Base
  has_many :payloads
  has_one :source, through: :payloads

  validates :referred_by, presence: true, uniqueness: true

  def most_popular_referrers(path)
    url = Url.find_by(url: path)
    if url.nil?
      return []
    end

    group_count = url.referrers.group(:referred_by).count
    group_count.sort_by { |_, count| count }.reverse.flatten
  end
end
