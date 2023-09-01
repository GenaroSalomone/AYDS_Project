db_options = YAML.load(File.read('./config/database.yml'))

environment = ENV['RACK_ENV'] || 'development'
ActiveRecord::Base.establish_connection(db_options[environment])
