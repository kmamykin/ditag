class Sample < ActiveRecord::Base
  IMAGE_CONTENT_TYPES = ["image/jpeg", "image/gif", :image]
  AUDIO_CONTENT_TYPES = ["audio/x-amr", "audio/AMR", "audio/mpeg"]
  acts_as_taggable
  #relationships
  belongs_to :user
  has_many :attachments
  
  validates_associated :user
  validates_presence_of :recorded_at, :user_id, :glucose, :activity_type
  validates_inclusion_of :activity_type, :in => %w( Meal Exercise Other ), :message => 'Activity Type must be either Meal, Exercise or Other'
  validates_numericality_of :glucose, :only_integer => true, :allow_nil => false
  validates_numericality_of :followup_glucose, :only_integer => true, :allow_nil => true
  validates_numericality_of :carbohydrates, :only_integer => true, :allow_nil => true
  validates_numericality_of :fat, :only_integer => true, :allow_nil => true
  validates_numericality_of :protein, :only_integer => true, :allow_nil => true
  validates_numericality_of :calories, :only_integer => true, :allow_nil => true
  validates_numericality_of :time, :only_integer => true, :allow_nil => true
  
  def audios
    attachments.find(:all, :conditions => ["content_type IN (?)",  AUDIO_CONTENT_TYPES ])
  end
  
  def images
    attachments.find(:all, :conditions => ["content_type IN (?)",  IMAGE_CONTENT_TYPES])
  end
  
  def activity
    case activity_type
    when "Meal"
        "Meal: #{carbohydrates} carbs, #{fat} fat, #{protein} protein"
    when "Exercise"
        "Exercise: #{calories} calories, #{time} min"
    when "Other"    
        "Other"
    end   
  end
  
  def glucose_text
    followup_glucose.nil? ? "Pre: #{glucose}" : "Pre: #{glucose}, Post: #{followup_glucose}"
  end
  
  def self.find_other_related_tags(tag_list, samples=nil)
    return TagList.new(Tag.find(:all).collect{|t| t.name }) if tag_list.names.empty?
    
    samples = samples || Sample.find_tagged_with(tag_list.names, :match_all => true)
    other_tags = []
    samples.each do |s|
      other_tags.concat(s.tag_list.names - other_tags)
    end
    return TagList.new(other_tags - tag_list.names)
  end
  
  def self.find_tagged_with_or_all(tag_list, querying_user)
    sort_by = "recorded_at DESC"
    if querying_user.admin?
      tag_list.names.empty? ? \
        Sample.find( :all, :order=>sort_by ) : \
        Sample.find_tagged_with(tag_list.names, :match_all => true, :order=>sort_by)
    else
      # first we will get a list of user_ids that belong to the same group as the querying user
      users_in_group = User.find_all_by_group_id(querying_user.group_id )
      user_id_array = users_in_group.collect {|u| u.id}
      conditions = ["user_id IN (?)",  user_id_array]
      tag_list.names.empty? ? \
        Sample.find( :all, :order=>sort_by, :conditions => conditions ) : \
        Sample.find_tagged_with(tag_list.names, :match_all => true, :order=>sort_by, :conditions => conditions)
    end
  end
end
