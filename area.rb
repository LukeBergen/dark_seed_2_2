require 'gosu'

class Area
  
  attr_accessor :name, :game_objects
  
  def initialize(game, name)
    @game = game
    @name = name
    @game_objects = []
    @background_image = Gosu::Image.new(game.window, "./data/areas/#{name}/background.png", false)
    @foreground_image = Gosu::Image.new(game.window, "./data/areas/#{name}/foreground.png", false)
  end
  
  def draw
    @background_image.draw(0, 0, ZOrder::Background)
    @foreground_image.draw(0, 0, ZOrder::Foreground)
  end
  
end