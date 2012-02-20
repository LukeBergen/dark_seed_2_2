require 'ruby-debug'
require 'gosu'
require './game'

class GameWindow < Gosu::Window
  def initialize
    super 800, 600, false
    self.caption = "Dark Seed 2: 2"
    @game = Game.new(self)
    @dialog_font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @mouse_img = @game.game_objects["Game"].images["mouse.png"]
    @dialog_background = @game.game_objects["Game"].images["dialog_background.png"]
    @dialog_scroll_height = 0
    @currently_selected_line = -1
  end
  
  def update
    if self.text_input
      @last ||= ""
      @last = self.text_input.text
      if self.text_input.text[-1] == Gosu::KbEnter
        @game.instance_eval(self.text_input.text)
        self.text_input = nil
      end
    else
      @game.tick
    end
  end
  
  def draw
    
    draw_quad(0, 0, Gosu::Color::WHITE, self.width, 0, Gosu::Color::WHITE, 0, self.height, Gosu::Color::WHITE, self.width, self.height, Gosu::Color::WHITE)
    
    if (self.text_input)
      #@dialog_font.draw(self.text_input, 500, 200, ZOrder::SuperTop, 1.0, 1.0, 0x000000ff)
      self.draw_quad(480, 90, Gosu::Color::BLACK, 700, 90, Gosu::Color::BLACK,
                     480, 130, Gosu::Color::BLACK, 700, 130, Gosu::Color::BLACK, ZOrder::Background)
      @dialog_font.draw(self.text_input.text, 500, 100, ZOrder::DialogEntities, 1.0, 1.0, 0xffffffff)
    end
    
    @game.current_area.draw
    @game.current_area.game_objects.each do |obj_name|
      @game.game_objects[obj_name].draw
    end
    @mouse_img.draw(self.mouse_x - (@mouse_img.width / 2), self.mouse_y - (@mouse_img.height / 2), ZOrder::Mouse)
    
    # This whole thing needs to be re-thought a little.
    # @game.current_dialog_text needs to be replaced with something like @game.current_dialog_hash
    # and main.rb just needs to be smart about it.  This might be one place where it just doesn't make
    # sense for game.rb to have the logic
    if (@game.current_menu)
      menu_obj = @game.game_objects[@game.current_menu]
      display_objs = [menu_obj] + menu_obj.menu_objects.collect {|obj_name| @game.game_objects[obj_name]}
      display_objs.each do |obj|
        obj.draw
      end
    end
    if (@game.current_dialog_hash)
      diag_x = 50
      diag_y = self.height - 120
      diag_width = 700
      diag_height = 100
      line_height = 23
      #self.draw_quad(diag_x, diag_y, 0xff000000, diag_x+diag_width, diag_y, 0xff000000, diag_x+diag_width, diag_y+diag_height, 0xff000000, diag_x, diag_y+diag_height, 0xff000000, ZOrder::DialogBackground)
      @dialog_background.draw(diag_x, diag_y, ZOrder::DialogBackground)
      dialog_lines = dialog_text_to_lines(@game.current_dialog_hash)
      clip_to(diag_x, diag_y, diag_width, diag_height-20) do
        dialog_lines.first.each_with_index do |line, i|
          @dialog_font.draw(line, 100, self.height - 110 + (i * line_height) - @dialog_scroll_height, ZOrder::DialogEntities, 1.0, 1.0, Gosu::Color::WHITE)
        end
        c = dialog_lines.first.count + 1
        self.draw_quad(diag_x + 10, diag_y + (line_height * c) - 4 - @dialog_scroll_height, Gosu::Color::GREEN,
                       diag_x + diag_width - 10, diag_y + (line_height * c) - 4 - @dialog_scroll_height, Gosu::Color::WHITE,
                       diag_x + 10, diag_y + (line_height * c) + 4 - @dialog_scroll_height, Gosu::Color::GREEN,
                       diag_x + diag_width - 10, diag_y + (line_height * c) + 4 - @dialog_scroll_height, Gosu::Color::WHITE,
                       ZOrder::DialogEntities)
        dialog_lines.last.each_with_index do |line, i|
          if (self.mouse_x > diag_x + 20 && self.mouse_x < diag_x + diag_width - 20 &&
              self.mouse_y > diag_y + 10 + ((i+c)*line_height) - @dialog_scroll_height && self.mouse_y < diag_y + 10 + ((i+c+1)*line_height) - @dialog_scroll_height )
            color = 0xffff00ff
            @currently_selected_line = i
          else
            color = 0xffffff00
          end
          @dialog_font.draw(line, 100, self.height - 110 + ((i+c) * line_height) - @dialog_scroll_height, ZOrder::DialogEntities, 1.0, 1.0, color)
        end
      end
      
    end
  end
  
  def dialog_text_to_lines(dialog_hash)
    [dialog_hash["text"].split("{NEWLINE}")] + [dialog_hash["responses"].collect {|h| h["text"]}]
  end
  
  def button_down(id)
    if id == Gosu::KbEscape
      close
    elsif id == Gosu::MsLeft
      puts "left click at #{self.mouse_x}, #{self.mouse_y}"
      if (@game.current_dialog_hash)
        if (@currently_selected_line >= 0)
          actions = @game.current_dialog_hash["responses"][@currently_selected_line]["actions"]
          @game.finish_dialog
          @dialog_scroll_height = 0
          @currently_selected_line = -1
          @game.do_actions(actions)
        end
      else
        @game.left_click(self.mouse_x, self.mouse_y)
      end
    elsif id == Gosu::MsRight
      puts "#{self.mouse_x}, #{self.mouse_y}"
    elsif id == Gosu::KbReturn
      if self.text_input
        begin
          @game.instance_eval(self.text_input.text)
        rescue
          puts "didn't understand how to do that: #{self.text_input.text}"
        end
        self.text_input = nil
      else
        @game.finish_dialog
        @dialog_scroll_height = 0
      end
    elsif id == Gosu::KbUp || id == Gosu::MsWheelDown
      if (@game.current_dialog_hash)
        @dialog_scroll_height += 1
      end
    elsif id == Gosu::KbDown || id == Gosu::MsWheelUp
      if (@game.current_dialog_hash)
        @dialog_scroll_height -= 1
      end
    elsif id == 50     # 50 is the ` key
      self.text_input = Gosu::TextInput.new
    else
      puts "button pressed: #{id}"
    end
  end
  
end

window = GameWindow.new
window.show
