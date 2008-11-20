class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer           :user_id, :null => false
      t.integer           :project_id, :null => false
      t.integer           :action, :null => false
      t.string            :data 
      t.text              :body
      
      t.integer           :target_id
      t.string            :target_type
      
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
