require 'active_record'
require 'activerecord-jdbc-adapter' if defined? JRUBY_VERSION

# Connect to Database
ActiveRecord::Base.establish_connection(
  database: ENV['FILESTORE_DB_NAME'],
  username: ENV['FILESTORE_DB_USER'],
  password: ENV['FILESTORE_DB_PASSWORD'],
  host: ENV['FILESTORE_DB_HOST']
)

class FileStore < ActiveRecord::Base
  self.table_name = 'file_store'
  def read_only?
    true
  end
end
