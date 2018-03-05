require 'fileutils'
require 'dotenv/load'
require_relative './fb_source/connect_database.rb'

# This class is responsible for getting views, procedures and triggers,
# creating directory and deleting contents.
class FbSource
  def initialize(*args)
    @output_path = args[0][:output_path]
  end

  def run
    delete_content_dir(@output_path)

    %w(procedures triggers views).each do |d|
      create_dir("#{@output_path}/#{d}")
      send("write_#{d}")
    end
  end

  private

  def connect_db
    ConnectDatabase.new({
      host: ENV['DATABASE_HOST'],
      port: ENV['DATABASE_PORT'],
      database: ENV['DATABASE_NAME'],
      username: ENV['DATABASE_USERNAME'],
      password: ENV['DATABASE_PASSWORD']
    })
  end

  # SQL script for getting the procedures from the database
  def get_procedures
    connect_db.fetch("SELECT RDB$PROCEDURE_NAME, RDB$PROCEDURE_SOURCE  FROM RDB$PROCEDURES")
  end

  # SQL script for getting the triggers from the database
  def get_triggers
    connect_db.fetch("SELECT RDB$TRIGGER_NAME, RDB$TRIGGER_SOURCE FROM RDB$TRIGGERS WHERE RDB$SYSTEM_FLAG = 0")
  end

  # SQL script for getting the views from the database
  def get_views
    connect_db.fetch("SELECT RDB$RELATION_NAME, RDB$VIEW_SOURCE FROM RDB$RELATIONS WHERE RDB$VIEW_BLR IS NOT NULL AND (RDB$SYSTEM_FLAG IS NULL OR RDB$SYSTEM_FLAG = 0)")
  end

  # Write procedures
  def write_procedures
    get_procedures.each do |row|
      write_source("#{@output_path}/procedures", row['RDB$PROCEDURE_NAME'], row['RDB$PROCEDURE_SOURCE'])
    end
  end

  # Write triggers
  def write_triggers
    get_triggers.each do |row|
      write_source("#{@output_path}/triggers", row['RDB$TRIGGER_NAME'], row['RDB$TRIGGER_SOURCE'])
    end
  end

  # Write views
  def write_views
    get_views.each do |row|
      write_source("#{@output_path}/views", row['RDB$RELATION_NAME'], row['RDB$VIEW_SOURCE'])
    end
  end

  # It creates the files in the target directory
  def write_source(path, name, source)
    out_file = File.new("#{path}/#{name.strip}.sql", "w")
    out_file.puts(source)
    out_file.close
  end

  # It creates a directory if it does not exist
  def create_dir(path)
    FileUtils.mkdir_p(path, { mode: 0775 }) unless File.exists?(path)
  end

  # It deletes all the content in the target directory
  def delete_content_dir(path)
    FileUtils.rm_rf(Dir.glob("#{path}/*"))
  end
end
