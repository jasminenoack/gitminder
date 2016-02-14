require 'io/console'
require 'byebug'

class PPGThread
    def initialize(switch_time, user_1, user_2, threads, pairing_manager)
        @switch_time = switch_time
        @user_1 = user_1
        @user_2 = user_2
        @threads = threads
        @pairing_manager = pairing_manager
        @strings = [""]
    end

    def header_string
        pwd = `pwd`.chomp
        @user = `whoami`.chomp
        @git_branch = `git rev-parse --abbrev-ref HEAD`.chomp
        return "|-#{@user}:~#{pwd}(#{@git_branch})-|$ "
    end

    def run
        puts ""
        puts "Enjoy GitMinder"
        puts ""
        print header_string
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
                        sleep @switch_time * 60
                        @pairing_manager.needs_nav_change = true
                        print "\r"
                        print "\nIt has been #{@switch_time} minutes.  Please change the navigator\n"
                        print "\r"
                        print header_string
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

    def handle_key_press
      c = read_char
      case c
      when " "
        @strings[-1] << " "
        print " "
      when "\t"
        # puts "TAB"
      when "\r"
        if @strings[-1].length > 0
            @strings << ""
        end
        if @strings.length > 100
            @strings = @strings.drop(@strings.length - 100)
        end
        puts ""
        print header_string
        return @strings[-2]
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

    def process(input)
        if input.strip.start_with?('ppg')
            if input.start_with?('ppg commit')
                string = "#{input.gsub('ppg', 'git')}"
                unless input.include?('-m')
                    print header_string
                    puts "Please enter a commit message:"
                    message = gets.chomp
                    string += " -m #{message}"
                end
                puts string
                output = `#{string}`
                puts output
            else
                puts "not a ppg string #{input}"
            end
        else
            output = `#{input}`
            if output.length > 0
                puts output
            end
        end
        print header_string
        rescue => boom
            puts boom
        print header_string
    end
end
