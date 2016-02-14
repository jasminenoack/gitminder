require 'date'
require 'byebug'

module KeyPress

  def header_string
      pwd = `pwd`.chomp
      @git_branch = `git rev-parse --abbrev-ref HEAD`.chomp
      if @paused
        next_switch_time = "paused:#{@paused.floor}"
      else
        next_switch_time = "#{(@next_switch_time - Time.now).floor}"
      end
      return "|-#{@navigator.name}:~#{pwd}(#{@git_branch}) #{next_switch_time} -|$ "
  end

  def read_char
    STDIN.echo = false
    STDIN.raw!

    input = STDIN.getc.chr
    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end
  ensure
    STDIN.echo = true
    STDIN.cooked!

    return input
  end

  def handle_key_press
    c = read_char
    if @responding
      return
    end
    case c
    when " "
      @strings[-1] << " "
      print " "
    when "\t"
      # puts "T
    when "\r"
      command = @strings[-1]
      if @strings[-1].length > 0
          @strings << ""
      end
      if @strings.length > 100
          @strings = @strings.drop(@strings.length - 100)
      end
      puts ""
      return command
    when "\n"
      # puts "LINE FEED"
    when "\e"
      # puts "ESCAPE"
    when "\e[A"
      # puts "UP ARROW"
    when "\e[B"
      # puts "DOWN ARROW"
    when "\e[C"
      # puts "RIGHT ARROW"
    when "\e[D"
      # puts "LEFT ARROW"
    when "\177"
      print "\r"
      print " " * (header_string.length + @strings[-1].length)
      print "\r"
      print header_string
      @strings[-1] = @strings[-1][0..-2]
      print @strings[-1]
    when "\004"
      # puts "DELETE"
    when "\e[3~"
      # puts "ALTERNATE DELETE"
    when "\u0003"
      exit 0
    when /^.$/
      @strings[-1] << c
      print c
    end
  end

  def input_prompt
    length = @strings.length
    until @strings.length == length + 1
      handle_key_press
    end
  end
end
