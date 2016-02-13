require_relative 'user'
require_relative 'ppgthread'
require_relative 'intro'
require 'thwait'
require_relative 'ppgthread'
require 'io/console'
require 'byebug'

class PairProgrammingGitConsole

  include Intro

  attr_accessor :thread, :switch_timer, :navigator, :driver, :needs_nav_change

  def initialize()
    git_init
    intro_prompt
    @threads = []
    @switch_timer = 1
    @user_1 = User.new({name: 'name', email: 'email', repo: 'https://github.com/Coroecram/gitminder.git', role: 'navigator'})
    @user_2 = User.new({name: 'name', email: 'email', repo: 'https://github.com/Coroecram/gitminder.git', role: 'driver'})
    @thread = PPGThread.new(@switch_timer, @user_1, @user_2, @threads, self)
    @thread.run
    ThreadsWait.all_waits(@threads)
  end

  def git_init
    `git init` if !(File.directory?('.git'))
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
