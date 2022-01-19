class Secret
  def self.database_configuration
    {
      url: ENV['DB_URL'],
      username: ENV['DB_UNAME'],
      password: ENV['DB_PASS']
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