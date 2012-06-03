require 'gosu'

class Area
  
  TILES_PER_WINDOW_WIDTH = 80
  TILES_PER_WINDOW_HEIGHT = 64
  
  attr_accessor :name
  
  def initialize(game, name)
    @game = game
    @name = name
    @background_image = (Gosu::Image.new(game.window, "./data/areas/#{name}/background.png", false) rescue nil)
    @foreground_image = (Gosu::Image.new(game.window, "./data/areas/#{name}/foreground.png", false) rescue nil)
    @walkable_map = (Marshal::load(File.open("./data/areas/#{name}/walkable_map.marshal", "r") {|f| f.read}) rescue nil)
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
  
  def path_exists?(from_x, from_y, to_x, to_y)
    return true unless @walkable_map
    
    # TODO actual checking based on @walkable_map
    
  end
  
  def get_path(from_x, from_y, to_x, to_y)
    # if there is no map to say where you can't go, just go straight to the endpoint
    return [[to_x, to_y]] unless @walkable_map
    
    # TODO figure out a set of x, y points to move through to get from current x, y to destination x, y
    
  end
  
end