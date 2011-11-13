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
  
  class WidgetContext
    def initialize(root)
      @stack = [root]
    end
    
    def push(newwidget)
      @stack.push(newwidget)
    end
    
    def pop
      @stack.pop
    end
    
    def add_widget(w)
      @stack.last.add_widget(w)
    end
  end          

  class WindowWrapper
    def initialize(w)
      @w = w
    end

    def add_widget(w)
      @w.Content = w
    end
  end

  class PanelWrapper
    def initialize(p)
      @p = p
    end

    def add_widget(w)
      @p.Children.Add(w)
    end
  end

  class TextBoxWrapper
    def initialize(editbox)
      @box = editbox
    end
    public
    def text
      @box.Text
    end
    def text=(v)
      @box.Text = v
    end
  end

      
  class Instance
    def initialize(props)
      width = props[:width] if props and props.has_key? :width
      height = props[:height] if props and props.has_key? :height
      
      @win = System::Windows::Window.new
      @win.Width = width if width
      @win.Height = height if height
      @wcontext = WidgetContext.new(WindowWrapper.new(@win))
      wrappanel = System::Windows::Controls::WrapPanel.new
      @wcontext.add_widget(wrappanel)
      @wcontext.push(PanelWrapper.new(wrappanel))
    end
    public  
    def runloop
      System::Windows::Application.new.Run(@win)
    end

    def button(content, &clickhandler)
      but = System::Windows::Controls::Button.new
      but.Content = content
      @wcontext.add_widget(but)
      if clickhandler
        but.AddHandler(System::Windows::Controls::Primitives::ButtonBase::click_event, System::Windows::RoutedEventHandler.new { |o, e| clickhandler.call })
      end
    end
    def title(content)
      r = TitleWrapper.new(content)
      @wcontext.add_widget(r.label)
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

    def with_ctx(obj, wrapper, &block)
      @wcontext.push(wrapper)
      instance_eval(&block)
      @wcontext.pop
      @wcontext.add_widget(obj)
    end
    def with_panel(obj, &block)
      with_ctx(obj, PanelWrapper.new(obj), &block)
    end
    def stack(&block)
      panel = System::Windows::Controls::StackPanel.new
      with_panel(panel, &block)
    end
    def flow(&block)
      with_panel(System::Windows::Controls::WrapPanel.new, &block)
    end

    def image(uri)
      bimg = System::Windows::Media::Imaging::BitmapImage.new(System::Uri.new(uri))
      img = System::Windows::Controls::Image.new
      img.Source = bimg

      @wcontext.add_widget(img)
    end
    def edit_line
      box = System::Windows::Controls::TextBox.new
      @wcontext.add_widget(box)
      TextBoxWrapper.new(box)
    end
  end
def self.app(props = {}, &block)
  inst = Instance.new(props)
  inst.instance_eval(&block)
  inst.runloop
end
end

load ARGV[0]
