require 'thor'
require 'jarvis/generator/multi/multi_generator'
require 'jarvis/questions/menu'
require 'helpers/printer'

module Jarvis
  # top class
  class Cli < Thor
    desc 'execute', 'Runs Jarvis wizard'
    def execute
      Questions::Menu.start
    end
  end
end
