class User

attr_accessor :name, :email, :repo, :role

  def initialize(options)
    @name = options[:name]
    @email = options[:email]
    @repo = options[:repo]
    @role = options[:role]
  end

  def switch_role
    role = (role == 'navigator' ? 'driver' : 'navigator')
  end

end
