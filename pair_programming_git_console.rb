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
    @switch_timer = switch_timer_prompt
    @navigator, @driver = @user1, @user2
  end

  def new_user(role)
      name = name_prompt(role)
      email = email_prompt(role)
      info = {name: name, email: email, role: role}

      confirm_user_info?(info) ? User.new(info) : new_user(role)
  end

  def name_prompt(role)
    puts "\nWhat is the #{role}'s name?"
    name = gets.chomp
    raise NoInputError, "**Please enter a name**" if name == ""
    name
    rescue ArgumentError => e
      puts e.message
      retry
  end

  def email_prompt(role)
      puts "What is the #{role}'s email?"
      email = gets.chomp
      raise SameEmailError, "**Driver and Navigator cannot have the same email!**" if @user1 && @user1.email == email
      raise EmailFormatError, "**Please enter a valid email address**" unless email =~ /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/

      email
    rescue ArgumentError => e
      puts e.message
      retry
  end

  def confirm_user_info?(info)
    puts "\nName:  #{info[:name]}"
    puts "Email:  #{info[:email]}"
    puts "Role:  #{info[:role]}"
    puts "Is this correct? (y/n)"
    confirmation = gets.chomp

    confirmation == "" ? confirm_user_info?(info) : confirmation.chomp.downcase =~ /y+e?s?/
  end

  def switch_timer_prompt
    puts 'Switch every 15 minutes? (press enter or enter different number)'
    switch_timer = gets.chomp
    timer_confirm(switch_timer) if switch_timer == "\n" || switch_timer

  end

end

class NoInputError < ArgumentError; end
class SameEmailError < ArgumentError; end
class EmailFormatError < ArgumentError; end

PairProgrammingGitConsole.new
