class SearchController < ApplicationController
  
  def index
  end
  
  def show
    term = params[:q]
    results = do_search(term)
    if results
      @edms = Edm.find_all_by_tag(results.name)
    end
  end
  
  private
    def do_search term
      tags = Tag.find_by_name_and_kind(term, "tag")
      tags
    end
  
end
