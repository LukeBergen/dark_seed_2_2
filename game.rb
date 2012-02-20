require './game_object'
require './area'

module ZOrder
  Background, Player, Objects, Foreground, ForegroundObjects, DialogBackground, DialogEntities, Menu1, Menu2, Menu3, Mouse, SuperTop = *1..12
end

class Game
  
  attr_accessor :current_menu
  
  def initialize(parent_win)
    @game_window = parent_win
    @game_objects = load_game_objects()
    @areas = load_areas()
    @current_area = nil
    @current_dialog_hash = nil
    @current_menu = nil
    @notifications = []
    @inventory = []
    @frames = 0
    @state = nil
    load_state()
  end
  
  def tick
    @game_objects.each do |obj_name, obj|
      obj.tick
    end
    check_notifications
    @frames += 1
  end
  
  def load_areas
    {"dev_room" => Area.new(self, "dev_room")}
  end
  
  def current_area
    @areas[@current_area]
  end
  
  def window
    @game_window
  end
  
  def load_state(state_name="default")
    if (state_name)
      # TODO if state is passed in, load from a state file or something
      state = YAML::load(File.read("./data/state/#{state_name}/state.yml"))
      @current_area = state["Current Area"]
      @state = state["Game State"]
      @state.each do |obj_name, variables|
        if (variables.keys.include?("current image"))
          @game_objects[obj_name].set_image(variables["current image"])
        end
        if (variables.keys.include?("current area"))
          if @areas.keys.include?(variables["current area"])
            @areas[variables["current area"]].game_objects << obj_name
          end
        end
        if (variables.keys.include?("x pos") && variables.keys.include?("y pos"))
          @game_objects[obj_name].position = [variables["x pos"], variables["y pos"]]
        end
      end
      
      puts "EVERYTHING LOADED."
    else
      @current_area = "dev_room"
      @game_objects["mark"].show
      @game_objects["mark"].position = [300, 300]
      @game_objects["mark"].set_image("idle.png")
      current_area.game_objects << "mark"
    end
  end
  
  def game_objects
    @game_objects
  end
  
  def left_click(x, y)
    # figure out action
    clicked_obj = nil
    current_area.game_objects.each do |obj_name|
      next if (obj_name == "game")
      obj = @game_objects[obj_name]
      if (x >= obj.x && y >= obj.y && x <= (obj.x + obj.width) && y <= (obj.y + obj.height))
        clicked_obj = obj
      end
    end
    
    if (clicked_obj)
      clicked_obj.on_click(x, y)
    else
      puts "you clicked an area.  Moving to that area"
      do_player_move(x, y)
    end
  end
  
  def do_player_move(x, y, after_move=nil)
    @notifications.each do |noti|
      if (noti.obj_name == "mark" && noti.message = "move complete")
        @notifications.delete(noti)
      end
    end
    @game_objects["Mark"].start_animation("move")
    noti = register_notification("Mark", "move complete", ["game_objects['Mark'].stop_animation", "game_objects['Mark'].set_image('idle.png')"] + (after_move || []))
    @game_objects["Mark"].move(x, y, noti)
  end
  
  def do_dialog(dialog_hash)
    if (dialog_hash && dialog_hash.class == Hash)
      @current_dialog_hash = dialog_hash
    else
      @current_dialog_hash = @game_objects[dialog_hash].dialogs()[get_state(dialog_hash, "next dialog")]
    end
  end
  
  def finish_dialog
    @current_dialog_hash = nil
  end
  
  def current_dialog_hash
    @current_dialog_hash
  end
  
  def do_actions(actions)
    actions.each do |action|
      puts "doing action: #{action}"
      self.instance_eval(action)
    end
  end
  
  def register_notification(obj_name, message, params=nil)
    noti = Notification.new(obj_name, message, params)
    @notifications << noti
    noti
  end
  
  def notify(obj, message)
    @notifications.each do |noti|
      if (noti.obj_name == obj.name && noti.message == message)
        noti.triggered = true
      end
    end
  end
  
  def check_notifications
    @notifications.each do |noti|
      if (noti.triggered)
        #game_objects[noti.obj_name].respond_to_notification(noti.message, noti.params)
        if (noti.params && noti.params.is_a?(Array))
          noti.params.each do |p|
            puts "evaling: #{p}"
            self.instance_eval(p)
          end
        end
        @notifications.delete(noti)
      end
    end
  end
  
  def save_game(save_name="save1")
    puts "saving game: #{save_name}"
  end
  
  def load_game(save_name="save1")
    puts "loading game: #{save_name}"
  end
  
  def set_state(obj_name, state_name, state_val)
    puts "trying to set state #{obj_name}:#{state_name} = #{state_val}"
    @state[obj_name] ||= {}
    @state[obj_name][state_name] = state_val
  end
  
  def get_state(obj_name, state_name)
    puts "trying to get state #{obj_name}:#{state_name}"
    @state[obj_name][state_name]
  end
  
  def load_game_objects()
    objs = {}
    objs_dir = "./data/game_objects"
    Dir.entries(objs_dir).each do |obj_name|
      if (file_valid?(obj_name))
        puts "loading game object for #{obj_name}"
        objs[obj_name] = GameObject.new(self, obj_name)
        objs[obj_name].init
        
        # at this point there's only one level of recurrsion so sub_sub_objects aren't possible
        # if that ends up being a need I'll generify this to take arbitrarily deep sub_object loading
        Dir.entries("#{objs_dir}/#{obj_name}").each do |sub_obj_name|
          if (sub_obj_name[0] == "_")
            puts "loading sub object #{sub_obj_name}"
            objs["#{obj_name}_#{sub_obj_name[1..-1]}"] = GameObject.new(self, "#{obj_name}_#{sub_obj_name[1..-1]}")
            objs["#{obj_name}_#{sub_obj_name[1..-1]}"].init
          end
        end
      end
    end
    objs
  end
  
  def file_valid?(s)
    s != "." && s != ".." && s != ".DS_Store"
  end
  
end

class Notification
  
  attr_accessor :obj_name, :message, :triggered, :params
  
  def initialize(obj_name, message, params=nil)
    @obj_name = obj_name
    @message = message
    @triggered = false
    @params = params
  end
  
  def trigger
    @triggered = true
  end
  
end