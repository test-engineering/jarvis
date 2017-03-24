require 'jarvis/generator/plan/plan_generator'

module Generator
  module Plan
    # top class
    class PlanList

      attr_accessor :plan_list

      def initialize(plans)
        @plan_list = {}
        plans.each do |plan|
          @plan_list[plan] = Generator::Plan::PlanGenerator.new(plan)
        end
      end

      def create_on_blaze
        @plan_list.each do |_name, plan|
          plan.create_on_blaze
        end
      end

      def names
        @plan_list.keys
      end

      def plan_clone(plan_name, qtd, files)
        name = plan_list[plan_name].name
        plan_list[plan_name].name("#{name} 1")
        files.each do |file|
          file_name = plan_list[plan_name].file_path(file).split('/').last
          plan_list[plan_name].file_path(file, "~/.jarvis/tmp/#{plan_name}1/#{file_name}")
        end

        2.upto(qtd) do |i|
          plan_list[plan_name + i.to_s] = Generator::Plan::PlanGenerator.new(plan_name)

          plan_list[plan_name + i.to_s].name(name + " #{i}")
          files.each do |file|
            file_name = plan_list[plan_name + i.to_s].file_path(file).split('/').last
            plan_list[plan_name + i.to_s].file_path(file, "~/.jarvis/tmp/#{plan_name}#{i}/#{file_name}")
          end
        end
      end

    end
  end
end
