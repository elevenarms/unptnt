class Item < ActiveRecord::Base
  belongs_to :bom
  has_attached_file :item_image, 
                    :styles => { :medium => "300x300>",
                                 :thumb => "100x100>" } 
  has_many :file_attachments, :dependent => :delete_all  #these are the (multiple) file attachments, using attachment_fu
  has_many   :events, :as => :target, :dependent => :delete_all
  is_indexed :fields => ['name'], :delta => true
  has_many :doc_versions, :dependent => :delete_all
  has_one  :forum, :as => :subject, :dependent => :delete
 
  def docs
    #get just current versions
    DocVersion.find(:all, :conditions => "item_id = '#{self.id}'  AND  current_version = TRUE", :order => "created_at DESC")
  end
end
