# the name of the module should exactly match the name of the objects folder

module DevRoomToHighSchoolHallway
  
  # THIS IS THE OFFSET FROM THIS OBJECT'S X,Y THAT THE PLAYER WILL MOVE TO WHEN EXAMINED
  def examine_from_xy
    [0, 0]
  end
  
  def on_examine()
    game.move_object("Mark", warp_to_area, warp_to_x, warp_to_y)
    game.change_area(warp_to_area)
  end
  
end