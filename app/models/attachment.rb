require 'base64'

class Attachment < ActiveRecord::Base
  has_attachment :content_type => Sample::IMAGE_CONTENT_TYPES + Sample::AUDIO_CONTENT_TYPES, 
                 :storage => :file_system, 
                 :max_size => 500.kilobytes,
                 :path_prefix => "/public/attachments"
                 
  validates_as_attachment
  
  belongs_to :sample
  
  def self.create_from_file(file_name, content_type)
    uploaded_file = Attachment.create_uploaded_file(file_name, content_type)
    Attachment.new(:uploaded_data => uploaded_file)
  end
 
 # this parameter may be of StringIO or Tempfile type, need to watch out...
  def self.create_from_base64_multipart(uploaded_chunk)
    decrypted_temp_file_path = decrypt_base64(uploaded_chunk)
    decrypted_temp_file_path = convert_to_mp3_if_amr_audio(decrypted_temp_file_path, uploaded_chunk.content_type)
    Attachment.create_from_file(decrypted_temp_file_path, uploaded_chunk.content_type)
  end

  def self.create_multipart_for_testing(path, content_type)
    create_uploaded_file(path, content_type)
  end
  
  def self.convert_to_mp3_if_amr_audio(file_path, content_type)
    return file_path unless (content_type.strip == "audio/x-amr") || (content_type.strip == "audio/AMR")
    command = ENV['MP3CMD'] || 'cp %s %s' # stub it with simple copy in case MP3CMD is not defined
    command = sprintf(command, file_path, "#{file_path}.mp3")
    begin
      logger.info "Running: #{command}"
      system(command)
    rescue => err
      logger.error err
      logger.error "Could not convert to MP3, importing AMR file"
      return file_path
    end
    return "#{file_path}.mp3"
  end
    
  private

  # get us an object that represents an uploaded file
  def self.create_uploaded_file(path, content_type="application/octet-stream", filename=nil)
    filename ||= File.basename(path)
    t = Tempfile.new(filename)
    FileUtils.copy_file(path, t.path)
    (class << t; self; end;).class_eval do
      alias local_path path
      define_method(:original_filename) { filename }
      define_method(:content_type) { content_type }
    end
    return t
  end

   
  # this parameter may be of StringIO or Tempfile type, need to watch out...
  def self.decrypt_base64(uploaded_chunk)
    out_file = Tempfile.new(File.basename(uploaded_chunk.original_filename || "somefile"))
    begin
      out_file.write(Base64.decode64(uploaded_chunk.readlines.join))
    ensure
      out_file.close
    end
    
    return out_file.path
  end
 end
