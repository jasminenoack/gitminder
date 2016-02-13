class User

attr_accessor :name, :email, :role

  def initialize(options)
    @name = options[:name]
    @email = options[:email]
    @role = options[:role]
  end

end
