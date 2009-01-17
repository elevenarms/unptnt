class Project < ActiveRecord::Base
  
  has_many  :users, :through => 'project_person'
  has_many :project_people, :dependent => :delete_all , :dependent => :delete_all
  belongs_to :license
  has_one :bom,   :include => [:items]
  has_many :events, :dependent => :delete_all
  has_many :items , :through => :bom
  has_many :statuses, :order => "created_at DESC", :dependent => :delete_all
  has_many :clone_trees, :dependent => :delete_all
  acts_as_taggable_on :keywords
  has_many :uploaded_images, :dependent => :delete_all
  is_indexed :fields => ['name', 'description', 'status'], :delta => true
  has_many :doc_versions, :dependent => :delete_all
  has_one  :forum, :as => :subject, :include => [ {:topics => :posts} ]

  validates_presence_of     :name
  validates_length_of       :name,     :maximum => 100
  
  def create_event(action_id, target, user, data = nil, body = nil, date = Time.now.utc)
    #debugger - commented out so it would run in NetBeans
    events.create(:action => action_id, :target => target, :user => user,
                  :body => body, :data => data, :created_at => date)
  end   
  
  def related_users
    project_people = ProjectPerson.find(:all, :conditions => "project_id = '#{self.id }'")
    related_users = { :owner => nil, :followers => [], :collaborators => [] }

    project_people.each do |pp|
      case pp.relationship
      when "owner" then  related_users[:owner] = pp.user
      when "follower" then related_users[:followers] << pp.user
      when "collaborator" then related_users[:collaborators] << pp.user
      end
    end   
    return related_users
  end
  
  def get_bom
    if  self.bom.nil? then
      self.bom = Bom.new(:name => "'BOM for project: ' + self.name")
      self.bom = @bom
    else
      bom = self.bom
    end   
  end
  
  def docs
    #get just current versions
    DocVersion.find(:all, :conditions => "project_id = '#{self.id}'  AND  current_version = TRUE", :order => "last_edited_at DESC")
  end  
  
  #
  #methods for tracking family tree of project
  #
def create_root
    #creates a root node
    clone_tree = CloneTree.create(:project_id => self.id, :lft => 1, :rt => 2, :relationship_type => "root")
    clone_tree.update_attribute(:rootnode, clone_tree.id)
    clone_tree.save
  end
  
  def make_new_clone(parent)
    #creates a new clone of project with projectid
    #NOTE if project in more than one tree, must create a new clone record IN EACH TREE
    parent.clone_trees.each do |pct|
      new_clone_tree = CloneTree.create(:project_id => self.id, :rootnode => pct.rootnode, :relationship_type => "clone")
      if pct.id == pct.rootnode  then
        #first clone of a project - MOST common - so we handle it specially
        new_clone_tree.update_attributes(:lft => pct.rt, :rt => pct.rt + 1)
        pct.update_attributes(:rt => pct.rt + 2)
        return
      end
      #the harder case: the tree already has more than one node
      new_lft = pct.rt 
      new_rt = pct.rt + 1
      
      #fix nodes to the "right"
      nodes_to_fix = CloneTree.find(:all, :conditions => "rootnode = '#{pct.rootnode}'", :conditions => "rt > '#{new_lft}'", :order => 'lft' )
      nodes_to_fix.each do |node|
        rt = node.rt + 2
        unless node.lft < new_lft then
          lft = node.lft + 2 
        else
          lft = node.lft
        end
        node.update_attributes(:lft => lft, :rt => rt)
      end
      
      #fix parent
      pct.update_attributes(:rt => new_rt + 1)
      new_clone_tree.update_attributes(:lft => new_lft, :rt => new_rt)      
    end
  end
  
  def delete_clone_tree
    #DO WE EVEN WANT THIS?????
    #deletes all relevant records from clone_tree.  Need to promote all its direct descendants
    #(children) - in ALL trees - to be roots and delete the clone tree entries for this project
    return false
  end
  
  def add_parent(parent)
    #similar to insert new 
    # MAYBE don't need this
    return false
  end
  
  def find_trees
    #get all the family trees (PLURAL) that this project is in
    clone_trees = Array.new
    #first find all the clone_tree entries for this project
    ct_records = CloneTree.find(:all, :conditions => "project_id = '#{self.id}'")
    ct_records.each do |r|
      clone_trees << CloneTree.find(:all, :conditions => "rootnode = '#{r.rootnode}'", :order => 'lft')
    end
    return clone_trees
  end

  def owner
    user_id = ProjectPerson.find(:first,
      :conditions => "relationship = 'owner' AND project_id = '#{ self.id }' ").user_id
    return User.find(user_id)
  end

  def home_page_image
    image = UploadedImage.fetch_single_image_for("project", self.id, "home_page")
  end

  def all_images
    images = UploadedImage.fetch_all_images_for("project", self.id)
  end

  def image_filename(thumb=nil)
    image = UploadedImage.fetch_single_image_for("project", self.id, "home_page")
    return nil if image.nil?
    image.public_filename(thumb) 
  end

  def image_name
    image = UploadedImage.fetch_single_image_for("project", self.id, "home_page")
    name = nil
    name = image.display_name unless image.nil?
  end

end

