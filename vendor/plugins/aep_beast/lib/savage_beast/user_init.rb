
module SavageBeast

  module UserInit

    def self.included(base)
      base.class_eval do

       include ProjectModule

				has_many :moderatorships, :dependent => :destroy
				has_many :forums, :through => :moderatorships, :order => "#{Forum.table_name}.name"

				has_many :posts
				has_many :topics
				has_many :monitorships
				has_many :monitored_topics, :through => :monitorships, :conditions => ["#{Monitorship.table_name}.active = ?", true], :order => "#{Topic.table_name}.replied_at desc", :source => :topic

				#implement in your user model 
				#def display_name
					#"implement display_name in your user model"
				#end
				
				#implement in your user model 
				#def admin?
					#false
				#end
				
        def moderator_of?(forum)  #instance
        forum = Forum.find(forum) unless forum.is_a?(Forum)
        if forum.subject_type == 'project' then
          project = Project.find(forum[:subject_id])
        else
          item = Item.find(forum[:subject_id])
          project = item.bom.project
        end
        self.is_editor?(project)
        end

        def to_xml(options = {})  #instance
          options[:except] ||= []
          super
        end
      end
      base.extend(ClassMethods)
    end

    module ClassMethods			
			#implement in your user model 
			#def currently_online
				#false
			#end
			
			#def search(query, options = {})
				#with_scope :find => { :conditions => build_search_conditions(query) } do
					#options[:page] ||= nil
					#paginate options
				#end
			#end
			
			#implmement to build search coondtitions
			#def build_search_conditions(query)
				# query && ['LOWER(display_name) LIKE :q OR LOWER(login) LIKE :q', {:q => "%#{query}%"}]
				#query
			#end
			
			def moderator_of?(forum)  #class
        forum = Forum.find(forum) unless forum.is_a?(Forum)
        if forum.subject_type == 'project' then
          project = current_project(forum.subject_id)
        else
          item = Item.find(subject_id)
          project = item.bom.project
        end
        self.is_editor?(project)
			end
			
			def to_xml(options = {})  #class
				options[:except] ||= []
				options[:except] << :email << :login_key << :login_key_expires_at << :password_hash << :openid_url << :activated << :admin
				super
			end
			
			def update_posts_count
				self.class.update_posts_count id
			end
			
			def update_posts_count(id)
				User.update_all ['posts_count = ?', Post.count(:id, :conditions => {:user_id => id})],   ['id = ?', id]
			end
			
    end
      
  end
end
