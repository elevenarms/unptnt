class UploadedImage < ActiveRecord::Base

  has_attachment  :content_type => :image,
                  :max_size => 5.megabytes,
                  :resize_to => '600>',
                  :thumbnails => {:thumb => "45>", :medium => "290x320>", :large => "664>"},
                  :storage => :file_system,
                  :path_prefix => 'public/uploaded_images',
                  :processor => :image_science

  validates_as_attachment

  belongs_to :user
  belongs_to :project
  belongs_to :item

  def display_name
    self.name ? self.name : self.created_at.strftime("created on: %m/%d/%y")
  end

  def self.fetch_all_images_for(image_type, id)
    conditions = "#{ image_type }_id = '#{ id }' AND image_type = '#{ image_type }' "
    return UploadedImage.find(:all, :conditions => conditions)
  end

  def self.fetch_single_image_for(image_type, id, purpose)
    conditions = "#{ image_type }_id = '#{ id }' AND image_type = '#{ image_type }' "
    conditions = conditions + "AND purpose = '#{ purpose }'" unless purpose.nil?
    return UploadedImage.find(:first, :conditions => conditions)
  end

  def url
    #return the url for display and access
  end

end
