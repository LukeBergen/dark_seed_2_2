# the name of the module should exactly match the name of the objects folder

module CloseInventory
  
  def on_click()
    game.change_area(game.game_objects["Mark"].current_area)
  end
  
end