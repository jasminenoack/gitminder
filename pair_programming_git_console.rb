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
      puts
      puts "What is the name of the #{role}?"
      name = gets.chomp
      email = email_prompt(role)
      info = {name: name, email: email, role: role}
      confirm_user_info?(info) ? User.new(info) : new_user(role)
  end

  def email_prompt(role)
      puts "What is the email of the #{role}?"
      email = gets.chomp
      raise SameEmailError, "**Driver and Navigator cannot have the same email!**" if @user1 && @user1.email == email
      raise EmailFormatError, "**Please enter a valid email address.**" unless email =~ /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
      email
    rescue StandardError => e
      puts e.message
      retry
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

class SameEmailError < ArgumentError; end
class EmailFormatError < ArgumentError; end

PairProgrammingGitConsole.new
