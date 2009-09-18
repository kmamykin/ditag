require File.dirname(__FILE__) + '/../test_helper'

class TagTest < Test::Unit::TestCase
  fixtures :users, :samples, :taggings, :tags

  def test_sample_tag_behaves_like_tag
    t = Tag.find_by_name("Good")
    assert t.taggings.length > 0
  end
  
  def test_new_tags_have_no_description
    t = Tag.create(:name => "Something unique")
    assert ! t.has_description?
    assert_equal "", t.description
  end
  
  def test_adding_descsiption_makes_it_current
    t = Tag.create(:name => "Something unique1")
    u = User.find(1)
    t.record_description("this is description text", u)
    assert "this is description text", t.description
  end
  
  def test_adding_many_descsiptions_makes_last_current
    t = Tag.create(:name => "Something unique2")
    u = User.find(1)
    t.record_description("text1", u)
    t.record_description("text2", u)
    t.record_description("text3", u)
    assert "text3", t.description
  end
  
  def test_history_records_all_descriptions
    t = Tag.create(:name => "Something unique3")
    u1 = User.find(1)
    u2 = User.find(2)
    t.record_description("text1", u1)
    t.record_description("text2", u2)
    t.record_description("text3", u1)
    t = Tag.find_by_name("Something unique3")
    assert "text3", t.description
    hist = t.description_history
    #puts hist.inspect
    assert_equal 3, hist.length
    assert_equal "text3", hist[0].description
    assert_equal u1.id, hist[0].user.id
    assert_equal "text2", hist[1].description
    assert_equal u2.id, hist[1].user.id
    assert_equal "text1", hist[2].description
    assert_equal u1.id, hist[2].user.id
    
  end
 
end
