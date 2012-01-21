class Animation
  
  attr_accessor :speed
  
  def initialize()
    @counter = 0
    @current = 0
    @frames_skipped = 0
    @images = []
  end
  
  def <<(v)
    @images << v
  end
  
  def reset
    @counter = @current = @frames_skipped = 0
  end
  
  def tick
    r = @images[@counter]
    @frames_skipped += 1
    if (@frames_skipped == @speed)
      @counter = (@counter + 1) % @images.count
      @frames_skipped = 0
    end
    return r
  end
end