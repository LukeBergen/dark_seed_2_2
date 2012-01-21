require './game_object'

class Game
  
  def initialize(parent_win)
    @game_window = parent_win
    @game_objects = load_game_objects()
  end
  
  def tick
    @game_objects.each do |obj_name, obj|
      obj.tick
    end
  end
  
  def load_state(state=nil)
    if (state)
      # TODO if state is passed in, load from a state file or something
    else
      @game_objects["mark"].show
      @game_objects["mark"].position = [300, 300]
    end
  end
  
  def game_objects
    @game_objects
  end
  
  def left_click(x, y)
    @game_objects["mark"].start_animation("test")
    @game_objects["mark"].move(x, y) do
      stop_animation
      set_image("idle.png")
    end
  end
  
  def load_game_objects()
    objs = {}
    objs_dir = "./media/game_objects"
    Dir.entries(objs_dir).each do |obj_name|
      if (obj_name != "." && obj_name != ".." && obj_name != ".DS_Store")
        puts "loading game object for #{obj_name}"
        objs[obj_name] = GameObject.new(@game_window, obj_name)
      end
    end
    objs
  end
  
  def file_valid?(s)
    s != "." && s != ".." && s != ".DS_Store"
  end
  
end