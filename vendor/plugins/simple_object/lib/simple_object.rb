##################################################
# Author: Michael Cerna
# SimpleObject
# Rails embed/object tag helper
module SimpleObjectHelper
  DEFAULT_WIDTH = 320
  DEFAULT_HEIGHT = 320
  
  # Renders an object/embed tag for media!
  # You can pass whatever parameters make sense,
  # But the goal of this is to glean as many 
  # default parameters from the source filename
  # as possible.
  def simple_object_tag(source, options = {})

    # MK Begin
    options[:contenttype] ||= source2contenttype(source)
    # MK End    

    # The OBJECT Tag gets built last, with the inner tags, and
    # content-defined attributes
    content = get_param_tags_for_source_and_options(source,options)
    content << embed_tag(get_embed_options_from_source_and_options(source,options))
    content_tag :object, content.join("\n"), get_object_options_from_source_and_options(source,options)
  
  end

  
  # generate the embed tag
  def embed_tag(options)
    tag :embed, options
  end
  
  # generate a single param tag
  def param_tag(name,value)
    tag :param, :name=>name,:value=>value unless value.blank?
  end

  # generate sensible param tags
  def get_param_tags_for_source_and_options(source,options)
    param_tags = [param_tag(:src,source)]
    options[:width] ||= SimpleObjectHelper::DEFAULT_WIDTH
    options[:height] ||= SimpleObjectHelper::DEFAULT_HEIGHT
	
#    case source # ORIGINAL
    case options[:contenttype]
#    when /mov/
    when "video/quicktime"
      options[:target] ||= "quicktime"
      options[:controller] ||= "true"
      options[:kioskmode] ||= "false"
#    when /swf/,/flv/
		when "application/x-shockwave-flash"
      options[:movie] ||= source
      options[:src] ||= source
      options[:wmode] ||= "transparent"
      options[:loop] ||= "false"
      options[:quality] ||= "high"
      options[:salign] ||= ""
      options[:menu] ||= "-1"
      options[:base] ||= ""
      options[:allowscriptaccess] ||= "always"
      options[:scale] ||= "showall"
      options[:devicefont] ||= "0"
      options[:embedmovie] ||= "0"
      options[:bgcolor] ||= "transparent"
      options[:swremote] ||= ""
      options[:moviedata] ||= ""
      options[:seamlesstabbing] ||= "1"
#    when /wmv/i,/avi/i,/mpg/i,/mpeg/i,/mp4/i
    when "video/x-ms-wmv", "video/x-msvideo", "video/mpeg", "video/mp4"
      options[:filename] ||= source
      options[:bgcolor] ||= "transparent"
      options[:autostart] ||= "1"
      options[:scale] ||= "aspect"
      options[:type] ||= "application/x-mplayer2"
      options[:showcontrols] ||= "1"
      options[:windowlessvideo] ||= "0"
		when "audio/mp3"
    end
    
    options.each do |key,value|
      param_tags << param_tag(key,value)
    end
    return param_tags
  end

  # generate the attributes for the object tag
  def get_object_options_from_source_and_options(source,options)

#    case source
    case options[:contenttype]
#    when /mov/
    when "video/quicktime"
      return {:width=>(options[:width]||SimpleObjectHelper::DEFAULT_WIDTH),
              :height=>(options[:height]||SimpleObjectHelper::DEFAULT_HEIGHT),
              :vspace=>(options[:vspace]||"0"),
              :hspace=>(options[:hspace]||"0"),
              :codebase=>"http://www.apple.com/qtactivex/qtplugin.cab",
              :classid=>"clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B"}
#    when /swf/,/flv/
		when "application/x-shockwave-flash"
      return {:codebase=>"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=5,0,0,0", 
              :classid=>"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"}
      
#    when /wmv/i,/avi/i,/mpg/i,/mpeg/i,/mp4/i
    when "video/x-ms-wmv", "video/x-msvideo", "video/mpeg", "video/mp4"
      return {:width=>(options[:width]||SimpleObjectHelper::DEFAULT_WIDTH),
              :height=>(options[:height]||SimpleObjectHelper::DEFAULT_HEIGHT),
              :classid=>"CLSID:22D6F312-B0F6-11D0-94AB-0080C74C7E95",
              :scale=>(options[:scale]||"aspect")}
    end
    return {}
  end

  # generate the embed tag from the global options
  def get_embed_options_from_source_and_options(source,options)
    embed_options = {:width=>(options[:width]||SimpleObjectHelper::DEFAULT_WIDTH),
                      :height=>(options[:height]||SimpleObjectHelper::DEFAULT_HEIGHT),
                      :src=>source,
                      :autostart=>(options[:autostart]||"1")
                    }
		case options[:contenttype]
#    case source
#    when /mov/
    when "video/quicktime"
      embed_options[:controller] = params[:controller]||"true"
      embed_options[:target] = "quicktime"
      embed_options[:pluginspage] = "http://www.apple.com/quicktime"
#    when /swf/,/flv/
		when "application/x-shockwave-flash"
      embed_options[:quality] = "high"
      embed_options[:bgcolor] = options[:bgcolor]||"transparent"
      embed_options[:type] = options[:type]||"application/x-shockwave-flash"
      embed_options[:pluginspage] = "http://www.macromedia.com/go/getflashplayer"
      embed_options[:flashvars] = options[:flashvars] if options[:flashvars]
#    when /wmv/i,/avi/i,/mpg/i,/mpeg/i,/mp4/i
    when "video/x-ms-wmv", "video/x-msvideo", "video/mpeg", "video/mp4"
      embed_options[:type] = "application/x-mplayer2" 
      embed_options[:autostart] = "1" 
      embed_options[:scale] = "aspect" 
      embed_options[:showcontrols] = "1"      
    end
    return embed_options
  end
    
# MK Begin
	
	def source2contenttype(source)
		case source
    when /mov$/i
			"video/quicktime"
    when /swf$/i ,/flv$/i
			"application/x-shockwave-flash"
    when /wmv$/i
			"video/x-ms-wmv"
		when /avi$/i
			"video/x-msvideo"
		when /mpg$/i, /mpeg$/i
			"video/mpeg"
		when /mp4$/i
			"video/mp4"
		when /mp3$/i
			"audio/mpeg"
		end

	end
	
# MK End

end

