class User

attr_accessor :name, :email, :repo, :role, :identifier

  def initialize(options)
    @name = options[:name]
    @email = options[:email]
    @repo = options[:repo]
    @role = options[:role]
    @identifier = options[:identifier]
  end

  def switch_role
    role = (role == 'navigator' ? 'driver' : 'navigator')
  end

  def self.valid_repo?(repo)
    !!(repo =~ /https:\/\/github.com\/\w+\/\w+\.git/)
  end

  def self.valid_email(email)
    !!(email =~ /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/)
  end
  
end
