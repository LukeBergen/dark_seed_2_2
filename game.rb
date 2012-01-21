require './game_object'
require './notification'

class Game
  
  def initialize(parent_win)
    @game_window = parent_win
    @game_objects = load_game_objects()
    @notifications = []
    @frames = 0
  end
  
  def tick
    @game_objects.each do |obj_name, obj|
      obj.tick
    end
    check_notifications
    @frames += 1
  end
  
  def load_state(state=nil)
    if (state)
      # TODO if state is passed in, load from a state file or something
    else
      @game_objects["mark"].show
      @game_objects["mark"].position = [300, 300]
      @game_objects["mark"].set_image("idle.png")
    end
  end
  
  def game_objects
    @game_objects
  end
  
  def left_click(x, y)
    # figure out action
    @game_objects.each do |obj_name, obj|
      next if (obj_name == "game")
      if (x >= obj.x && y >= obj.y && x <= (obj.x + obj.width) && y <= (obj.y + obj.height))
        obj.click(self, x,y)
      else
        do_player_move(x, y)
      end
    end
  end
  
  def do_player_move(x, y)
    @notifications.each do |noti|
      if (noti.obj_name == "mark" && noti.message = "move complete")
        @notifications.delete(noti)
      end
    end
    @game_objects["mark"].start_animation("move")
    noti = Notification.new(self, "mark", "move complete") do
      @game_objects["mark"].stop_animation
      @game_objects["mark"].set_image("idle.png")
    end
    @notifications << noti
    @game_objects["mark"].move(x, y, noti)
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
        noti.exec
        @notifications.delete(noti)
      end
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