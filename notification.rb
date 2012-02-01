class Notification
  
  attr_accessor :obj_name, :message, :triggered, :params
  
  def initialize(obj_name, message, params=nil)
    @obj_name = obj_name
    @message = message
    @triggered = false
    @params = params
  end
  
  def trigger
    @triggered = true
  end
  
end