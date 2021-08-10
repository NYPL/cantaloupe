class Secret

  def self.database_configuration
    {
      url: 'jdbc:mysql://10.224.247.101:3306/archive?useSSL=false',
      username: ENV['DB_UNAME'],
      password: ENV['DB_PASS']
    }
  end

end
