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
      @strings[@strings_index] << " "
      print " "
    when "\t"
      # puts "T
    when "\r"
      command = @strings[@strings_index]
      if @strings[@strings_index].length > 0 && @strings_index == -1
          @strings << ""
      end
      if @strings.length > 100
          @strings = @strings.drop(@strings.length - 100) # .shift?
      end
      puts ""
      @strings_index = -1
      return command
    when "\n"
      # puts "LINE FEED"
    when "\e"
      # puts "ESCAPE"
    when "\e[A"
      return if @strings_index <= -(@strings.length)
      print "\r"
      print " " * (header_string.length + @strings[@strings_index].length) + " "
      print "\r"
      print header_string
      @strings_index -= 1
      print @strings[@strings_index]
    when "\e[B"
      return if @strings_index == -1
      print "\r"
      print " " * (header_string.length + @strings[@strings_index].length) + " "
      print "\r"
      print header_string
      @strings_index += 1
      print @strings[@strings_index]
    when "\e[C"
      # puts "RIGHT ARROW"
    when "\e[D"
      # puts "LEFT ARROW"
    when "\177"
      print "\r"
      print " " * (header_string.length + @strings[@strings_index].length)
      print "\r"
      print header_string
      @strings[@strings_index] = @strings[@strings_index][0..-2]
      @strings[-1] = ""
      print @strings[@strings_index]
    when "\004"
      # puts "DELETE"
    when "\e[3~"
      # puts "ALTERNATE DELETE"
    when "\u0003"
      exit 0
    when /^.$/
      @strings[@strings_index] << c
      print c
    end
  end

  def input_prompt
    length = @strings.length
    until @strings.length == length + 1
      handle_key_press
    end
    @strings[@strings_index - 1]
  end
end
