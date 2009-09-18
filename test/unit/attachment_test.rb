require File.dirname(__FILE__) + '/../test_helper'

class AttachmentTest < Test::Unit::TestCase
  fixtures :users, :samples

  # Replace this with your real tests.
  def test_create_from_unencoded_file
    a = Attachment.create_from_file("#{File.expand_path(RAILS_ROOT)}/test/fixtures/image.jpg", 'image/jpeg')
    a.sample = samples("sample_one")
    assert a.save
    assert File.exists?("#{File.expand_path(RAILS_ROOT)}/public#{a.public_filename}")
  end
  
  def test_create_from_encoded_file
    file_base64 = Attachment.create_multipart_for_testing("#{File.expand_path(RAILS_ROOT)}/test/fixtures/base64encoded.jpg", 'image/jpeg')
    a = Attachment.create_from_base64_multipart(file_base64)
    a.sample = samples("sample_one")
    assert a.save
    assert File.exists?("#{File.expand_path(RAILS_ROOT)}/public#{a.public_filename}")
  end
 
end
