class TaggingsController < ApplicationController

  def create
    tagging = build_tagging_and_set_tag_values_taggable_id(params[:tag])
    get_taggable_type(params[:taggable_type].to_s)
    tag = Tag.find(tagging.tag_id)
    if tag.parent_id.nil?
      parent_id = nil
    else
      parent_id = '?parent_id='+tag.parent_id.to_s
    end
    tagging.save
    get_tags(tag.parent_id)
    @tag = tag
    respond_to do |format|
      if parent_id.nil?
        format.html { redirect_to '/edit_' << params[:taggable_type].to_s.downcase << '_taggings?instance=' << @the_instance.id.to_s }
      else
        format.html { redirect_to '/edit_' << params[:taggable_type].to_s.downcase << '_taggings' << parent_id.to_s << '&instance=' << @the_instance.id.to_s }
      end
      format.js { 
        render '/taggings/base.js.erb' 
      }
    end
  end
  
  def destroy
    get_taggable_type(params[:taggable_type].to_s)
    tagging = Tagging.find_by_taggable_type_and_taggable_id_and_tag_id(@the_instance.class.to_s, @the_instance.id, params[:tag])
    tag = Tag.find(tagging.tag_id)
    if tag.parent_id.nil?
      parent_id = nil
    else
      parent_id = '?parent_id='+tag.parent_id.to_s
    end
    tagging.destroy
    get_tags(tag.parent_id)
    @tag = tag
    respond_to do |format|
      if parent_id.nil?
        format.html { redirect_to '/edit_' << params[:taggable_type].to_s.downcase << '_taggings?instance=' << @the_instance.id.to_s }
      else
        format.html { redirect_to '/edit_' << params[:taggable_type].to_s.downcase << '_taggings' << parent_id.to_s << '&instance=' << @the_instance.id.to_s }
      end
      format.js { 
        render '/taggings/base.js.erb' 
      }
    end
  end
  
  def add_tagging_and_remove_the_rest
    get_taggable_type(params[:taggable_type].to_s)
    tag = Tag.find(params[:tag])
    tags_to_remove = Tag.find_all_by_parent_id(params[:tag])
    tags_to_remove.each do |tag|
      unless tag.taggings.find_by_tag_id_and_taggable_id(tag.id, params[:taggable_id]).nil?
        tag.taggings.find_by_tag_id_and_taggable_id(tag.id, params[:taggable_id]).destroy
      end
    end
    unless params[:child_tag][:id].to_s.eql?('')
      tagging = build_tagging_and_set_tag_values_taggable_id(params[:child_tag][:id])
      tagging.save
    end
    @tag = tag
    # for base.js.erb
    @update = true
    respond_to do |format|
      format.html { 
        unless tag.parent_id.nil?
          redirect_to '/edit_' << params[:taggable_type].to_s.downcase << '_taggings?instance=' << @the_instance.id.to_s << '&parent_id=' << tag.parent_id.to_s
        else
          redirect_to '/edit_' << params[:taggable_type].to_s.downcase << '_taggings?instance=' << @the_instance.id.to_s
        end
      }
      format.js { 
        get_tags(nil)
        render '/taggings/base.js.erb' 
      }
    end
  end
  
  def refresh_available_tags
    get_taggable_type(params[:taggable_type].to_s)
    get_tags(params[:tag])
    respond_to do |format|
      format.js { render '/taggings/refresh.js.erb' }
    end
  end
  
  private
  
  def get_tags(parent_id)
    @added_tags =  @the_instance.tags.find_all_by_parent_id(parent_id)
    if @the_instance.class.to_s.eql?('Item')
      the_class = @the_instance.item_type.to_s
    else
      the_class = @the_instance.class.to_s
    end
    @available_tags =  Tag.find_all_by_parent_id_and_taggable_type(parent_id, the_class) - @added_tags
  end
  
  def get_taggable_type(type)
    the_class = Kernel.const_get(type)
    if the_class.superclass.to_s.eql?('Item')
      the_class = Kernel.const_get('Item')
    end
    @the_instance = the_class.find(params[:taggable_id])
  end
  
  def build_tagging_and_set_tag_values_taggable_id(tag_id)
    tagging = Tagging.new
    the_class = Kernel.const_get(params[:taggable_type].to_s)
    if the_class.superclass.to_s.eql?('Item')
      the_class = Kernel.const_get('Item')
    end
    tagging.taggable_type = the_class.to_s
    tagging.tag_id = tag_id
    tagging.taggable_id = params[:taggable_id]
    return tagging
  end
  
end