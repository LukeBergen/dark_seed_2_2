module Mark
  def dialogs
    {
      "Finds Key" => {
        "text" => "hey it's a key... I wonder if it'll open something",
        "audio" => "audio file",
        "responses" => [
          {
            "text"    => "Continue",
            "audio"   => "audio file",
            "actions" => ["game_objects['Key'].to_inventory()"]
          }
        ]
      },
      "Finds Wood Plank" => {
        "text" => "Hey, a wood plank... I wonder what I could use it for",
        "audio" => "audio file",
        "responses" => [
          {
            "text" => "Continue",
            "audio" => "audio file",
            "actions" => ["game_objects['WoodPlank'].to_inventory()"]
          }
        ]
      }
    }
  end
end