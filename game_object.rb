require 'gosu'
require 'yaml'
undef y
require './animation'

class GameObject
  
  attr_accessor :name, :state, :game
  
  def initialize(game, name, dirname=nil)
    @game = game
    @name = name
    @dx = @dy = @new_x = @new_y = nil
    @speed = 5.0
    @moving = false
    @animations = {}
    @images = {}
    @current_animation = nil
    reload(dirname)
  end
  
  def method_missing(meth_name, *args, &block)
    raw_meth_name = meth_name.to_s.gsub("=", "")
    
    self.class.send(:define_method, raw_meth_name) {get_state(raw_meth_name)}
    self.class.send(:define_method, raw_meth_name+"=") {|arg| set_state(raw_meth_name, arg)}
    
    puts "you tried accessing something that previously didn't exist: #{meth_name}(#{args})"
    puts "because state = #{self.state}"
    puts "and now still..  #{meth_name}(#{args})"
    
    if (args.length > 0)
      return self.send(meth_name, *args)
    else
      return self.send(meth_name)
    end
  end
  
  def width
    if current_image
      current_image.width
    else
      0
    end
  end
  
  def height
    if current_image
      current_image.height
    else
      0
    end
  end
  
  def current_image
    @current_animation ? @current_animation.image : @images[get_state("current_image")]
  end
  
  def draw
    current_image.draw((x || 0.0), (y || 0.0), (z || 0.0)) if current_image
  end
  
  def move(new_x, new_y)
    @new_x = new_x
    @new_y = new_y
    dist = Gosu::distance((x || 0.0), (y || 0.0), @new_x, @new_y)
    #slope = (@y - @new_y) / (@x - @new_x)
    @dx = (@new_x - (x || 0.0)) / dist
    @dy = (@new_y - (y || 0.0)) / dist
    
    set_state("moving", true)
  end
  
  def tick
    if get_state("moving")
      if (Gosu::distance((x || 0.0), (y || 0.0), @new_x, @new_y) < @speed)
        self.x = @new_x
        self.y = @new_y
        @new_x = @new_y = @dx = @dy = nil
        set_state("moving", false)
      else
        self.x = (x || 0.0) + (@dx * @speed)
        self.y = (y || 0.0) + (@dy * @speed)
      end
    end
    
    if (@current_animation)
      @current_animation.tick
    end
    
    if (get_state("dragging"))
      self.x = @game.mouse_x - self.mouse_offset_x
      self.y = @game.mouse_y - self.mouse_offset_y
    end
    
  end
  
  def start_animation(ani_name)
    @current_animation = @animations[ani_name]
  end
  
  def stop_animation
    @current_animation.reset if @current_animation
    @current_animation = nil
  end
  
  def set_image(img_name)
    set_state("current_image", img_name)
  end
  
  def images
    @images
  end
  
  def reload(dirname=nil)
    load_media(dirname)
    load_logic(dirname)
  end
  
  def load_media(dirname=nil)
    dirname = "./data/game_objects/#{@name}" unless dirname
    
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
  
  def load_logic(dirname=nil)
    # first require anything under data/game_objects/#{@name}/#{@name}.rb
    begin
      dirname ||= @name
      load("./data/game_objects/#{dirname}/#{dirname}.rb")
      self.extend(Kernel.const_get(@name))
    rescue Exception => e
      puts "Exception occurred trying to load logic for #{self.name}.  Exception follows:"
      puts e.backtrace
    end
    
    @state = game.state[self.name]
    
  end
  
  def current_area=(area_name)
    move_to(area_name)
  end
  
  def move_to(area_name, x=nil, y=nil)
    game.move_object(self.name, area_name, x, y)
  end
  
  def init
    
  end
  
  def on_click(mouse_x, mouse_y)
    if (get_state("Game", "can_move"))
      game.do_player_move(self.x + examine_from_xy.first, self.y + examine_from_xy.last, ["game_objects['#{self.name}'].on_examine()"])
    end
  end
  
  def on_drag_complete(mouse_x, mouse_y)
    obj = @game.mouse_over_objects(mouse_x, mouse_y, "mouse_up").first
    obj.tell(:acted_on_by, self) if obj
  end
  
  def tell(meth_name, *args)
    if (self.respond_to?(meth_name))
      self.send(meth_name, *args)
    end
  end
  
  def on_examine()
    #game.do_dialog(dialogs()[get_state("next_dialog")])
  end
  
  def enter_coordinates(from_area, to_area)
    game.enter_coordinates(from_area, to_area)
  end
  
  def animate(ani_name, after=[])
    # TODO. objects need to be able to do animations and then do actions on animation complete
  end
  
  def examine_from_xy()
    [0, 0]
  end
  
  def dialogs()
    {}
  end
  
  def get_state(state_name_or_obj_name, state_name=nil)
    if state_name
      @game.get_state(state_name_or_obj_name, state_name)
    else
      @game.get_state(self.name, state_name_or_obj_name)
    end
  end
  
  def set_state(object_name_or_state_name, state_name_or_value, value=nil)
    if (value)
      @game.set_state(object_name_or_state_name, state_name_or_value, value)
    else
      @game.set_state(self.name, object_name_or_state_name, state_name_or_value)
    end
  end
  
  def respond_to_notification(message, params=nil)
    puts "responding to notification: #{message}"
    if (params && params.is_a?(Array))
      params.each do |p|
        self.instance_eval(p)
      end
    end
  end
  
end

# go = GameObject.new(Gosu::Window.new(640, 480, false), "main_guy")
