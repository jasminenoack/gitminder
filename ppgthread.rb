require_relative 'keypress'
require_relative 'custom_errors'
require_relative 'user'
require 'io/console'
require 'byebug'
require 'date'

class PPGThread
  include KeyPress

    def initialize(switch_time, navigator, driver, threads, pairing_manager)
        @switch_time = switch_time
        @navigator = driver
        @driver = navigator
        @pairing_manager = pairing_manager
        switch_roles #switch roles to run git config...
        @threads = threads
        @strings = [""]
        set_time
        @responding = false
        @last_commit = Time.now
    end

    def set_time(delta=nil)
        delta = delta || @switch_time
        @next_switch_time = Time.now + (delta * 60)
    end

    def run
        puts ""
        puts ""
        puts ""
        puts ""
        puts "Enjoy GitMinder"
        puts ""
        puts "EXTRA COMMANDS:"
        puts ""
        puts "ppg switch"
        puts "    switches the navigator, and user of record"
        puts "ppg set-time"
        puts "    gits off the timer change script"
        puts ""
        print header_string
        set_time
        @threads << Thread.new do
            loop do
                if @responding
                    next
                end
                if @next_switch_time < Time.now
                    if @strings[-1].length < 1
                        print "\r"
                        print " " * (header_string.length + @strings[-1].length)
                        print "\r"
                        puts ""
                        puts "It has been #{@switch_time} minutes.  Please change the navigator"
                        print header_string
                    else
                        puts ""
                        puts "\nIt has been #{@switch_time} minutes.  Please change the navigator"
                        print header_string
                        print @strings[-1]
                    end
                end
                string = handle_key_press
                if string
                    @responding = true
                    process(string)
                    @responding = false
                end
            end
        end
        @threads << Thread.new do
            loop do
                if @responding
                    next
                end
                print "\r"
                print " " * (header_string.length + @strings[-1].length) + " "
                print "\r"
                print header_string + @strings[-1]
                if (@next_switch_time - Time.now).floor == 0
                    print "\r"
                    puts ""
                    print "\nIt has been #{@switch_time} minutes.  Please change the navigator\n"
                    print "\r"
                    print header_string
                    print @strings[-1]
                end
                if Time.now - @last_commit > 5 * 60 && !@commit_alerted
                    @commit_alerted = true
                    print "\r"
                    puts ""
                    print "\nIt has been 5 minutes consider committing\n"
                    print "\r"
                    print header_string
                    print @strings[-1]
                    sleep 10
                end
                sleep 1
            end
        end
        @threads.each {|thread| thread.abort_on_exception = true}
    end

    def process(input)
        output = ""
        if input.strip.start_with?('ppg')
            if input.start_with?('ppg commit')
                string = "#{input.gsub('ppg', 'git')}"
                output = commit (string)
            elsif input == 'ppg set-time'
                reset_time
            elsif input == 'ppg switch'
                switch_roles
            else
                string = "#{input.gsub('ppg', 'git')}"
                puts(string)
                output = `#{string}`
            end
        else
            if input.start_with?('git commit')
                output = commit(input)
            else
                output = `#{input}`
            end
        end
        if output.length > 0
            puts output
        end
        print "\r"
        print header_string
        rescue => boom
            puts boom
            print header_string
    end

    def switch_roles
      @navigator, @driver = @driver, @navigator
      set_time
      `git config --local --replace-all user.name #{@navigator.name}`
      `git config --local --replace-all user.email #{@navigator.email}`
    end

    def reset_time
        puts "How long would you like this round to be?"
        num = gets.to_i
        set_time(num)
    end

    def modify_user(identifier, attr, value)
      if attr == 'email'
        raise FormatError, "Please enter a valid email address" if !(User.valid_email?(value))
      elsif attr == 'repo'
        raise FormatError, "Please enter a valid Github Repository address" if !(User.valid_repo?(value))
      end

      user = (@navigator.identifier == identifier ? @navigator : @driver)
      user.instance_variable_set("@#{attr}".to_sym, value)
    end

    def commit(string)
        unless string.include?('-m')
            puts "Please enter a commit message:"
            message = gets.chomp
            unless message.include?('"')
                message = "\"#{message}\""
            end
            string += " -m #{message}"
        end
        puts string
        output = `#{string}`
        @last_commit = Time.now
        @commit_alerted = false
        return output
    end
end
