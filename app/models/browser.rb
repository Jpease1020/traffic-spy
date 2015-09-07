class Browser < ActiveRecord::Base
  has_many :payloads
  has_one :source, through: :payloads

  validates :browser, presence: true, uniqueness: true
  validates :operating_system, presence: true, uniqueness: true

  def most_popular_browsers(path)
    url = Url.find_by(url: path)
    if url.nil?
      return []
    end
    group_count = url.browsers.group(:browser).count
    group_count.sort_by { |_, count| count }.reverse.flatten
  end

  def most_popular_operating_systems(path)
    url = Url.find_by(url: path)
    if url.nil?
      return []
    end
    group_count = url.browsers.group(:operating_system).count
    group_count.sort_by { |_, count| count }.reverse.flatten
  end

  def list_browsers(source)
    source.browsers.group(:browser).count
  end

  def list_operating_systems(source)
    source.browsers.group(:operating_system).count
  end
end
