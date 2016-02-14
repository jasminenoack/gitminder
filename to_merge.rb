require_relative 'user'
require_relative 'custom_errors'

def modify_user(identifier, attr, value)
  if attr == 'email'
    raise FormatError, "Please enter a valid email address" if !(User.valid_email?(value))
  elsif attr == 'repo'
    raise FormatError, "Please enter a valid Github Repository address" if !(User.valid_repo?(value))
  end

  user = (@navigator.identifier == identifier ? @navigator : @driver)
  user.instance_variable_set("@#{attr}".to_sym, value)
end


def switch_roles
  @navigator, @driver = @driver, @navigator

  `git config user.name #{@navigator.name}`
  `git config user.email #{@navigator.email}`
end
