class Secret
  # Change this to match whatever you choose to set up your database as.
  def self.database_configuration
    {
      url: ENV['DATABASE_URL'],
      username: ENV['DATABASE_USERNAME'],
      password: ENV['DATABASE_PASSWORD'],
    }
  end

  def self.api_configuration
    {
      api_url: ENV['API_URL'],
      auth_token: ENV['AUTH_TOKEN'],
    }
  end

  def self.storage_configuration
    {
      default_image_path: ENV['DEFAULT_IMAGE_PATH'],
    }
  end
end
