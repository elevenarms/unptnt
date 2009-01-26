class SearchController < ApplicationController
  
  def run_search
    page = params[:page] || 1
    @search = Ultrasphinx::Search.new(:query => params[:search_string].strip, :page => page)
    @search.run
    @uploaded_images = Hash.new
    @owners = Hash.new
    @search.results.each do |r|
      x = r.id.to_s
      image  = UploadedImage.fetch_single_image_for("project", r.id, "home_page")
      @uploaded_images[x] = image
      project_person  = ProjectPerson.find(:first, :conditions => "project_id = '#{ x }' and relationship = 'owner'")
      owner = User.find(project_person.user_id)
      @owners[x] = owner
    end
  end
end
