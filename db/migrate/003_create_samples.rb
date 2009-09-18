class CreateSamples < ActiveRecord::Migration
  def self.up
    create_table :samples do |t|
      t.column :recorded_at, :datetime, :null=>false
      t.column :user_id, :integer, :null=>false
      t.column :glucose, :integer, :null=>true
      t.column :followup_glucose, :integer, :null=>true
      t.column :activity_type, :string, :null=>false
      t.column :carbohydrates, :integer, :null=>true
      t.column :fat, :integer, :null=>true
      t.column :protein, :integer, :null=>true
      t.column :calories, :integer, :null=>true
      t.column :time, :integer, :null=>true
      t.column :comment, :text, :null=>true #for now all comments will be appended to the same text field
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
   end
  end

  def self.down
    drop_table :samples
  end
end
