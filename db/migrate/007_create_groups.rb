class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
       t.column :name,  :string, :null=>false
    end
    add_column :users, :group_id, :integer, :null=>false
    g1 = Group.create(:name=>"Group 1")
    g2 = Group.create(:name=>"Group 2")
    User.find(:all).each do |u|
      u.group_id = g1.id
      u.save!
    end
  end

  def self.down
    remove_column :users, :group_id
    drop_table :groups
  end
end
