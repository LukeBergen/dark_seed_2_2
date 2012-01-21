class Notification
  
  attr_accessor :obj_name, :message, :proc, :triggered
  
  def initialize(parent_obj, obj_name, message, &block)
    @parent = parent_obj
    @obj_name = obj_name
    @message = message
    @proc = block
    @triggered = false
  end
  
  def exec
    @parent.instance_eval(&@proc)
  end
  
  def trigger
    @triggered = true
  end
  
end