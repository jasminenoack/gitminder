require_relative 'user'
require_relative 'ppgthread'
require_relative 'intro'

class PairProgrammingGitConsole

  include 'Intro'

  attr_accessor :thread, :switch_timer, :navigator, :driver

  def initialize()
    intro_prompt
    @thread = PPGThread.new()
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
