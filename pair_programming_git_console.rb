require_relative 'user'
require_relative 'ppgthread'
require_relative 'intro'
require_relative 'custom_errors'
require_relative 'ppgthread'
require_relative 'keypress'
require 'thwait'
require 'stringio'
require 'io/console'
require 'byebug'

class PairProgrammingGitConsole

  include Intro
  include KeyPress

  attr_accessor :thread, :switch_timer, :navigator, :driver, :needs_nav_change

  def initialize()
    git_init
    intro_prompt
    create_remotes
    @threads = []
    @switch_timer = 1
    @user_1 = User.new({name: 'name', email: 'email', repo: 'https://github.com/Coroecram/test.git', role: 'navigator', identifier: 1})
    @user_2 = User.new({name: 'name', email: 'email', repo: 'https://github.com/Coroecram/test.git', role: 'driver', identifier: 2})
    @thread = PPGThread.new(@switch_timer, @navigator, @driver, @threads, self)
    @thread.run
    ThreadsWait.all_waits(@threads)
  end

  def git_init
    `git init` if !(File.directory?('.git'))
  end

  def create_remotes
    `git remote add first_partner #{@user_1.repo}`
    `git remote add second_partner #{@user_2.repo}`
  end
end

class String
    def is_i?
       !!(self =~ /\A[-+]?[0-9]+\z/)
    end
end

PairProgrammingGitConsole.new
