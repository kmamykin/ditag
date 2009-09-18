require File.dirname(__FILE__) + '/../test_helper'

class SampleTest < Test::Unit::TestCase
  fixtures :users, :samples, :taggings, :tags

  def test_find_other_related_tags
    other_tags = Sample.find_other_related_tags(TagList.from("Good"))
    assert other_tags.names.include?("Bad")
    assert other_tags.names.include?("Ugly")
  end
  
  def test_activity
    assert_equal "Meal: 2 carbs, 3 fat, 4 protein", Sample.find(2).activity
    assert_equal "Exercise: 2345 calories, 30 min", Sample.find(3).activity
    assert_equal "Other", Sample.find(4).activity
  end
end
