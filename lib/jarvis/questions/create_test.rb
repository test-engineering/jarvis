require 'thor/group'
require 'jarvis/manager/files'
require 'jarvis/generator/multi/multi_generator'
require 'inquirer'

module Questions
  class CreateTest < Thor::Group

    def type
      options = [
        'Multi',
        'Plan'
      ]
      type_idx = Ask.list 'Type', options
      @type = options[type_idx]
    end

    def list
      options = Manager::Files.new.list(@type.downcase)
      idx = Ask.list @type, options
      @file_name = options[idx]
    end

    def execute
      case @type
      when 'Multi'
        Generator::Multi::MultiGenerator.new(@file_name).create_on_blaze
      when 'Plan'
        Generator::Plan::PlanGenerator.new(@file_name).create_on_blaze
      end
    end

  end
end