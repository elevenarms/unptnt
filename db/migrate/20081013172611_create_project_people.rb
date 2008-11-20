class CreateProjectPeople < ActiveRecord::Migration
  def self.up
    create_table :project_people do |t|
      t.integer :project_id
      t.integer :user_id
      t.string :relationship
      t.timestamps
    end
  end

  def self.down
    drop_table :project_people
  end
end
