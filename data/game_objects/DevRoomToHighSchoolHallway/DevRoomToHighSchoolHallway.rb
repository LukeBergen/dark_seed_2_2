# the name of the module should exactly match the name of the objects folder

module DevRoomToHighSchoolHallway
  
  def on_examine()
    game.move_to("HighSchoolHallway", 400, 650)
  end
  
end