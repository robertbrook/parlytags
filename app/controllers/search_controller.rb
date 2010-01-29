class SearchController < ApplicationController
  
  def index
    term = params[:q]
    if term
      results = do_search(term)
      if results
        edms = Edm.find_all_by_tag(results.name)
        @results = edms.paginate :page => params[:page], :order => 'created_at DESC'
      end
      @place = Place.find_by_ascii_name(term)
    end
  end
  
  private
    def do_search term
      @last_search_term = term
      tags = Tag.find_by_name_and_kind(term, "tag")
      tags
    end
  
end
