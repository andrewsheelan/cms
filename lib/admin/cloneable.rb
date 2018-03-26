require_relative 'cloneable/dsl'

::ActiveAdmin::DSL.send(:include, Cloneable::DSL)
