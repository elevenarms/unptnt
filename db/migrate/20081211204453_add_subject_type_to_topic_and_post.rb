class AddSubjectTypeToTopicAndPost < ActiveRecord::Migration
  def self.up
    add_column :topics, :subject_id, :integer
    add_column :topics, :subject_type, :string
    add_column :posts, :subject_id, :integer
    add_column :posts,  :subject_type, :string
  end

  def self.down
    remove_column :topics, :subject_id
    remove_column :topics, :subject_type
    remove_column :posts, :subject_id
    remove_column :posts, :subject_type
  end
end
