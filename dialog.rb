class Dialog
  class Response
    attr_accessor :text, :audio_file, :after_response
    def initialize(opts = {})
      opts = {:text=>"", :audio_file=>"", :after_response=>Proc.new(){nil}}.merge(opts)
      @text = opts[:text]
      @audio_file = opts[:audio_file]
      @after_response = opts[:after_response]
    end
  end
  
  attr_accessor :name, :text, :audio_file, :responses
  
  def initialize(opts = {})
    opts = {:name=>"", :text=>"", :audio_file=>"", :responses=>[Response.new(:text=>"Continue")]}.merge(opts)
    @name = opts[:name]
    @text = opts[:text]
    @audio_file = opts[:audio_file]
    @responses = opts[:responses]
  end
  
end