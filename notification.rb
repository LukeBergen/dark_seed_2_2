class Notification
  
  attr_accessor :context, :obj_name, :message, :proc, :triggered
  
  def initialize(context, obj_name, message, &block)
    @context = context
    @obj_name = obj_name
    @message = message
    @proc = block
    @triggered = false
  end
  
  def exec
    @context.instance_eval(&@proc)
  end
  
  def trigger
    @triggered = true
  end
  
end