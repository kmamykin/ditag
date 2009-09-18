require "base64"

class HandsetController < ApplicationController
  layout false
  
  MAGIC_AUTH_VALUE = "a457c19eef"
  
  skip_filter :set_user_timezone # no current user to set timezone for
  around_filter :set_server_timezone
  before_filter :validate_handset_request
  
  def upload_sample
    if params.has_key?("log")
      # just a logging post
    else
      @sample = Sample.new() do |s|
        s.user = @user
        s.recorded_at = TzTime.now.utc
        s.glucose = params[:glucose] || 0
        s.activity_type = params[:activity_type] || "Other"
        case s.activity_type
          when "Meal"
            s.carbohydrates, s.fat, s.protein = params[:meal_descriptor].split(";") if params.has_key?(:meal_descriptor)
          when "Exercise"
            s.calories, s.time = params[:exercise_descriptor].split(";") if params.has_key?(:exercise_descriptor)
        end
        #s.comment = "Submitted through phone"
        s.tag_list = params[:tags].gsub(/;/, ",") if params.has_key?(:tags)
      end
      @sample.save!
      @sample.reload
      params.each do |key,value|
        if key.starts_with?("img_file_") or key.starts_with?("audio_file_")
          process_file(value)
        end
      end
    end
  end
  
  def upload_followup
    @sample = Sample.find(params[:sample_id])
    @sample.followup_glucose = params[:glucose]
    @sample.tag_list.add(params[:tags].split(";")) if params.has_key?(:tags)
    @sample.save!
  end
  
  def update_tags
    @tags = Sample.tag_counts
  end
  
  protected

  def process_file(incoming_file)
    a = Attachment.create_from_base64_multipart( incoming_file )
    a.sample = @sample
    a.save! 
  end
  
  def validate_handset_request
    check_mandatory_params( [:auth, :user_id] )
    check_auth_and_handset_number
  end
  
  def check_mandatory_params(must_haves)
    must_haves.each do |p| 
      raise "#{p} parameter is missing" unless params.has_key?(p) 
    end
  end
  
  def check_auth_and_handset_number()
    raise "auth has incorrect value" unless params[:auth] == HandsetController::MAGIC_AUTH_VALUE
    @user = User.find_by_handset_number(params[:user_id])
    raise "user_id does not correspond to handset_number" if @user.nil?
    @user.last_log_time = TzTime.now.utc
    @user.save!
  end
  
  # need to set the current timezone = to the server timezone, because the recorded_at of the samples is determined on the server
  def set_server_timezone
    TzTime.zone = TimeZone[ENV['TZ']] # TZ environment variable is set in the environment.rb and is different for production
    yield
    TzTime.reset!
  end
  
end
