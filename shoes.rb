require 'WindowsBase'
require 'PresentationFramework'
require 'PresentationCore'

module Shoes
  class Instance
    def initialize(props)
      @width = props[:width] if props and props.has_key? :width
      @height = props[:height] if props and props.has_key? :height
      
      @win = System::Windows::Window.new
      @win.Width = @width
      @win.Height = @height
    end
    public  
    def runloop
      System::Windows::Application.new.Run(@win)
    end

    def button(content, &clickhandler)
      but = System::Windows::Controls::Button.new
      but.Content = content
      @win.Content = but
      if clickhandler
        but.AddHandler(System::Windows::Controls::Primitives::ButtonBase::click_event, System::Windows::RoutedEventHandler.new { |o, e| clickhandler.call })
      end
    end
    def alert(msg)
      System::Windows::MessageBox.Show(@win, msg, "Shoes says")
    end
  end
def self.app(props, &block)
  inst = Instance.new(props)
  inst.instance_eval(&block)
  inst.runloop
end
end

load ARGV[0]
