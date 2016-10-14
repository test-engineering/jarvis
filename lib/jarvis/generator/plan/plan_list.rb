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
        @plan_list.each do |name, plan|
          plan.create_on_blaze
        end
      end

      def names
        @plan_list.keys
      end

    end
  end
end
