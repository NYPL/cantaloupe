class Secret

  def self.database_configuration
    {
      url: ENV['DB_URL'],
      username: ENV['DB_UNAME'],
      password: ENV['DB_PASS']
    }
  end

end
