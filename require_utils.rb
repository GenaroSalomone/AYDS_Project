require 'sinatra'
require 'bundler/setup'
require 'logger'
require 'sinatra/activerecord'
require 'bcrypt'
require 'sinatra/session'
require 'dotenv/load'
require 'securerandom'
require 'enumerize'
require 'jwt'
require 'net/http'
require 'uri'
require 'json'
require 'sinatra/cross_origin'
require 'sanitize'
require 'mail'
require_relative 'models/user'
require_relative 'models/question'
require_relative 'models/choice'
require_relative 'models/answer'
require_relative 'models/difficulty'
require_relative 'models/trivia'
require_relative 'models/question_answer'
require_relative 'models/true_false'
require_relative 'models/autocomplete'
require_relative 'models/ranking'
require_relative 'models/claim'
require_relative 'controllers/answer_controller'
require_relative 'controllers/results_controller'
require_relative 'controllers/login_controller'
require_relative 'controllers/trivia_controller'
require_relative 'controllers/claim_controller'
require_relative 'controllers/error_controller'
