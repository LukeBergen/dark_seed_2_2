require 'gosu'

class Area
  
  attr_accessor :name, :game_objects
  
  def initialize(game, name)
    @game = game
    @name = name
    @game_objects = []
    @background_image = (Gosu::Image.new(game.window, "./data/areas/#{name}/background.png", false) rescue nil)
    @foreground_image = (Gosu::Image.new(game.window, "./data/areas/#{name}/foreground.png", false) rescue nil)
  end
  
  def draw
    @background_image.draw(0, 0, ZOrder::Background) if @background_image
    @foreground_image.draw(0, 0, ZOrder::Foreground) if @foreground_image
  end
  
end