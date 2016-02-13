require_relative 'user'
require_relative 'ppgthread'

class PairProgrammingGitConsole

  attr_accessor :thread, :switch_timer, :navigator, :driver

  def initialize()
    intro_prompt
    @thread = PPGThread.new()

  end

  def intro_prompt
    @user1 = new_user("navigator")
    @user2 = new_user("driver")
    puts @user1
    puts @user2
    @switch_timer = switch_timer
    @navigator = navigator
    @driver = driver
  end

  def new_user(role)
      puts "What is the name of the #{role}?"
      name = gets
      puts "What is the email of the #{role}?"
      email = gets
      info = {name: name, email: email, role: role}
      confirm_user_info?(info) ? User.new(info) : new_user("navigator")
      puts
  end

  def confirm_user_info?(info)
    puts "\nName:  #{info[:name]}"
    puts "Email:  #{info[:email]}"
    puts "Role:  #{info[:role]}"
    puts "Is this correct? (y/n)"
    confirmation = gets

    confirmation == "\n" ? confirm_user_info?(info) : confirmation.chomp.downcase =~ /y+e?s?/
  end

end

PairProgrammingGitConsole.new
