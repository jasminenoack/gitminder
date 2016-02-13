class PairProgrammingGitConsole

  attr_accessor :switch_timer, :navigator, :driver

  def initialize()
    intro_prompt

  end

  def intro_prompt
    @switch_timer = switch_timer
    @navigator = navigator
    @driver = driver
  end
