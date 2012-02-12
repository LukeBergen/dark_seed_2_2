require 'gosu'
require './game'

class GameWindow < Gosu::Window
  def initialize
    super 800, 600, false
    self.caption = "Dark Seed 2: 2"
    @game = Game.new(self)
    @dialog_font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @dialog_scroll_height = 0
    @currently_selected_line = -1
  end
  
  def update
    @game.tick
  end
  
  def draw
    draw_quad(0, 0, Gosu::Color::WHITE, self.width, 0, Gosu::Color::WHITE, 0, self.height, Gosu::Color::WHITE, self.width, self.height, Gosu::Color::WHITE)
    @game.current_area.game_objects.each do |obj_name|
      @game.game_objects[obj_name].draw
    end
    mouse_img = @game.game_objects["game"].images["mouse.png"]
    mouse_img.draw(self.mouse_x - (mouse_img.width / 2), self.mouse_y - (mouse_img.height / 2), ZOrder::Mouse)
    if (@game.current_dialog_text)
      diag_x = 50
      diag_y = self.height - 120
      diag_width = 700
      diag_height = 100
      line_height = 23
      self.draw_quad(diag_x, diag_y, 0xff000000, diag_x+diag_width, diag_y, 0xff000000, diag_x+diag_width, diag_y+diag_height, 0xff000000, diag_x, diag_y+diag_height, 0xff000000, ZOrder::UI)
      dialog_lines = dialog_text_to_lines(@game.current_dialog_text)
      clip_to(diag_x, diag_y, diag_width, diag_height-20) do
        dialog_lines.each_with_index do |line, i|
          if (self.mouse_x > diag_x + 20 && self.mouse_x < diag_x + diag_width - 20 &&
              self.mouse_y > diag_y + 10 + (i*line_height) - @dialog_scroll_height && self.mouse_y < diag_y + 10 + ((i+1)*line_height) - @dialog_scroll_height )
            color = 0xffff00ff
            @currently_selected_line = i
          else
            color = 0xffffff00
          end
          @dialog_font.draw(line, 100, self.height - 110 + (i * line_height) - @dialog_scroll_height, ZOrder::DialogText, 1.0, 1.0, color)
        end
      end
      
    end
  end
  
  def dialog_text_to_lines(full_text)
    full_text.split("{NEWLINE}")
  end
  
  def button_down(id)
    if id == Gosu::KbEscape
      close
    elsif id == Gosu::MsLeft
      puts "left click at #{self.mouse_x}, #{self.mouse_y}"
      if (@game.current_dialog_text)
        if (@currently_selected_line >= 0)
          puts "line clicked: #{@currently_selected_line}"
        end
      else
        @game.left_click(self.mouse_x, self.mouse_y)
      end
    elsif id == Gosu::MsRight
      puts "#{self.mouse_x}, #{self.mouse_y}"
    elsif id == Gosu::KbReturn
      @game.finish_dialog
      @dialog_scroll_height = 0
    elsif id == Gosu::KbUp || id == Gosu::MsWheelDown
      if (@game.current_dialog_text)
        @dialog_scroll_height += 1
      end
    elsif id == Gosu::KbDown || id == Gosu::MsWheelUp
      if (@game.current_dialog_text)
        @dialog_scroll_height -= 1
      end
    else
      puts "bah"
    end
  end
  
end

window = GameWindow.new
window.show
