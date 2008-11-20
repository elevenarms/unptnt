class CreateStatuses < ActiveRecord::Migration
  def self.up
    create_table :statuses do |t|
      t.integer :project_id
      t.string :status_text, :limit => 140
      t.timestamps
    end
  end

  def self.down
    drop_table :statuses
  end
end
