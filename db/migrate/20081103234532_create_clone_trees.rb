class CreateCloneTrees < ActiveRecord::Migration
  def self.up
    create_table :clone_trees do |t|
      t.integer :project_id
      t.integer :lft
      t.integer :rt
      t.integer :rootnode
      t.string  :relationship_type
      t.timestamps
    end
    puts "Setting primary keys"
    execute "CREATE INDEX index_clone_trees_on_project_id ON clone_trees (project_id)"     
    execute "CREATE INDEX index_clone_trees_on_rootnode ON clone_trees (rootnode)" 
  end
  
  def self.down
    drop_table :clone_trees
  end
end
