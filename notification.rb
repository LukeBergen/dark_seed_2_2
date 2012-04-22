class Notification
  
  def initialize(name, condition_proc, execute)
    @name = name
    if (condition_proc.is_a?(String))
      @condition_proc = Proc.new {|game| game.eval(condition_proc || "")}
    else
      @condition_proc = condition_proc
    end
    
    if (execute.is_a?(String))
      @execute_proc = Proc.new {|game| game.eval(condition_proc || "")}
    else
      @execute_proc = execute
    end
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
    @execute_proc.call(game)
  end
end