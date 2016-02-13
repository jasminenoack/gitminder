class PairProgrammingGitConsole

  attr_accessor :thread, :switch_timer, :navigator, :driver

  def initialize()
    intro_prompt
    @thread = PPGThread.new()

  end

  def intro_prompt
    user1 = new_user("navigator")
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
  end

  def confirm_user_info?(info)
    puts "\nName:  #{info[:name]}"
    puts "Email:  #{info[:email]}"
    puts "Role:  #{info[:role]}"
    puts "Is this correct?"
    return gets.chomp.downcase =~ /y+e?s?/
  end

end

PairProgrammingGitConsole.new
