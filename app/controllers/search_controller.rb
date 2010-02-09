class SearchController < ApplicationController
  
  def index
    term = params[:q]
    if term
      term = do_search(term.strip)
      if @place.blank?
        @place = nil
      else
        @map = GMap.new("map")
        @map.control_init(:large_map => true,:map_type => false)
        @map.center_zoom_init([@place.lat, @place.lng], @place.zoom_level)
      end
    end
  end
  
  private
    def do_search term
      @last_search_term = term
      @searched_for = term
      places = Place.find_all_by_ascii_name_or_alternate_names(term)
      if places.empty?
        terms = term.split(",")
        places = Place.find_all_by_ascii_name_or_alternate_names(terms[0])
        if places
          places.each do |place|
            if place.county_name == terms[1].strip
              places = [place]
              break
            end
          end
        end
      end
      unless places.empty?
        @place = places.first
        if @place.placetag
          @place_title = @place.placetag.name
          if @place.placetag.county
            @place_title = "#{@place_title.strip}, #{@place.placetag.county.strip}"
          end
        else
          @place_title = @place.ascii_name
          county = @place.county_name
          if county
            @place_title = "#{@place_title.strip}, #{county.strip}"
          end
        end
        if @place.ascii_name.downcase != term.downcase && @place.ascii_name.downcase != term.split(",")[0].downcase
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
      term
    end
  
end
