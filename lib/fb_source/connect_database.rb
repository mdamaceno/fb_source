require 'fb'

# This class is responsible for creating a connection with the database.
# Its arguments come from variables defined in .env file.
class ConnectDatabase
  include Fb

  def initialize(*args)
    @database = "#{args[0][:host]}/#{args[0][:port]}:#{args[0][:database]}"
    @username = args[0][:username]
    @password = args[0][:password]
  end

  def fetch(sql)
    get_connection.query(:hash, sql)
  end

  private

  def database
    Database.new(
      database: @database,
      username: @username,
      password: @password
    )
  end

  def get_connection
    database.connect
  end
end
