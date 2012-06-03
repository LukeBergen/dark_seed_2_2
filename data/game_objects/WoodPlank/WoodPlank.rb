# the name of the module should exactly match the name of the objects folder

module WoodPlank
  
  include InventoryItem
  
  def on_examine()
    # what's the procedure to make mark say something on examining an object
    @game.do_dialog(@game.player.dialog("Finds Wood Plank"))
  end
  
end