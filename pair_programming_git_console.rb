require_relative 'user'
require_relative 'ppgthread'
require_relative 'intro'
require 'thwait'
require_relative 'ppgthread'
require 'io/console'

class PairProgrammingGitConsole

  include Intro

  attr_accessor :thread, :switch_timer, :navigator, :driver, :needs_nav_change

  def initialize()
    intro_prompt
    @threads = []
    @thread = PPGThread.new(@switch_timer, @user_1, @user_2, @threads, self)
    @thread.run
    ThreadsWait.all_waits(@threads)
  end
end

class String
    def is_i?
       !!(self =~ /\A[-+]?[0-9]+\z/)
    end
end

class InputError < ArgumentError; end
class DuplicateError < ArgumentError; end
class FormatError < ArgumentError; end
class NotIntegerError < ArgumentError; end
class OutofBoundsError < ArgumentError; end

PairProgrammingGitConsole.new
