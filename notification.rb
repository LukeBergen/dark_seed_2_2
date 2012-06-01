class Notification
  
  attr_accessor :name
  
  def initialize(name, condition_proc, execute)
    @name = name
    if (condition_proc.is_a?(String))
      @condition_proc = Proc.new {|game| game.eval(condition_proc || "")}
    else
      @condition_proc = condition_proc
    end
    @execute_proc = execute
  end
  
  def triggered?(game)
    begin
      @condition_proc.call(game)
    rescue
      false
    end
  end
  
  def exec(game)
    puts "executing exec_proc.  @exec_proc: #{@execute_proc}"
    if (@execute_proc.is_a?(Array))
      @execute_proc.each do |proc|
        proc.call(game)
      end
    else
      @execute_proc.call(game)
    end
  end
end