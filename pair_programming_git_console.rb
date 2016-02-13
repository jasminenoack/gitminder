class PairProgrammingGitConsole

  attr_accessor :thread, :switch_timer, :navigator, :driver

  def initialize()
    intro_prompt
    @thread = PPGThread.new()

  end

  def intro_prompt
    @switch_timer = switch_timer
    @navigator = navigator
    @driver = driver
  end

end
