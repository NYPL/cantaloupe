class Secret
  # For deployment. 
  # def self.database_configuration
  #   {
  #     url: 'jdbc:mysql://10.224.247.101:3306/archive?useSSL=false',
  #     username: ENV['DB_UNAME'],
  #     password: ENV['DB_PASS']
  #   }
  # end
  
  # def self.api_configuration
  #   {
  #     api_url: 'http://api.repo.nypl.org',
  #     auth_token: ENV['AUTH_TOKEN']
  #   }
  # end
  
  # def self.storage_configuration
  #   {
  #     default_image_path: nil
  #   }
  # end

  # For local development. 
  
  # Change this to match whatever you choose to set up your database as.
  def self.database_configuration
    {
      url: 'jdbc:mysql://localhost:3306/filestore?useSSL=false',
      username: 'root',
      password: 'password'
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

  # For local development. 
  #
  # Change this to match whatever you choose to set up your database as.
  # def self.database_configuration
  #   {
  #     url: 'jdbc:mysql://localhost:3306/archive?useSSL=false',
  #     username: 'root',
  #     password: ''
  #   }
  # end
  #
  # def self.api_configuration
  #   {
  #     api_url: 'http://api.repo.nypl.org',
  #     auth_token: 'yourAPIAuthTokenHere'
  #   }
  # end
  #
  # def self.storage_configuration
  #   {
  #     default_image_path: '/some/awesome/developer/cantaloupe/images/nypl.jpg'
  #   }
  # end
end
