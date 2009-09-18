class TagsController < ApplicationController
  before_filter :login_required
  
  def tagged
    params[:tags] ||= ""
    tag_list = TagList.from(params[:tags]) # important to use .from as it accepts and parses delimited string
    @tag = tag_list.names.length == 1 ? Tag.find_by_name(tag_list.names[0]) : nil

    @selected_tags = tag_list.names.to_a
    
    @remove_tag_links={}
    tag_list.names.each do |tag|
      @remove_tag_links[tag] = (tag_list.names - [tag]).join(",")
    end
    
    @add_tag_links={}
    @samples = Sample.find_tagged_with_or_all(tag_list, current_user)
    related_tags = Sample.find_other_related_tags(tag_list, @samples)
    related_tags.names.each do |tag|
      @add_tag_links[tag] = (tag_list.names + [tag]).join(",")
    end
  end
  
  def tag_history
    @tag = Tag.find_by_name(params[:id])
    @tag_history = @tag.description_history
  end
  
  def set_tag_description
    t = Tag.find_by_name(params[:id])
    t.record_description(params[:value], current_user)
    render_text text_to_html(t.description)
  end
  
  def get_tag_description
    t = Tag.find_by_name(params[:id])
    render_text t.description
  end
  
  def list
    @tag_counts = Sample.tag_counts
  end

end
