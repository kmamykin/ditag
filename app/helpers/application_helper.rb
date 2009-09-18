# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def tag_cloud_calculate(tags)
    classes = %w(tag_weight1 tag_weight2 tag_weight3 tag_weight4 tag_weight5)
    max, min = 0, 0
    tags.each do |t|
      max = t.count.to_i if t.count.to_i > max
      min = t.count.to_i if t.count.to_i < min
    end
    
    divisor = ((max - min) / classes.size) + 1
    
    tags.each do |t|
      yield t, classes[(t.count.to_i - min) / divisor]
    end
  end
  
  def local_time_label(time_at)
    return "Unknown" if time_at.nil?
    TzTime.zone.utc_to_local(time_at.utc).to_s :shortampm
  end
  
  def user_label(u)
    u.id == current_user.id ? "Me" : u.login
  end
  
  def time_ago(time_at)
    return "N/A" if time_at.nil?
    time_ago_in_words(time_at, false) << " ago"
  end
  
  def back_link
    link_to_unless request.env['HTTP_REFERER'].nil?, 'Back', request.env['HTTP_REFERER']
  end
 
  def embedded_player(audio_url)
    #"<script language='JavaScript' type='text/javascript'>QT_WriteOBJECT('#{audio_url}', '160', '20', '', 'autoplay', 'false', 'align', 'middle');</script>"
    simple_object_tag audio_url, :width=>160, :height=>20, :autostart => "0"
  end
end
