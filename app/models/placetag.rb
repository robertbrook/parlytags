class Placetag < ActiveRecord::Base
  has_and_belongs_to_many :tags
  belongs_to :place
  
  def item_count
    total = 0
    if tags
      counts = tags.collect { |x| x.items.count }
      counts.each do |count|
        total += count
      end
    end
    total
  end
  
end