require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include SavageBeast::UserInit

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  before_create :make_activation_code 
  
  acts_as_taggable_on  :proj_types, :keywords
  has_many  :projects, :through => 'project_person'
  has_many :project_people
  has_many :boms, :through => :project
  has_many :events
  has_many :doc_versions, :foreign_key => "editor_id"
  
  has_attached_file :user_image, 
                    :styles => { :medium => "300x300>",
                                 :thumb => "40x40>" }
                               
  validates_presence_of :invitation_id, :message => 'is required'
  validates_uniqueness_of :invitation_id

  has_many :sent_invitations, :class_name => 'Invitation', :foreign_key => 'sender_id'
  belongs_to :invitation

  before_create :set_invitation_limit
  
  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation, :user_image, :invitation_token
  
   #Activates the user in the database.
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    return false
    @activated
  end

  def active?
    return true
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
  
  def is_editor?(project)
    self.relationship(project) == 'owner' || self.relationship(project) == 'collaborator' 
  end
  
  def is_owner?(project)
    if self.relationship(project) == 'owner' then true
    else false
    end    
  end
  
  def relationship(project)
    proj_person = ProjectPerson.find(:first, :conditions => "project_people.user_id = '#{self.id}' && project_people.project_id = '#{project.id}'")
    if proj_person.nil? then return "none"
    else return proj_person.relationship
    end
  end
  
  def related_projects
    project_people = ProjectPerson.find(:all, :conditions => "user_id = '#{self.id}'")
    related_projects = { :owns => [], :following => [], :collaborating => [] }
    project_people.each do |pp|
      case pp.relationship
      when "owner" :  related_projects[:owns] << pp.project
      when "follower" : related_projects[:following] << pp.project
      when "collaborator" : related_projects[:collaborating] << pp.project        
      end
    end
    return related_projects
  end
  
  def related_events
     user_projects = self.related_projects
     all_events = Array.new
     unless user_projects[:owns].empty?
       user_projects[:owns].each do |e|
         all_events <<  e.events
       end
     end
     unless user_projects[:following].empty?
       user_projects[:following].each do |e|
         all_events << e.events
       end
     end
     unless user_projects[:collaborating].empty?
       user_projects[:collaborating].each do |e|
         all_events << e.events
       end
     end
     #all_events.sort { |a,b| b[:date] <=> a[:date] }
     return all_events.flatten
   end
   
  def invitation_token
    invitation.token if invitation
  end

  def invitation_token=(token)
    self.invitation = Invitation.find_by_token(token)
  end
  
  def docs
    #get just current versions
    DocVersion.find(:all, :conditions => "editor_id = '#{self.id}'  AND  current_version = TRUE", :order => "last_edited_at DESC")
  end

  # the following four methods are implemented to support aep_beast

  def self.currently_online
    # assume this returns an array of all users who are currently logged in
    false
  end

  def display_name
    # name to display for the user
    self.login
  end

  def admin?
    # is this person a forum administrator - nobody is
    false
  end

  def build_search_conditions(query)
		query && ['LOWER(display_name) LIKE :q OR LOWER(login) LIKE :q', {:q => "%#{query}%"}]
		query
	end

  private

  def set_invitation_limit
    self.invitation_limit = 5
  end
  
  protected
    
    def make_activation_code
        self.activation_code = self.class.make_token
    end
  end

