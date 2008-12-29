class DocVersion < ActiveRecord::Base
  
  belongs_to :editor, :class_name => 'User', :foreign_key => 'editor_id'
  belongs_to :project
  belongs_to :item
  has_many   :events, :as => :target, :dependent => :destroy
   is_indexed :fields => ['content'], :delta => true
  
  validates_presence_of  [ :project_id, :editor_id, :item_id, :doc_id, :content], :on =>  :create

  #for RedCloth support
  format_attribute :content
  attr_accessible :content
  
  
  def self.find_current_for_item(item_id)
    return DocVersion.find(:all, 
      :conditions => "item_id = '#{ item_id }' AND current_version = TRUE",
      :order => 'last_edited_at DESC')
  end
  
  def self.find_current_for_project(project_id)
    return DocVersion.find(:all, 
      :conditions => "project_id = '#{ project_id }' AND current_version = TRUE AND item_id = '0'",
      :order => 'last_edited_at DESC')
  end  
end
