require File.dirname(__FILE__) + '/../test_helper'
require 'handset_controller'

# Re-raise errors caught by the controller.
class HandsetController; def rescue_action(e) raise e end; end

class HandsetControllerTest < Test::Unit::TestCase
  fixtures :users, :samples, :tags, :taggings
  
  def setup
    @controller = HandsetController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @update_tags_requests = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'fixtures', 'update_tags.yml'))
    @upload_sample_requests = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'fixtures', 'upload_sample.yml'))
  end
  
  # Replace this with your real tests.
  def test_update_tags_with_incomplete_params_fails
    assert_raise_message(RuntimeError, /auth/) { post :update_tags, {} } 
    assert_raise_message(RuntimeError, /auth/) { post :update_tags, @update_tags_requests["just_user_id"] } 
    assert_raise_message(RuntimeError, /user_id/) { post :update_tags, @update_tags_requests["just_auth"] } 
    assert_raise_message(RuntimeError, /auth/) { post :update_tags, @update_tags_requests["other_keys"] } 
  end
  
  def test_update_tags_with_incorrect_params_fails
    assert_raise_message(RuntimeError, /auth/) { post :update_tags, @update_tags_requests["wrong_auth_key"] } 
    assert_raise_message(RuntimeError, /user_id/) { post :update_tags, @update_tags_requests["not_integer_user_id"]  } 
    assert_raise_message(RuntimeError, /user_id/) { post :update_tags, @update_tags_requests["non_existent_user_id"]  } #not existent user id
  end
  
  def test_update_tags_with_good_params
    post :update_tags, @update_tags_requests["good_request"]
    assert_equal "1,Good,2;2,Bad,2;3,Ugly,1;6,Pretty,1", @response.body
    u = User.find(1) # based on the good_request and users fixture
    #puts u.inspect
    assert_not_nil u.last_log_time
   end
  
  def test_upload_sample_with_incomplete_params_fails
    assert_raise_message(RuntimeError, /auth/)  { post :upload_sample, {} } 
    assert_raise_message(RuntimeError, /auth/)  { post :upload_sample, @upload_sample_requests["without_auth"] } 
    assert_raise_message(RuntimeError, /user_id/)  { post :upload_sample, @upload_sample_requests["without_user_id"] } 
  end
  
  def test_upload_sample_with_incorrect_params_fails
    assert_raise_message(RuntimeError, /auth/) { post :upload_sample, @upload_sample_requests["wrong_auth"] }
    assert_raise_message(RuntimeError, /user_id/) { post :upload_sample, @upload_sample_requests["non_integer_user_id"] } 
    assert_raise_message(RuntimeError, /user_id/) { post :upload_sample, @upload_sample_requests["non_existent_user_id"] } #not existent user id
  end
  
  def test_upload_sample_with_good_params_succeeds
    post :upload_sample, @upload_sample_requests["minimal_good_request"]
    id = assigns(:sample).id
    assert Sample.exists?(id)
  end 

  def test_upload_sample_meal_exercise
    post :upload_sample, @upload_sample_requests["meal"]
    post :upload_sample, @upload_sample_requests["exercise"]
  end
  
  def test_upload_sample_with_tags
    post :upload_sample, @upload_sample_requests["two_tags"]
    s = Sample.find_by_id(assigns(:sample).id)
    assert_not_nil s
    assert_equal 2, s.tags.count
    assert_equal "cats, dogs", s.tag_list.to_s
  end 

  def test_upload_sample_with_one_image
    # "audio_file_-777976250 used for audio
    image = Attachment.create_multipart_for_testing("#{File.expand_path(RAILS_ROOT)}/test/fixtures/base64encoded.jpg", "image/jpeg")
    params = @upload_sample_requests["minimal_good_request"].merge("img_file_-758738805" => image)
    assert_equal 0, Attachment.count
    post :upload_sample, params
    assert_equal 1, Attachment.count
  end

  def test_upload_sample_with_two_images
    # "audio_file_-777976250 used for audio
    image1 = Attachment.create_multipart_for_testing("#{File.expand_path(RAILS_ROOT)}/test/fixtures/base64encoded.jpg", "image/jpeg")
    image2 = Attachment.create_multipart_for_testing("#{File.expand_path(RAILS_ROOT)}/test/fixtures/base64encoded.jpg", "image/jpeg")
    audio1 = Attachment.create_multipart_for_testing("#{File.expand_path(RAILS_ROOT)}/test/fixtures/base64encoded.jpg", "audio/x-amr")
    audio2 = Attachment.create_multipart_for_testing("#{File.expand_path(RAILS_ROOT)}/test/fixtures/base64encoded.jpg", "audio/AMR")
    params = @upload_sample_requests["minimal_good_request"].merge( \
            {"img_file_-758738805" => image1, "img_file_-128234805" => image2, \
            "audio_file_-777976250" => audio1, "audio_file_-333972250" => audio2})
    assert_equal 0, Attachment.count
    post :upload_sample, params
    assert_equal 4, Attachment.count
    sample_id = assigns(:sample).id
    sample = Sample.find(sample_id)
    assert_equal 2, sample.images.size 
    assert_equal 2, sample.audios.size
    assert_equal 3, sample.tag_list.names.size
  end

  def test_upload_followup
    post :upload_followup, @upload_sample_requests["upload_followup_1"]
    s = Sample.find_by_id(assigns(:sample).id)
    assert_equal 123, s.followup_glucose
    assert_equal 4, s.tag_list.names.size
  end
  
  def assert_raise_message(types, matcher, message = nil, &block)
    args = [types].flatten + [message]
    exception = assert_raise(*args, &block)
    assert_match matcher, exception.message, message
  end
end
