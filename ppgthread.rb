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
    end

    def set_time(delta=nil)
        delta = delta || @switch_time
        @next_switch_time = Time.new + (delta * 60)
    end

    def run
        puts ""
        puts "Enjoy GitMinder"
        puts ""
        print header_string
        set_time
        @threads << Thread.new do
            @threads << Thread.new do
                loop do
                    if @next_switch_time < Time.now
                        if @strings[-1].length < 1
                            print "\r"
                            print " " * (header_string.length + @strings[-1].length)
                            print "\r"
                            puts "It has been #{@switch_time} minutes.  Please change the navigator"
                            print header_string
                        else
                            puts "\nIt has been #{@switch_time} minutes.  Please change the navigator"
                            print header_string
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
                    if @next_switch_time < Time.now
                        sleep @switch_time * 60
                        print "\r"
                        print "\nIt has been #{@switch_time} minutes.  Please change the navigator\n"
                        print "\r"
                        print header_string
                        print @strings[-1]
                        sleep 10
                    end
                end
            end
        end
        @threads.each {|thread| thread.abort_on_exception = true}
    end

    def process(input)
        if input.strip.start_with?('ppg')
            if input.start_with?('ppg commit')
                string = "#{input.gsub('ppg', 'git')}"
                output = commit (string)
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
      `git config user.name #{@navigator.name}`
      `git config user.email #{@navigator.email}`
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
                @getting_response = true
                message = gets.chomp
                unless message.include?('"')
                    message = "\"#{message}\""
                end
                @getting_response = false
                string += " -m #{message}"
            end
            puts string
            output = `#{string}`
            return output
    end
end
