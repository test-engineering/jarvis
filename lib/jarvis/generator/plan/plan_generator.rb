require 'yaml'
require 'blazemeter/blazemeter'

module Generator
  module Plan
    # top-class
    class PlanGenerator

      attr_accessor :file
      attr_accessor :plan_id

      def initialize(file_name)
        @file = YAML.load_file("#{ENV['HOME']}/.jarvis/plan/#{file_name}.yml")
      end

      def create_on_blaze
        @plan_id = Blaze.new.create_test(@file['plan'].to_json)
        upload_files
        @plan_id
      end

      def upload_files
        @file['files'].each do |_key, path|
          Blaze.new.upload_file(path, @plan_id)
        end
      end

      def location(location_name = nil)
        @file['plan']['configuration']['location'] = location_name if location_name
        @file['plan']['configuration']['location']
      end

      def rampup(value = nil)
        @file['plan']['configuration']['plugins']['jmeter']['override']['rampup'] = value if value
        @file['plan']['configuration']['plugins']['jmeter']['override']['rampup']
      end

      def duration(value = nil)
        @file['plan']['configuration']['plugins']['jmeter']['override']['duration'] = value if value
        @file['plan']['configuration']['plugins']['jmeter']['override']['duration']
      end

      def name(value = nil)
        @file['plan']['name'] = value if value
        @file['plan']['name']
      end

      def file_path(key, value = nil)
        @file['file'][key] = value if value
        @file['plan'][key]
      end

    end
  end
end
