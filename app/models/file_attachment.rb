class FileAttachment < ActiveRecord::Base
  belongs_to :item
  has_attachment :storage => :file_system, 
                 :max_size => 10.megabytes
  validates_as_attachment
  has_many   :events, :as => :target, :dependent => :destroy
end
