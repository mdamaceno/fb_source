require 'optparse'
require_relative './lib/fb_source.rb'
require_relative './lib/fb_source/exceptions/not_configured_database.rb'
require_relative './lib/fb_source/exceptions/not_configured_output.rb'

# If database variables is not defined in .env file, it will prompt an error
if ENV['DATABASE_HOST'].nil? ||
   ENV['DATABASE_PORT'].nil? ||
   ENV['DATABASE_NAME'].nil? ||
   ENV['DATABASE_USERNAME'].nil? ||
   ENV['DATABASE_PASSWORD'].nil?
  raise NotConfiguredDatabase.new('Database is not configured. Check the .env file.')
end

# Optional parameters that can be used when running on terminal
# Example: run.db -p $HOME/procedures
# This will create a folder called procedures in user's home directory
# with all procedures that come from the database
options = {}

OptionParser.new do |parser|
  parser.on("-o", "--output PATH", "Output path for the backup.") do |v|
    options[:output] = v
  end
end.parse!

# Check if OUTPUT_PATH variable is defined or --output options is passed
if ENV['OUTPUT_PATH'].nil? && options[:output].nil?
  raise NotConfiguredOutput.new('You need to specify the OUTPUT_PATH in .env file.')
end

# this overrides output path defined in .env if optional parameters is used
output_path = options[:output].nil? ? ENV['OUTPUT_PATH'] : options[:output]

# Create an instance of FbSource class
fb_source = FbSource.new({
  output_path: output_path,
})

# Get procedures from database
fb_source.get_procedures.each do |row|
  fb_source.write_source("#{output_path}/procedures", row['RDB$PROCEDURE_NAME'], row['RDB$PROCEDURE_SOURCE'])
end

# Get triggers from database
fb_source.get_triggers.each do |row|
  fb_source.write_source("#{output_path}/triggers", row['RDB$TRIGGER_NAME'], row['RDB$TRIGGER_SOURCE'])
end

# Get views from database
fb_source.get_views.each do |row|
  fb_source.write_source("#{output_path}/views", row['RDB$RELATION_NAME'], row['RDB$VIEW_SOURCE'])
end

puts "Script finished!"
