# the name of the module should exactly match the name of the objects folder

module Combiner
  
  def acted_on_by(object)
    puts "object #{object.name} now waiting to be combined with something"
    object.set_state("awaiting_combination", true)
  end
  
  def on_click(mouse_x, mouse_y)
    # do combination
    object_names = @game.game_objects.values.select {|obj| obj.get_state("awaiting_combination")}.collect {|o| o.name}.sort
    combine_into = item_combinations[object_names]
    if (combine_into)
      puts "combining objects: #{object_names} into #{combine_into}"
      puts "some brilliant flash or something aaaaaaand..."
      object_names.each do |name|
        delete = @game.game_objects[name]
        delete.set_state("awaiting_combination", false)
        delete.move_to("Null")
        @game.game_objects[combine_into].x = delete.x
        @game.game_objects[combine_into].y = delete.y
      end
      @game.game_objects[combine_into].to_inventory
    end
  end
  
  # Here is where to define all the different combinations of items
  # the format is [alphabetical list of items that are combined] => "new item name"
  def item_combinations
    {
      ["BoxOfNails", "WoodPlank"] => "NailPlank",
      ["GasCan", "Lighter"] => "FlameThrower"
    }
  end
  
end