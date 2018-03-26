require 'csv'
require 'json'
require 'charlock_holmes'
require 'open-uri'

require_relative "importable/data"
require_relative 'importable/dsl'
require_relative 'importable/fileless_io'

::ActiveAdmin::DSL.send(:include, Importable::DSL)
