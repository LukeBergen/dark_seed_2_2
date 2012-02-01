require 'gosu'
require 'yaml'
require './animation'

class GameObject
  
  attr_accessor :x, :y, :name, :state, :game
  
  def initialize(game_obj, name)
    @game = game_obj
    @name = name
    @x = @y = 0.0
    @dx = @dy = @new_x = @new_y = nil
    @speed = 5.0
    @showing = @moving = false
    @animations = {}
    @images = {}
    @current_animation = nil
    @notify_when_done = nil
    @current_image = nil
    reload()
  end
  
  def show?
    @showing
  end
  
  def show
    @showing = true
  end
  
  def hide
    @showing = false
  end
  
  def position=(arr)
    @x, @y = *arr
  end
  
  def position
    [@x, @y]
  end
  
  def width
    @current_image.width if @current_image
  end
  
  def height
    @current_image.height if @current_image
  end
  
  def current_image
    @current_image
  end
  
  def draw
    @current_image.draw(@x, @y, 0) if @current_image
  end
  
  def move(new_x, new_y, notification=nil)
    @new_x = new_x
    @new_y = new_y
    dist = Gosu::distance(@x, @y, @new_x, @new_y)
    #slope = (@y - @new_y) / (@x - @new_x)
    @dx = (@new_x - @x) / dist
    @dy = (@new_y - @y) / dist
    
    @notify_when_done = notification
    @moving = true
  end
  
  def tick
    if @moving
      if (Gosu::distance(@x, @y, @new_x, @new_y) < @speed)
        @x = @new_x
        @y = @new_y
        @new_x = @new_y = @dx = @dy = nil
        @moving = false
        if (@notify_when_done)
          @notify_when_done.trigger
        end
      else
        @x += (@dx * @speed)
        @y += (@dy * @speed)
      end
    end
    
    if (@current_animation)
      @current_image = @current_animation.tick
    end
  end
  
  def start_animation(ani_name)
    puts "setting @current_animation to #{@animations[ani_name]}"
    @current_animation = @animations[ani_name]
  end
  
  def stop_animation
    puts "about to try to stop #{@current_animation}"
    @current_animation.reset if @current_animation
    @current_animation = nil
  end
  
  def set_image(img_name)
    @current_image = @images[img_name]
  end
  
  def images
    @images
  end
  
  def load_media
    dirname = "./data/game_objects/#{@name}"
    
    if (File.exists?("#{dirname}/animations"))
      Dir.foreach("#{dirname}/animations") do |ani_dir|
        if (File.directory?("#{dirname}/animations/#{ani_dir}") && ani_dir != "." && ani_dir != ".." && ani_dir != ".DS_Store")
          ani = Animation.new()
          Dir.foreach("#{dirname}/animations/#{ani_dir}") do |filename|
            puts "loading animation #{dirname}/animations/#{ani_dir}"
            if (filename != "." && filename != ".." && filename != ".DS_Store" && filename != "config.yml")
              ani << Gosu::Image.new(game.window, "#{dirname}/animations/#{ani_dir}/#{filename}", false)
            end
            if (filename == "config.yml")
              cfg = YAML::load(File.read("#{dirname}/animations/#{ani_dir}/config.yml"))
              if (cfg.is_a?(Hash))
                ani.speed = cfg["speed"]
              end
            end
          end
          @animations[ani_dir] = ani
        end
      end
    end
    
    if (File.exists?("#{dirname}/images"))
      Dir.foreach("#{dirname}/images") do |image_file|
        if (image_file != "." && image_file != ".." && image_file != ".DS_Store")
          puts "loading image #{dirname}/images/#{image_file}"
          @images[image_file] = Gosu::Image.new(game.window, "#{dirname}/images/#{image_file}", false)
        end
      end
    end
    
    if (File.exists?("#{dirname}/config.yml"))
      cfg = YAML::load(File.read("#{dirname}/config.yml"))
      @speed = cfg["speed"] if cfg && cfg["speed"]
      @current_img = cfg["initial_image"] if cfg && cfg["initial_image"]
    end
    
  end
  
  def reload()
    load_media()
    load_logic()
  end
  
  def load_logic()
    # first require anything under data/game_objects/#{@name}/logic.rb
    # then require everything under data/state/current/logics/#{@name}
    begin
      load("./data/game_objects/#{@name}/logic.rb")
      self.extend(Kernel.const_get(@name))
    rescue LoadError
    end
  end
  
  def on_click(mouse_x, mouse_y)
    on_examine()
  end
  
  def on_examine()
    game.do_monolog(monologs["test"])
  end
  
  def monologs()
    {
      "test" => {
        "text" => "This is some text{NEWLINE}NEW LINE{NEWLINE}Then WHOLE NOTHER NEW LINE{NEWLINE}Then the last one",
        "audio" => "audio file"
      }
    }
  end
  
  def dialogs()
    {}
  end
  
  def do_dialog()
    
  end
  
  def set_state()
    
  end
  
  def respond_to_notification(message, params=nil)
    if (params && params.is_a?(Array))
      params.each do |p|
        self.instance_eval(p)
      end
    end
  end
  
end

# go = GameObject.new(Gosu::Window.new(640, 480, false), "main_guy")
