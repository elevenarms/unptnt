class SearchController < ApplicationController
  
  def run_search
    @search = Ultrasphinx::Search.new(:query => params[:search_string])
    @search.run
    @search.results
    
  end

end
