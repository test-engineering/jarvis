require 'jarvis/generator/plan/plan_list'
require 'blazemeter/blazemeter'

module Generator
  module Multi
    class MultiGenerator

      attr_accessor :plans
      attr_accessor :multi_id
      attr_accessor :body
      attr_accessor :config

      def initialize(file_name)
        @config = YAML.load_file("#{ENV['HOME']}/.jarvis/multi/#{file_name}.yml")
        @plans = Generator::Plan::PlanList.new(@config['plans'].keys)
        @body = { 'name' => @config['name'], 'projectId' => @config['projectId'], 'items' => [] }
      end

      def create_on_blaze
        @plans.create_on_blaze
        generate_items
        set_rampup_duration(@config['rampup'], @config['duration'])
        puts @body['name'].to_s.colorize(:light_blue)
        response = Blaze.new.create_mult_test(@body.to_json)
        puts "https://a.blazemeter.com/app/#projects/#{response['result']['projectId']}/collections/#{response['result']['id']}".colorize(:light_blue).underline
      end

      def generate_items
        @plans.names.each do |plan_name|
          if @config['plans'][plan_name]['copies']
            add_item(plan_name, @config['plans'][plan_name]['copies'])
          else
            add_item(plan_name)
          end
        end
      end

      def add_item(plan_name, qtd = 1)
        qtd.times do
          @body['items'] << { 'testId' => @plans.plan_list[plan_name].plan_id,
                              'location' => @plans.plan_list[plan_name].location,
                              'override' => { 'rampup' => @plans.plan_list[plan_name].rampup,
                                              'duration' => @plans.plan_list[plan_name].duration } }
        end
      end

      def set_rampup_duration(rampup, duration)
        raise 'Generate itens first...' if @body['items'] == []
        @body['items'].each do |item|
          item['override']['rampup'] = rampup * 60
          item['override']['duration'] = duration
        end
      end

    end
  end
end
