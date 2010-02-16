require 'open-uri'

class SearchController < ApplicationController
  
  def index
    @has_connection = true
    if RAILS_ENV == "development"
      begin
        open("http://maps.google.com")
      rescue
        @has_connection = false
      end
    end
    
    term = params[:q]
    if term
      term = do_search(term.strip)
      if @place.blank?
        @place = nil
      else
        if @has_connection
          @map = GMap.new("map")
          @map.control_init(:large_map => true,:map_type => false)
          @map.center_zoom_init([@place.lat, @place.lng], @place.zoom_level)
        end
      end
    end
  end
  
  private
    def do_search term
      @last_search_term = term
      @searched_for = term
      if term.downcase.strip == "united kingdom"
        places = []
      else
        places = do_place_search(term)
      end
      unless places.empty?
        @place = places.first
        @place_title = get_place_title(@place)
        @results = @place.find_nearby_items(10)
      end
      # @hansard_archive_results = do_hansard_archive_search(term)
      if @has_connection
        begin
          @ukparliament_twitter_results = do_ukparliament_twitter_search(term)
        rescue
          #ignore the error
        end
      end
      term
    end
    
    def do_ukparliament_twitter_search term
      results = ActiveSupport::JSON.decode(open("http://search.twitter.com/search.json?q=" + URI.escape(term.strip) + "&from=ukparliament").read)["results"]
      results.each do |result|
        html = result["text"]
        html.scan(/http:\/\/\S*/).each do |match|
          html.gsub!(match, "<a href='#{match}'>#{match}</a>")
        end
        result["text"] = html
      end
      results
    end
    
    # def do_hansard_archive_search term
    #   results = Hash.from_xml(open("http://hansard.millbanksystems.com/search/" + URI.escape(term.strip) + ".atom").read)
    #   results
    # end
    
    def do_place_search term
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
      places
    end
    
    def get_place_title place
      if place.placetag
        place_title = place.placetag.name
        if place.placetag.county
          place_title = "#{place_title.strip} (#{place.placetag.county.strip})"
        end
      else
        place_title = place.display_name
        county = place.county_name
        if county
          place_title = "#{place_title.strip}, #{county.strip}"
        end
      end
      place_title
    end
end
