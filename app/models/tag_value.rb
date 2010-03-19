class TagValue < ActiveRecord::Base
  attr_accessible :tag_id, :taggable_id, :taggable_type, :language, :value, :type
  belongs_to :tag
  belongs_to :value_taggable, :polymorphic => true
end
