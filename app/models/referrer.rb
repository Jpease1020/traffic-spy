class Referrer < ActiveRecord::Base
  has_many :payloads
  has_one :source, through: :payloads

  validates :referred_by, presence: true, uniqueness: true

  def most_popular_referrers(source)
    grouped = source.referrers.group(:referred_by).count
    referrers_grouped = grouped.map do |referrer, count|
      [referrer, count]
    end
    referrers_grouped.sort_by { |referrer, count| count }.reverse
  end
end
