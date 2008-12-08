class DocVersion < ActiveRecord::Base
  
  belongs_to :editor, :class_name => 'User', :foreign_key => 'editor_id'
  belongs_to :project
  belongs_to :item
  has_many   :events, :as => :target, :dependent => :destroy
   is_indexed :fields => ['content'], :delta => true
  
  validates_presence_of :project_id
  validates_presence_of :editor_id
  validates_presence_of :item_id
  validates_presence_of :doc_id
  
  
  def self.find_current_for_item(item_id)
    return DocVersion.find(:all, 
      :conditions => "item_id = '#{ item_id }' AND current_version = TRUE",
      :order => 'last_edited_at DESC')
  end
  
  def self.find_current_for_project(project_id)
    return DocVersion.find(:all, 
      :conditions => "project_id = '#{ project_id }' AND current_version = TRUE",
      :order => 'last_edited_at DESC')
  end  
end
