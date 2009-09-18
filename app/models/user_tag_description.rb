class UserTagDescription < ActiveRecord::Base
  belongs_to :user
  
  belongs_to :tag
  
  validates_associated :user, :tag
  validates_presence_of :user_id, :tag_id, :description
end
