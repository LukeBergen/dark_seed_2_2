# the name of the module should exactly match the name of the objects folder

module HighSchoolGymToHighSchoolHallway
  
  # THIS IS THE OFFSET FROM THIS OBJECT'S X,Y THAT THE PLAYER WILL MOVE TO WHEN EXAMINED
  def examine_from_xy
    [0, 0]
  end
  
  def on_examine()
    game.move_to_area("Mark", "HighSchool")
    game.change_area("HighSchool")
  end
  
end