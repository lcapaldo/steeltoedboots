require 'WindowsBase'
require 'PresentationFramework'
require 'PresentationCore'

module Shoes
  class TitleWrapper
    attr_accessor :label
    def initialize(content)
      lbl = System::Windows::Controls::Label.new 
      lbl.Content = content
      self.label = lbl
    end
    public
    def replace(newcontent)
      self.label.Content = newcontent
    end
  end
      
  class Instance
    def initialize(props)
      width = props[:width] if props and props.has_key? :width
      height = props[:height] if props and props.has_key? :height
      
      @win = System::Windows::Window.new
      @win.Width = width if width
      @win.Height = height if height
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
    def title(content)
      r = TitleWrapper.new(content)
      @win.Content = r.label
      r
    end  
    def alert(msg)
      System::Windows::MessageBox.Show(@win, msg, "Shoes says")
    end
    def every(seconds, &block)
      timer = System::Windows::Threading::DispatcherTimer.new
      timer.tick { |s, e| block.call }
      timer.Interval = System::TimeSpan.new(0,0,seconds)
      timer.Start()
    end
  end
def self.app(props = {}, &block)
  inst = Instance.new(props)
  inst.instance_eval(&block)
  inst.runloop
end
end

load ARGV[0]
