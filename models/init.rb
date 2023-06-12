require 'active_record'
require_relative 'user'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/test.sqlite3',
  pool: 5,
  timeout: 5000
)
