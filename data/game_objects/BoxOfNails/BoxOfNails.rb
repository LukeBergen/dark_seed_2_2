# the name of the module should exactly match the name of the objects folder

module BoxOfNails
  
  include InventoryItem
  
  def on_examine()
    # what's the procedure to make mark say something on examining an object
    #@game.do_dialog("Mark", "Finds Box Of Nails")
    @game.player.do_dialog("Finds Box Of Nails")
  end
  
end