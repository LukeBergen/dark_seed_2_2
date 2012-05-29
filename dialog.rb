class Dialog
  class Response
    attr_accessor :text, :audio_file, :after_response
    def initialize(opts = {})
      opts.reverse_merge!(:text=>"", :audio_file=>"", :after_response=>Proc.new(){nil})
      @text = t
      @audio_file = a
      @after_response = ar
    end
  end
  
  attr_accessor :name, :text, :audio_file, :responses
  
  def initialize(opts = {})
    opts.reverse_merge!(:name=>"", :text=>"", :audio_file=>"", :responses=>[Response.new(:text=>"Continue")])
    @name = opts[:name]
    @text = opts[:text]
    @audio_file = opts[:audio_file]
    @responses = opts[:responses]
  end
  
end