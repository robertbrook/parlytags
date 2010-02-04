class SearchController < ApplicationController
  
  def index
    term = params[:q]
    if term
      results = do_search(term.strip)
      if results
        items = Item.find_all_by_tag(results.name)
        @results = items.paginate :page => params[:page]
      end
      @place = Place.find_all_by_ascii_name_or_alternate_names(term)
      if @place.blank?
        @place = nil
      else
        @place = @place.first
        @map = GMap.new("map")
        @map.control_init(:large_map => true,:map_type => false)
        @map.center_zoom_init([@place.lat, @place.lng], 14)
      end
    end
  end
  
  private
    def do_search term
      @last_search_term = term
      tags = Tag.find_by_name(term)
      tags
    end
  
end
