require 'fileutils'
require 'dotenv/load'
require_relative './fb_source/connect_database.rb'

# This class is responsible for getting views, procedures and triggers,
# creating directory and deleting contents.
class FbSource
  def initialize(*args)
    @db = ConnectDatabase.new({
      host: ENV['DATABASE_HOST'],
      port: ENV['DATABASE_PORT'],
      database: ENV['DATABASE_NAME'],
      username: ENV['DATABASE_USERNAME'],
      password: ENV['DATABASE_PASSWORD']
    })

    self.delete_content_dir("#{args[0][:output_path]}")

    self.create_dir("#{args[0][:output_path]}/procedures")
    self.create_dir("#{args[0][:output_path]}/triggers")
    self.create_dir("#{args[0][:output_path]}/views")
  end

  # SQL script for getting the procedures from the database
  def get_procedures
    @db.fetch("SELECT RDB$PROCEDURE_NAME, RDB$PROCEDURE_SOURCE  FROM RDB$PROCEDURES")
  end

  # SQL script for getting the triggers from the database
  def get_triggers
    @db.fetch("SELECT RDB$TRIGGER_NAME, RDB$TRIGGER_SOURCE FROM RDB$TRIGGERS WHERE RDB$SYSTEM_FLAG = 0")
  end

  # SQL script for getting the views from the database
  def get_views
    @db.fetch("SELECT RDB$RELATION_NAME, RDB$VIEW_SOURCE FROM RDB$RELATIONS WHERE RDB$VIEW_BLR IS NOT NULL AND (RDB$SYSTEM_FLAG IS NULL OR RDB$SYSTEM_FLAG = 0)")
  end

  # It creates the files in the target directory
  def write_source(path, name, source)
    out_file = File.new("#{path}/#{name.strip}.sql", "w")
    out_file.puts(source)
    out_file.close
  end

  # It creates a directory if it does not exist
  def create_dir(path)
    FileUtils.mkdir_p(path) unless File.exists?(path)
  end

  # It deletes all the content in the target directory
  def delete_content_dir(path)
    FileUtils.rm_rf(Dir.glob("#{path}/*"))
  end
end
