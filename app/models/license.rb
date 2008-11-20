class License < ActiveRecord::Base
  has_many :projects
  has_attached_file :license_image, 
                    :styles => { :medium => "300x300>",
                                 :thumb => "40x40>" }
end
