require 'WindowsBase'
require 'PresentationFramework'

module Shoes
  class Instance
    def initialize(props)
      @width = props[:width]
      @height = props[:height]
      
      @win = System::Windows::Window.new
      @win.Width = @width
      @win.Height = @height
    end
    public  
    def runloop
      System::Windows::Application.new.Run(@win)
    end
  end
def self.app(props, &block)
  inst = Instance.new(props)
  inst.instance_eval(&block)
  inst.runloop
end
end

Shoes.app :width => 300, :height => 300 do
end

