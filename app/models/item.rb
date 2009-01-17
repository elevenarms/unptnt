class Item < ActiveRecord::Base
  belongs_to :bom
  has_many :uploaded_images, :dependent => :delete_all
  has_many :file_attachments, :dependent => :delete_all  #these are the (multiple) file attachments, using attachment_fu
  has_many   :events, :as => :target, :dependent => :delete_all
  is_indexed :fields => ['name'], :delta => true
  has_many :doc_versions, :dependent => :delete_all
  has_one  :forum, :as => :subject, :dependent => :delete
 
  def docs
    #get just current versions
    DocVersion.find(:all, :conditions => "item_id = '#{self.id}'  AND  current_version = TRUE", :order => "created_at DESC")
  end

  def home_page_image
    image = UploadedImage.fetch_single_image_for("item", self.id, "home_page")
  end

  def all_images
    UploadedImage.fetch_all_images_for("item", self.id)
  end

  def image_file_name
    image = self.home_page_image
    filename = nil
    filename = image.filename unless image.nil?
  end

  def image_name
    image = self.home_page_image
    name = nil
    name = image.display_name unless image.nil?
  end

end
