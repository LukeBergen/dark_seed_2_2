module Mark
  
  def build_dialogs
    dialogs = [
      Dialog.new(
        :name => "Finds Key",
        :text => "hey it's a key... I wonder if it'll open something",
        :responses => [
          Dialog::Response.new(
            :after_response => Proc.new() do |game|
              game.game_objects["Key"].to_inventory()
            end
          )
        ]
      ),
      Dialog.new(
        :name => "Finds Key",
        :text => "Hey, a wood plank... I wonder what I could use it for",
        :responses => [
          Dialog::Response.new(
            :after_response => Proc.new() do |game|
              game.game_objects["WoodPlank"].to_inventory()
            end
          )
        ]
      ),
      Dialog.new(
        :name => "Finds Wood Plank",
        :text => "Hey, a wood plank... I wonder what I could use it for",
        :responses => [
          Dialog::Response.new(
            :after_response => Proc.new() do |game|
              game.game_objects["WoodPlank"].to_inventory()
            end
          )
        ]
      ),
      Dialog.new(
        :name => "Finds Box Of Nails",
        :text => "Hey, a box of nails.  Maybe I'll take them{NEWLINE}You never know when you'll need some nails.",
        :responses => [
          Dialog::Response.new(
            :after_response => Proc.new() do |game|
              game.game_objects["BoxOfNails"].to_inventory()
            end
          )
        ]
      )
    ]
    
    return dialogs
  end
  
  def dialogs_old
    {
      "Finds Key" => {
        "text" => "hey it's a key... I wonder if it'll open something",
        "audio" => "audio file",
        "responses" => [
          {
            "text"    => "Continue",
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
            "actions" => ["game_objects['WoodPlank'].to_inventory()"]
          }
        ]
      },
      "Finds Box Of Nails" => {
        "text" => "Hey, a box of nails.  Maybe I'll take them{NEWLINE}You never know when you'll need some nails.",
        "audio" => "audio file",
        "responses" => [
          {
            "text" => "Continue",
            "actions" => ["game_objects['BoxOfNails'].to_inventory()"]
          }
        ]
      }
    }
  end
end