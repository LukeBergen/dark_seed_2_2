class Animation
  def initialize()
    @counter = 0
    @current = 0
    @images = []
  end
  
  def <<(v)
    @images << v
  end
  
  def reset
    @counter = @current = 0
  end
  
  def tick
    r = @images[@counter]
    @counter = (@counter + 1) % @images.count
    return r
  end
end