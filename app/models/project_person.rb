class ProjectPerson < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  has_many   :events, :as => :target, :dependent => :destroy
end
