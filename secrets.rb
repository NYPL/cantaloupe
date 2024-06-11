class Secret
  def self.database_configuration
    {
      url: ENV['DB_URL'] ||= 'jdbc:mysql://10.224.247.103:3306/archive?useSSL=false',
      username: ENV['DB_UNAME'],
      password: ENV['DB_PASS']
    }
  end

  def self.memcached_configuration
    {
      url: ENV['MEMCACHED_URL']
    }
  end

  def self.api_configuration
    {
      api_url: ENV['API_URL'],
      auth_token: ENV['AUTH_TOKEN']
    }
  end

  def self.storage_configuration
    {
      default_image_path: ENV['DEFAULT_IMAGE_PATH']
    }
  end
end