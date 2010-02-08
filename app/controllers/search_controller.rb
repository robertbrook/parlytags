class SearchController < ApplicationController
  
  def index
    term = params[:q]
    if term
      do_search(term.strip)
      if @place.blank?
        @place = nil
      else
        @map = GMap.new("map")
        @map.control_init(:large_map => true,:map_type => false)
        @map.center_zoom_init([@place.lat, @place.lng], 14)
      end
    end
  end
  
  private
    def do_search term
      @last_search_term = term
      @searched_for = term
      places = Place.find_all_by_ascii_name_or_alternate_names(term)
      unless places.empty?
        @place = places.first
        if @place.ascii_name != term
          @usually_known_as = @place.ascii_name
        end
        @results = @place.find_nearby_items(10)
      else
        tag = Tag.find_by_name(term)
        if tag
          items = Item.find_all_by_tag(tag.name)
          @results = items.paginate :page => params[:page]
        end
      end
    end
  
end
