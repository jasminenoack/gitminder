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
    raise InputError, "**Please enter a name**" if name == ""

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

    if !(confirmation.downcase =~ /[yn]+[eo]?s?/)
      raise InputError, "Enter y or n"
    else
      return confirmation.downcase =~ /y+e?s?/
    end

    rescue InputError => e
        puts e.message
        retry
  end

  def switch_timer_prompt
    puts 'Switch every 15 minutes? (press enter or enter different number)'
    switch_timer = gets.chomp
    if switch_timer == ""
      if timer_confirm?()
        15
      else
        raise InputError
      end
    elsif switch_timer.is_i?
      switch_timer = switch_timer.to_i
      if switch_timer <= 120 && switch_timer >= 15
        if timer_confirm?(switch_timer)
          switch_timer
        else
           raise InputError
         end
      else
        raise OutofBoundsError, "Value must be between 15 and 120"
      end
    else
      raise NotIntegerError, "Enter a value between 15 and 120"
    end

    rescue InputError
      retry
    rescue OutofBoundsError => e
      puts e.message
      retry
    rescue NotIntegerError => e
      puts e.message
      retry
  end

  def timer_confirm?(timer = 15)
    puts "Switch every #{timer} minutes?"
    confirmation = gets.chomp

    confirmation == "" ? timer_cofirm?(timer) : confirmation.chomp.downcase =~ /y+e?s?/
  end

end

class String
    def is_i?
       !!(self =~ /\A[-+]?[0-9]+\z/)
    end
end

class InputError < ArgumentError; end
class SameEmailError < ArgumentError; end
class EmailFormatError < ArgumentError; end
class NotIntegerError < ArgumentError; end
class OutofBoundsError < ArgumentError; end

PairProgrammingGitConsole.new
