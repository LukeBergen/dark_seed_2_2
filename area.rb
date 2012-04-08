require 'gosu'

class Area
  
  attr_accessor :name
  
  def initialize(game, name)
    @game = game
    @name = name
    @background_image = (Gosu::Image.new(game.window, "./data/areas/#{name}/background.png", false) rescue nil)
    @foreground_image = (Gosu::Image.new(game.window, "./data/areas/#{name}/foreground.png", false) rescue nil)
  end
  
  def draw
    @background_image.draw(0, 0, ZOrder::Background) if @background_image
    @foreground_image.draw(0, 0, ZOrder::Foreground) if @foreground_image
  end
  
  def game_objects
    @game.get_state("area_#{self.name}", "objects") || []
  end
  
  def add_object(obj_name)
    @game.set_state("area_#{self.name}", "objects", (@game.get_state("area_#{self.name}", "objects") || []) + [obj_name])
  end
  
  def remove_object(obj_name)
    @game.set_state("area_#{self.name}", "objects", (@game.get_state("area_#{self.name}", "objects") || []) - [obj_name])
  end
  
end