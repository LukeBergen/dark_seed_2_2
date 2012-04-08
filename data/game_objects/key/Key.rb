# the name of the module should exactly match the name of the objects folder

module Key
  
  include InventoryItem
  
  # THIS IS THE OFFSET FROM THIS OBJECT'S X,Y THAT THE PLAYER WILL MOVE TO WHEN EXAMINED
  def examine_from_xy
    [0, 0]
  end
  
  def on_examine()
    # what's the procedure to make mark say something on examining an object
    @game.do_dialog("Mark", "Finds Key")
  end
  
end