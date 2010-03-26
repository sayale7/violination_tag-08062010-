class Instrument < ActiveRecord::Base
  attr_accessible :user_id, :instrument_kind
  
  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :tag_values, :as => :taggable, :dependent => :destroy
  has_many :tags, :order => 'position', :through => :taggings
  has_many :tags_over_value, :through => :tag_values
  belongs_to :user
  
  def instrument_kind_choose
    %w{Streichinstrument Blasinstrument}
  end
  
  private
  
  def assign_german_tag_value
    self.tag_values.find_by_language('de').update_attributes(:taggable_id => self.id)
  end

  def assign_english_tag_value
    self.tag_values.find_by_language('en').update_attributes(:language => 'en', :tag_id => self.id, :taggable_type  => @taggable_type, :type => @type)
  end
  
end
