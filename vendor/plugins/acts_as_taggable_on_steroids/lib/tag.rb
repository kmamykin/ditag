class Tag < ActiveRecord::Base
  has_many :taggings
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  class << self
    delegate :delimiter, :delimiter=, :to => TagList
  end
  
  def ==(object)
    super || (object.is_a?(Tag) && name == object.name)
  end
  
  def to_s
    name
  end
  
  def count
    read_attribute(:count).to_i
  end
  
  # ****************** custom added by kmamykin
  #has_many :user_tag_descriptions #, :order => "created_at, id DESC"
  
  def has_description?
    description_history.length > 0
  end

  def record_description(desc_text, editor)
    description_record = UserTagDescription.new(:description => desc_text)
    description_record.user = editor
    description_record.tag = self
    description_record.save
  end
  
  def description
    desc = UserTagDescription.find(:first, :conditions => {:tag_id => id}, :order => "created_at DESC", :select => "description")
    desc.nil? ? "" : desc.description
  end
  
  def description_history
    UserTagDescription.find(:all, :conditions => {:tag_id => id}, :order => "created_at, id DESC")
  end
end
