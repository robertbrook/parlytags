class Item < ActiveRecord::Base
  has_and_belongs_to_many :placetags
  
  class << self
    def find_all_by_placetag tag_name
      if tag_name.is_a?(String)
        tag = Placetag.find_by_name(tag_name)
        return tag.items if tag
      elsif tag_name.is_a?(Array)
        tag_list = %Q|'#{tag_name.join("','")}'|
        tags = Placetag.find(:all, :conditions => "name in (#{tag_list})")
        unless tags.empty?
          items = []
          tags.each do |tag|
            tag.items.each do |item|
              items << item unless items.include?(item)
            end
          end
          return items
        end
      end
    end
  end
  
  def age
    days = (Time.now.to_date - created_at.to_date).to_i
    case days
      when 0
        return "Today"
      when 1
        return "Yesterday"
      else
        return "#{days} days ago"
    end
  end
  
  def display_url
    text = url.gsub("http://","")
    text = text.gsub("https://","")
    if text.length > 70
      while text.length > 66
        parts = text.split("/")
        last_part = parts.pop
        parts.pop
        parts << last_part
        text = parts.join("/")
      end
      parts = text.split("/")
      last_part = parts.pop
      parts << "..."
      parts << last_part
      text = parts.join("/")
    end
    text
  end
  
  def placenames
    names = placetags.collect { |x| x.name.gsub(/^County of /, '') }
    names.uniq
  end
  
end