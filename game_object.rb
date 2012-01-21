require 'gosu'
require 'yaml'
require './animation'

class GameObject
  
  attr_accessor :x, :y, :name
  
  def initialize(win, name)
    @game_window = win
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
    load_media()
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
    @current_image.width
  end
  
  def height
    @current_image.height
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
  
  def click(x, y)
    puts "I've been clicked and I am #{name}"
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
    dirname = "./media/game_objects/#{@name}"
    
    if (File.exists?("#{dirname}/animations"))
      Dir.foreach("#{dirname}/animations") do |ani_dir|
        if (File.directory?("#{dirname}/animations/#{ani_dir}") && ani_dir != "." && ani_dir != ".." && ani_dir != ".DS_Store")
          ani = Animation.new()
          Dir.foreach("#{dirname}/animations/#{ani_dir}") do |filename|
            puts "loading animation #{dirname}/animations/#{ani_dir}"
            if (filename != "." && filename != ".." && filename != ".DS_Store" && filename != "config.yml")
              ani << Gosu::Image.new(@game_window, "#{dirname}/animations/#{ani_dir}/#{filename}", false)
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
          @images[image_file] = Gosu::Image.new(@game_window, "#{dirname}/images/#{image_file}", false)
        end
      end
    end
    
    if (File.exists?("#{dirname}/config.yml"))
      cfg = YAML::load(File.read("#{dirname}/config.yml"))
      @speed = cfg["speed"] if cfg && cfg["speed"]
      @current_img = cfg["initial_image"] if cfg && cfg["initial_image"]
    end
    
  end
    
end

# go = GameObject.new(Gosu::Window.new(640, 480, false), "main_guy")
