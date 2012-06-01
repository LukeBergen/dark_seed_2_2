# the name of the module should exactly match the name of the objects folder

require './dialog'

module FarmerJim
  
  def examine_from_xy
    puts "overriding examine_from_xy for farmer jim"
    [self.width + 20, 20]
  end
  
  def can_you_see_me
    puts "yep"
  end
    
  def build_dialogs
    dialogs = [
      Dialog.new(
        :name => "monolog one",
        :text => "Line 1{NEWLINE}Line 2{NEWLINE}Line 3{NEWLINE}Line 4",
        :responses => [
          Dialog::Response.new(
            :text => "Investigating my brothers death",
            :after_response => Proc.new() do |game|
              self.do_dialog("why investigating")
            end
          )
        ]
      ),
      Dialog.new(
        :name => "first dialog",
        :text => "Hello main charactor. What are you doing?",
        :responses => [
          Dialog::Response.new(
            :text => "Investigating my brothers death",
            :after_response => Proc.new() do |game|
              self.do_dialog("why investigating")
            end
          ),
          Dialog::Response.new(
            :text => "Just visiting the ol' town",
            :after_response => Proc.new() do |game|
              self.do_dialog("thats nice")
            end
          )
        ]
      ),
      Dialog.new(
        :name => "why investigating",
        :text => "There's nothing here to investigate! Go away now!",
        :audio_file => nil,
        :responses => [
          Dialog::Response.new(
            :after_response => Proc.new() do |game|
              self.do_dialog("I told you")
            end
          )
        ]
      ),
      Dialog.new(
        :name => "thats nice",
        :text => "Well that's nice. Maybe we'll see each other around again soon.{NEWLINE}I have to go now.  Bye",
        :audio_file => nil,
        :responses => [
          Dialog::Response.new(
            :after_response => Proc.new() do |game|
              self.set_state("next_dialog", "have to go")
            end
          )
        ]
      ),
      Dialog.new(
        :name => "have to go",
        :text => "Like I said, I have to be going.  Bye now",
        :audio_file => nil
      ),
      Dialog.new(
        :name => "I told you",
        :text => "I told you there's nothing to investigate, now go away",
        :audio_file => nil
      )
    ]
    return dialogs
  end
  
  def on_examine()
    # based on what the state is, (and even using the game's state for global variables and such)
    # do whatever needs to be done on this object being examined.
    #game.do_dialog(dialogs()[get_state("next_dialog")])
    game.do_dialog(@dialogs.find {|d| d.name == self.get_state("next_dialog") } )
  end
  
end