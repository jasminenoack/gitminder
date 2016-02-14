require 'io/console'

class PPGThread
    def initialize(switch_time, user_1, user_2, threads, pairing_manager)
        @switch_time = switch_time
        @user_1 = user_1
        @user_2 = user_2
        @threads = threads
        @pairing_manager = pairing_manager
        @strings = [""]
    end

    def run
        @threads << Thread.new do
            @threads << Thread.new do
                loop do
                    if @pairing_manager.needs_nav_change
                        if @strings[-1].length < 1
                            puts "It has been #{@switch_time/60} minutes.  Please change the navigator"
                        else
                            puts "\nIt has been #{@switch_time/60} minutes.  Please change the navigator"
                            print @strings[-1]
                        end
                    end
                    string = handle_key_press
                    if string
                       process(string)
                    end
                end
            end
            @threads << Thread.new do
                loop do
                    if !@pairing_manager.needs_nav_change
                        sleep @switch_time
                        @pairing_manager.needs_nav_change = true
                        print "\r"
                        print "\nIt has been #{@switch_time/60} minutes.  Please change the navigator\n"
                        print "\r"
                        print @strings[-1]
                    end
                end
            end
            @threads.each {|thread| thread.abort_on_exception = true}
        end
        @threads.each {|thread| thread.abort_on_exception = true}
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

    def modify_user(identifier, attr, value)
      user = (identifier == 1 ? @user_1 : @user_2)
      user.instance_variable_set("@#{attr}".to_sym, value)
    end

    def handle_key_press
      c = read_char
      case c
      when " "
        @strings[-1] << " "
        print " "
      when "\t"
        puts "TAB"
      when "\r"
        if @strings[-1].length > 0
            @strings << ""
        end
        if @strings.length > 100
            @strings = @strings.drop(@strings.length - 100)
        end
        puts ""
        return @strings[-2]
      when "\n"
        puts "LINE FEED"
      when "\e"
        puts "ESCAPE"
      when "\e[A"
        puts "UP ARROW"
      when "\e[B"
        puts "DOWN ARROW"
      when "\e[C"
        puts "RIGHT ARROW"
      when "\e[D"
        puts "LEFT ARROW"
      when "\177"
        puts "BACKSPACE"
      when "\004"
        puts "DELETE"
      when "\e[3~"
        puts "ALTERNATE DELETE"
      when "\u0003"
        exit 0
      when /^.$/
        @strings[-1] << c
        print c
      end
    end

    def process(input)
        puts "General input #{input}"
    end
end
