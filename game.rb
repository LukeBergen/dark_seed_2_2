require './game_object'
require './area'
require './inventory_item'

module ZOrder
  Background, Objects, Player, Foreground, ForegroundObjects, DialogBackground, DialogEntities, Menu1, Menu2, Menu3, Mouse, SuperTop = *1..12
end

class Game
  
  attr_accessor :current_menu
  attr_reader :state
  
  def initialize(parent_win)
    @game_window = parent_win
    @areas = load_areas()
    @state = nil
    load_state()
    @game_objects = load_game_objects()
    @current_dialog_hash = nil
    @current_menu = nil
    @notifications = []
    @inventory = []
    @frames = 0
  end
  
  def tick
    @game_objects.each do |obj_name, obj|
      obj.tick
    end
    check_notifications
    @frames += 1
  end
  
  def load_areas
    {"DevRoom" => Area.new(self, "DevRoom"), "HighSchoolGym" => Area.new(self, "HighSchoolGym"), "HighSchoolHallway" => Area.new(self, "HighSchoolHallway"), "Inventory" => Area.new(self, "Inventory")}
  end
  
  def current_area
    @areas[get_state("Game", "current_area")]
  end
  
  def current_area=(area_name)
    set_state("Game", "current_area", area_name)
  end
  
  def window
    @game_window
  end
  
  def load_state(state_name="default")
    # TODO if state is passed in, load from a state file or something
    state = YAML::load(File.read("./data/state/#{state_name}/state.yml"))
    @state = state["Game State"]
        # 
        # @state.each do |obj_name, variables|
        #   if (variables.keys.include?("current image"))
        #     @game_objects[obj_name].set_image(variables["current image"])
        #   end
        #   if (variables.keys.include?("current area"))
        #     if @areas.keys.include?(variables["current area"])
        #       @areas[variables["current area"]].game_objects << obj_name
        #     end
        #   end
        #   if (variables.keys.include?("x pos") && variables.keys.include?("y pos"))
        #     @game_objects[obj_name].position = [variables["x pos"], variables["y pos"]]
        #   end
        #   
        #   if (variables.keys.include?("z pos"))
        #     @game_objects[obj_name].z_pos = variables["z pos"]
        #   end
        # end
        
    puts "EVERYTHING LOADED."
  end
  
  def game_objects
    @game_objects
  end
  
  def mouse_x
    @game_window.mouse_x
  end
  
  def mouse_y
    @game_window.mouse_y
  end
  
  def left_mouse_down(mouse_x, mouse_y)
    # figure out action
    clicked_obj = mouse_over_objects(mouse_x, mouse_y, "mouse_down").first
    puts "mouse_down on object: #{clicked_obj.name}" if clicked_obj
    if (clicked_obj)
      clicked_obj.set_state("initial_x", (clicked_obj.x || 0.0))
      clicked_obj.set_state("initial_y", (clicked_obj.y || 0.0))
      clicked_obj.set_state("mouse_offset_x", mouse_x - (clicked_obj.x || 0.0))
      clicked_obj.set_state("mouse_offset_y", mouse_y - (clicked_obj.y || 0.0))
      set_state("drag_start_x", mouse_x)
      set_state("drag_start_y", mouse_y)
      clicked_obj.set_state("mouse_down_on", true)
      clicked_obj.set_state("dragging", true) if (clicked_obj.get_state("draggable"))
    elsif (get_state("can_move"))
      puts "you clicked an area.  Moving to that area"
      do_player_move(mouse_x, mouse_y)
    end
  end
  
  def left_mouse_up(mouse_x, mouse_y)
    puts "left mouse up at #{mouse_x}, #{mouse_y}"
    obj = @game_objects.values.select {|obj| obj.get_state("mouse_down_on")}.first
    if (obj)
      obj.set_state("dragging", false)
      obj.set_state("mouse_down_on", false)
      if (get_state("drag_start_x") == mouse_x && get_state("drag_start_y") == mouse_y)
        obj.on_click(mouse_x, mouse_y)
      else
        obj.on_drag_complete(mouse_x, mouse_y)
      end
    end
  end
  
  def mouse_over_objects(x, y, action="mouse_down")
    objects = []
    current_area.game_objects.each do |obj_name|
      next if (obj_name == "Game")
      obj = @game_objects[obj_name]
      if (x >= (obj.x || 0.0) && y >= (obj.y || 0.0) && x <= ((obj.x || 0.0) + obj.width) && y <= ((obj.y || 0.0) + obj.height))
        objects << obj
      end
    end
    objects.sort {|obj1, obj2| (obj1.send((action+"_priority").to_sym) || obj1.z || -1) <=> (obj2.send((action+"_priority").to_sym) || obj2.z || -1) }.reverse
  end
  
  def do_player_move(x, y, after_move=nil)
    @notifications.each do |noti|
      if (noti.obj_name == "Mark" && noti.message = "move complete")
        @notifications.delete(noti)
      end
    end
    @game_objects["Mark"].start_animation("move")
    noti = register_notification("Mark", "move complete", ["game_objects['Mark'].stop_animation", "game_objects['Mark'].set_image('idle.png')"] + (after_move || []))
    @game_objects["Mark"].move(x, y, noti)
  end
  
  def player
    game_objects["Mark"]
  end
  
  def do_dialog(dialog_hash_or_obj_name, dialog_name=nil)
    puts "doing dialog #{dialog_hash_or_obj_name}:#{dialog_name}"
    if (dialog_hash_or_obj_name && dialog_hash_or_obj_name.class == Hash)
      @current_dialog_hash = dialog_hash_or_obj_name
    else
      @current_dialog_hash = @game_objects[dialog_hash_or_obj_name].dialogs()[(dialog_name || get_state(dialog_hash_or_obj_name, "next_dialog"))]
    end
  end
  
  def show_inventory()
    # game_objects.values.each do |obj|
    #   obj.stop_animation
    # end
    @last_area = get_state("Game", "current_area")
    change_area("Inventory")
    set_state("can_move", false)
  end
  
  def leave_inventory()
    game_objects.values.each do |obj|
      obj.stop_animation
    end
    change_area(@last_area)
    set_state("can_move", true)
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
            #begin
              self.instance_eval(p)
            #rescue
            #  puts "ERROR: error occurred evaling #{p}"
            #end
          end
        end
        @notifications.delete(noti)
      end
    end
  end
  
  def save_game(save_name="save1")
    puts "saving game: #{save_name}"
    save_name = "default_" if save_name == "default"
    begin
      Dir::mkdir("./data/state/#{save_name}")
    rescue
    end
    state_yaml = YAML::dump(@state)
    save_file = "./data/state/#{save_name}/state.yml"
    File.open(save_file, 'w') {|f| f.write(state_yaml)}
  end
  
  def load_game(save_name="default")
    puts "loading game: #{save_name}"
    begin
      save_file = "./data/state/#{save_name}/state.yml"
      @state = YAML::load(File.open(save_file, 'r'))
    end
  end
  
  def move_object(obj_name, new_area, x=nil, y=nil)
    @areas[@game_objects[obj_name].get_state("current_area")].remove_object(obj_name)
    @areas[new_area].add_object(obj_name)
    game_objects[obj_name].set_state("current_area", new_area)
    if (x && y)
      game_objects[obj_name].x = x
      game_objects[obj_name].y = y
    end
  end
  
  def change_area(area_name)
    self.current_area = area_name
  end
  
  def enter_coordinates(from_area, to_area)
    @areas[to_area].enter_coordinates[from_area]
  end
  
  def set_state(obj_name_or_state_name, state_name_or_value, value=nil)
    if (value.nil?)
      @state["Game"] ||= {}
      @state["Game"][obj_name_or_state_name] = state_name_or_value
    else
      @state[obj_name_or_state_name] ||= {}
      @state[obj_name_or_state_name][state_name_or_value] = value      
    end
  end
  
  def get_state(obj_name_or_state_name, state_name=nil)
    if (state_name)
      @state[obj_name_or_state_name] ? @state[obj_name_or_state_name][state_name] : nil
    else
      @state["Game"][obj_name_or_state_name]
    end
  end
  
  def add_to_inventory(item_name)
    set_state("game", "inventory", (get_state("Game", "inventory") || []) + [item_name])
  end
  
  def remove_from_inventory(item_name)
    set_state("game", "inventory", (get_state("Game", "inventory") || []) - [item_name])
  end
  
  def load_game_objects()
    objs = {}
    objs_dir = "./data/game_objects"
    Dir.entries(objs_dir).each do |obj_name|
      if (file_valid?(obj_name))
        puts "loading game object for #{obj_name}"
        objs[obj_name] = GameObject.new(self, obj_name)
        objs[obj_name].init
        
        @areas[objs[obj_name].get_state("current_area")].add_object(obj_name) if objs[obj_name].get_state("current_area")
        
        # at this point there's only one level of recurrsion so sub_sub_objects aren't possible
        # if that ends up being a need I'll generify this to take arbitrarily deep sub_object loading
        
        # nevermind, we'll finish implimenting this later
        # Dir.entries("#{objs_dir}/#{obj_name}").each do |sub_obj_name|
        #   if (sub_obj_name[0] == "_")
        #     puts "loading sub object #{sub_obj_name}"
        #     objs["#{obj_name}_#{sub_obj_name[1..-1]}"] = GameObject.new(self, "#{obj_name}_#{sub_obj_name[1..-1]}")
        #     objs["#{obj_name}_#{sub_obj_name[1..-1]}"].init
        #   end
        # end
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