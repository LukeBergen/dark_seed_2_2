require 'gosu'
require './game'

class GameWindow < Gosu::Window
  def initialize
    super 640, 480, false
    self.caption = "Gosu Tutorial Game"
    @game = Game.new(self)
    @game.load_state
  end
  
  def update
    @game.tick
  end
  
  def draw
    draw_quad(0, 0, Gosu::Color::WHITE, self.width, 0, Gosu::Color::WHITE, 0, self.height, Gosu::Color::WHITE, self.width, self.height, Gosu::Color::WHITE)
    @game.game_objects.each do |obj_name, obj|
      obj.draw if obj.show?
    end
  end
  
  def button_down(id)
    if id == Gosu::KbEscape
      close
    elsif id == Gosu::MsLeft
      puts "left click at #{self.mouse_x}, #{self.mouse_y}"
      @game.left_click(self.mouse_x, self.mouse_y)
    elsif id == Gosu::MsRight
      puts "#{self.mouse_x}, #{self.mouse_y}"
    else
      puts "bah"
    end
  end
  
end

window = GameWindow.new
window.show
