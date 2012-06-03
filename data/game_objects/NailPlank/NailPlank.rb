# the name of the module should exactly match the name of the objects folder

module NailPlank
  
  include InventoryItem
  
  def on_examine()
    # what's the procedure to make mark say something on examining an object
    @game.do_dialog("Mark", "Finds Wood Plank")
  end
  
end