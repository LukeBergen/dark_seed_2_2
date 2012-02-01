require 'gosu'
require './game'

class GameWindow < Gosu::Window
  def initialize
    super 800, 600, false
    self.caption = "Gosu Tutorial Game"
    @game = Game.new(self)
    @dialog_font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @game.load_state
  end
  
  def update
    @game.tick
  end
  
  def draw
    draw_quad(0, 0, Gosu::Color::WHITE, self.width, 0, Gosu::Color::WHITE, 0, self.height, Gosu::Color::WHITE, self.width, self.height, Gosu::Color::WHITE)
    @game.current_area.game_objects.each do |obj_name|
      @game.game_objects[obj_name].draw if @game.game_objects[obj_name].show?
    end
    mouse_img = @game.game_objects["game"].images["mouse.png"]
    mouse_img.draw(self.mouse_x - (mouse_img.width / 2), self.mouse_y - (mouse_img.height / 2), ZOrder::Mouse)
    if (@game.current_dialog_text)
      diag_x = 50
      diag_y = self.height - 200
      diag_width = 700
      diag_height = 150
      self.draw_quad(diag_x, diag_y, 0xff000000, diag_x+diag_width, diag_y, 0xff000000, diag_x+diag_width, diag_y+diag_height, 0xff000000, diag_x, diag_y+diag_height, 0xff000000, ZOrder::UI)
      dialog_lines = dialog_text_to_lines(@game.current_dialog_text)
      @dialog_font.draw(@game.current_dialog_text, 100, self.height - 100, ZOrder::DialogText, 1.0, 1.0, 0xffffffff)
    end
  end
  
  def dialog_text_to_lines(full_text)
    
  end
  
  def button_down(id)
    if id == Gosu::KbEscape
      close
    elsif id == Gosu::MsLeft
      puts "left click at #{self.mouse_x}, #{self.mouse_y}"
      @game.left_click(self.mouse_x, self.mouse_y)
    elsif id == Gosu::MsRight
      puts "#{self.mouse_x}, #{self.mouse_y}"
    elsif id == Gosu::KbReturn
      @game.finish_dialog
    else
      puts "bah"
    end
  end
  
end

window = GameWindow.new
window.show
