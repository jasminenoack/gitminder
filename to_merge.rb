require_relative 'user'
require_relative 'custom_errors'

def modify_user(identifier, attr, value)
  if attr == 'email'
    raise FormatError, "Please enter a valid email address" if !(User.valid_email?(value))
  elsif attr == 'repo'
    raise FormatError, "Please enter a valid Github Repository address" if !(User.valid_repo?(value))
  end

  user = (identifier == 1 ? @user_1 : @user_2)
  user.instance_variable_set("@#{attr}".to_sym, value)
end
