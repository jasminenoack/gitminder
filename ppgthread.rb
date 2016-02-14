require 'io/console'
require 'byebug'
require_relative 'keypress'

class PPGThread
  include KeyPress

    def initialize(switch_time, user_1, user_2, threads, pairing_manager)
        @switch_time = switch_time
        @user_1 = user_1
        @user_2 = user_2
        @threads = threads
        @pairing_manager = pairing_manager
        @strings = [""]
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
