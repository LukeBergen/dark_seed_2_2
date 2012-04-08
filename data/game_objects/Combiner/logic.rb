# the name of the module should exactly match the name of the objects folder

module Combiner
  
  def acted_on_by(object)
    puts "object #{object.name} now waiting to be combined with something"
    object.set_state("awaiting_combination", true)
  end
  
  def on_click(mouse_x, mouse_y)
    # do combination
    objects = @game.game_objects.values.select {|obj| obj.get_state("awaiting_combination")}
    puts "combining objects: #{objects.collect {|o| o.name}}"
  end
  
end