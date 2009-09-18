require File.dirname(__FILE__) + '/../test_helper'
require 'tags_controller'

# Re-raise errors caught by the controller.
class TagsController; def rescue_action(e) raise e end; end

class TagsControllerTest < Test::Unit::TestCase
  
  fixtures :users, :samples, :tags, :taggings
  
  def setup
    @controller = TagsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  # Replace this with your real tests.
  def test_tagged_request_for_no_tags
    login_as(:quentin)
    post :tagged, {:tags=>nil}
    assert_response :success
    assert_nil assigns(:tag)
    assert_equal [], assigns(:selected_tags)
    assert_equal Hash[], assigns(:remove_tag_links)
    assert_equal Hash['Good'=>'Good', 'Bad'=>'Bad', 'Ugly'=>'Ugly', 'Question'=>'Question', 'Crazy sugar'=>'Crazy sugar', 'Pretty'=>'Pretty'], assigns(:add_tag_links)
    assert_equal 4, assigns(:samples).size
  end
  
  def test_tagged_request_for_one_tag
    login_as(:quentin)
    post :tagged, {:tags=>'Good'}
    assert_response :success
    assert_not_nil assigns(:tag)
    assert_equal ['Good'], assigns(:selected_tags)
    assert_equal Hash['Good'=>''], assigns(:remove_tag_links)
    assert_equal Hash['Bad'=>'Good,Bad', 'Ugly'=>'Good,Ugly'], assigns(:add_tag_links)
    assert_equal 2, assigns(:samples).size
  end
  
  def test_tagged_request_for_multiple_tags
    login_as(:quentin)
    post :tagged, {:tags=>'Good,Bad'}
    assert_response :success
    assert_nil assigns(:tag)
    assert_equal ['Good','Bad'], assigns(:selected_tags)
    assert_equal Hash['Good'=>'Bad', 'Bad'=>'Good'], assigns(:remove_tag_links)
    assert_equal Hash['Ugly'=>'Good,Bad,Ugly'], assigns(:add_tag_links)
    assert_equal 2, assigns(:samples).size
  end

  def test_tagged_request_for_one_tag_for_group2
    login_as(:aaron) # belongs to group 2
    post :tagged, {:tags=>'Pretty'}
    assert_response :success
    assert_not_nil assigns(:tag)
    assert_equal ['Pretty'], assigns(:selected_tags)
    assert_equal Hash['Pretty'=>''], assigns(:remove_tag_links)
    assert_equal Hash[], assigns(:add_tag_links)
    assert_equal 1, assigns(:samples).size
  end

  def test_tagged_request_for_admin_returns_all_samples
    login_as(:admin) # belongs to group 1
    post :tagged, {:tags=>''}
    assert_response :success
    assert_nil assigns(:tag)
    assert_equal Sample.count, assigns(:samples).size
  end

  def test_tagged_request_for_admin_returns_all_samples
    login_as(:admin) # belongs to group 1
    post :tagged, {:tags=>'Pretty'}
    assert_response :success
    assert_not_nil assigns(:tag)
    assert_equal 1, assigns(:samples).size
  end

end
