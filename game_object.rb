require 'gosu'
require './animation'

class GameObject
  
  attr_accessor :x, :y
  
  def initialize(win, name)
    @game_window = win
    @name = name
    @x = @y = 0.0
    @dx = @dy = @new_x = @new_y = nil
    @speed = 0.1
    @showing = @moving = false
    @animations = {}
    @images = {}
    @current_animation = nil
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
  
  def current_image
    @current_image
  end
  
  def draw
    @current_image.draw(@x, @y, 0) if @current_image
  end
  
  def move(new_x, new_y, proc=nil)
    @new_x = new_x
    @new_y = new_y
    dist = Gosu::distance(@x, @y, @new_x, @new_y)
    angle = (@x - @new_x) / (@y - @new_y)
    @dx = Gosu::offset_x(angle, dist)
    @dy = Gosu::offset_y(angle, dist)
    @after_move_proc = proc
    @moving = true
  end
  
  def tick
    if @moving
      if (Gosu::distance(@x, @y, @new_x, @new_y) < @speed)
        @x = @new_x
        @y = @new_y
        @new_x = @new_y = @dx = @dy = nil
        @moving = false
        if (@after_move_proc)
          self.instance_eval(@after_move_proc)
          @after_move_proc = nil
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
    @current_animation = @animations[ani_name]
  end
  
  def stop_animation
    @current_animation.reset
    @current_animation = nil
  end
  
  def set_image(img_name)
    @current_image = @images[img_name]
  end
  
  def load_media
    dirname = "./media/game_objects/#{@name}"
    Dir.foreach("#{dirname}/animations") do |ani_dir|
      if (File.directory?("#{dirname}/animations/#{ani_dir}") && ani_dir != "." && ani_dir != ".." && ani_dir != ".DS_Store")
        ani = Animation.new()
        Dir.foreach("#{dirname}/animations/#{ani_dir}") do |filename|
          puts "loading animation #{dirname}/animations/#{ani_dir}"
          if (filename != "." && filename != ".." && filename != ".DS_Store")
            ani << Gosu::Image.new(@game_window, "#{dirname}/animations/#{ani_dir}/#{filename}", false)
          end
        end
        @animations[ani_dir] = ani
      end
    end
    
    Dir.foreach("#{dirname}/images") do |image_file|
      if (image_file != "." && image_file != ".." && image_file != ".DS_Store")
        puts "loading image #{dirname}/images/#{image_file}"
        @images[image_file] = Gosu::Image.new(@game_window, "#{dirname}/images/#{image_file}", false)
      end
    end
  end
    
end

# go = GameObject.new(Gosu::Window.new(640, 480, false), "main_guy")
