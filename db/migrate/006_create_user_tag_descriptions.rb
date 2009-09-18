class CreateUserTagDescriptions < ActiveRecord::Migration
  def self.up
    create_table :user_tag_descriptions do |t|
      t.column :user_id,                    :integer, :null => false
      t.column :tag_id,                     :integer, :null => false
      t.column :description,                :text
      t.column :created_at,                 :datetime
    end
  end

  def self.down
    drop_table :user_tag_descriptions
  end
end
