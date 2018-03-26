require_relative 'versionable/dsl'

::ActiveAdmin::DSL.send(:include, Versionable::DSL)
