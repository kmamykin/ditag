class SamplesController < ApplicationController
  before_filter :login_required
  
    def index
      if current_user.admin?
        @users = User.find(:all)
        @total_tag_counts = Sample.tag_counts
        render :action => 'index_admin'
      else
        @samples = current_user.samples.find(:all, :order => "recorded_at DESC", :limit => 5)
        @tag_counts = current_user.samples.tag_counts
        @total_tag_counts = Sample.tag_counts
        render :action => 'index_user'
      end
    end
  
  def show
    @sample = Sample.find(params[:id])
  end
  
  def new
    @sample = Sample.new
    @sample.recorded_at = TzTime.zone.now # set the default
  end
  
  def list
    params[:id] ||= current_user.id
    @user = User.find(params[:id])
    @samples = @user.samples
  end
  
  def feedback
    # render view
  end
  
  def submit_feedback
    Notifier.deliver_feedback(current_user, params[:feedback_text])
    render :action=> 'feedback_thankyou'
  end
  
  def create
    @sample = Sample.new(params[:sample])
    @sample.recorded_at = TzTime.zone.local_to_utc(@sample.recorded_at) # convert local time passed through params to UTC
    @sample.user = current_user
    @sample.activity_type = 'Other'
    
    if @sample.save
      @sample.reload
      
      unless params[:audio].nil? or params[:audio][:uploaded_data].nil? or (params[:audio][:uploaded_data].kind_of?(String) and params[:audio][:uploaded_data].empty?)
        audio = Attachment.new(params[:audio])
        audio.sample = @sample
        audio.save!
      end
      
      unless params[:image].nil? or params[:image][:uploaded_data].nil? or (params[:audio][:uploaded_data].kind_of?(String) and params[:image][:uploaded_data].empty?)
        image = Attachment.new(params[:image])
        image.sample = @sample
        image.save!
      end
      
      flash['notice'] = 'Sample was successfully created.'
      redirect_to :action => 'index'
    else
      render_action 'new'
    end
  end
  
  
  def set_sample_tag_list
    sample = Sample.find(params[:id])
    sample.tag_list = params[:value]
    sample.save!
    sample.reload
    render_text sample.tag_list.to_s
  end
  
  def set_sample_comment
    sample = Sample.find(params[:id])
    sample.comment = "" if sample.comment.nil?
    sample.comment << "\n*" << current_user.login << "*(" << TzTime.now.to_s(:short) << ")\n" << params[:value]
    sample.save!
    sample.reload
    render_text text_to_html(sample.comment)
  end
  
  def get_sample_comment
    render_text ""
  end
  
  def just_comment
    @sample = Sample.find(params[:id])
  end
end
