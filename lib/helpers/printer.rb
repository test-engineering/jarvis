require 'colorize'

class Printer

  def initialize
    @printed = 0
  end

  @@instance = Printer.new

  def self.instance
    @@instance
  end

  def carriage_return;  "\r"    end
  def line_up;          "\e[A"  end
  def clear_line;       "\e[0K" end

  def clear
    # jump back to the first position and clear the line
    print carriage_return + (line_up + clear_line) * @printed + clear_line
    start_new
    Printer.instance
  end

  def draw(msg, color = nil)
    puts msg.colorize(color)
    increment_printed 1
    Printer.instance
  end

  def start_new
    @printed = 0
    Printer.instance
  end

  def increment_printed(lines)
    @printed += lines
    Printer.instance
  end

  private_class_method :new

end
