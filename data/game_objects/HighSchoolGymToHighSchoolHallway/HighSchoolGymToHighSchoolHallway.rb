# the name of the module should exactly match the name of the objects folder

module HighSchoolGymToHighSchoolHallway
  
  def on_examine()
    game.move_to_area("Mark", "HighSchool")
    game.change_area("HighSchool")
  end
  
end