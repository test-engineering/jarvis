require 'httparty'
require 'httmultiparty'
require 'colorize'
require 'retriable'

class Blaze

  include HTTParty
  include HTTMultiParty

  base_uri 'a.blazemeter.com:443/api/latest'
  format :json
  headers 'x-api-key' => ENV['APIKEY']
  open_timeout 5

  ## Using New Jarvis
  def create_test(body)
    response = self.class.post('/tests/', body: body, headers: { 'Content-Type' => 'application/json' })
    project_id = response['result']['projectId']
    test_id = response['result']['id']
    puts "Plan created - #{response['result']['name']}".colorize(:light_blue)
    puts "https://a.blazemeter.com/app/#projects/#{project_id}/tests/#{test_id}".colorize(:light_blue).underline
    response['result']['id']
  end

  def update_test(body, plan_id)
    self.class.post("/tests/#{plan_id}", body: body, headers: { 'Content-Type' => 'application/json' })
  end

  def get_plan_info(plan_id)
    self.class.get("/tests/#{plan_id}", headers: { 'Content-Type' => 'application/json' })
  end

  ## Using New Jarvis
  def upload_file(file_path, plan_id)
    options = { headers: { 'Content-Type' => 'multipart/form-data', 'x-api-key' => ENV['APIKEY'] },
                body: { file: File.new(file_path) } }
    Printer.instance.draw("Uploading file - #{file_path}".colorize(:yellow))
    Retriable.retriable do
      @response = HTTMultiParty.post("https://a.blazemeter.com:443/api/latest/tests/#{plan_id}/files", options)
    end
    Printer.instance.clear.draw("Upload finished - #{file_path}".colorize(:green)).start_new
    @response
  end

  ## Using New Jarvis
  def create_mult_test(body)
    self.class.post('/collections?populate_tests=true', body: body, headers: { 'Content-Type' => 'application/json' })
  end

  def delete_plan(id)
    self.class.delete("/collections/#{id}")
  end

  def get_plans_from_project(project_id)
    response = self.class.get("/tests?limit=20&project_id=#{project_id}",
                              headers: { 'Content-Type' => 'application/json' })
    plans_info = {}
    response['result'].each do |plan|
      plans_info[plan['name']] = { 'id' => plan['id'],
                                   'duration' => plan['configuration']['plugins']['jmeter']['override']['duration'] }
    end
    plans_info
  end

  def start_plan(plan_id)
    self.class.get("/tests/#{plan_id}/start", headers: { 'Content-Type' => 'application/json' })
  end

  def get_test_status(test_id)
    options = { headers: { 'Content-Type' => 'application/json' } }
    self.class.get("/masters/#{test_id}/status", options)
  end

  def list_projects
    options = { headers: { 'Content-Type' => 'application/json' } }
    response = self.class.get('/user/projects?&limit=25', options)
    projects = {}
    response['result'].each do |plan|
      projects[plan['name']] = plan['id']
    end
    projects
  end

  def list_reports
    options = { headers: { 'Content-Type' => 'application/json' } }
    response = self.class.get('/user/masters?sort%5B%5D=-updated&limit=20', options)

    reports = {}
    response['result'].each do |report|
      reports[report['id']] = report
    end

    reports
  end

  def terminate(plan_id)
    options = { headers: { 'Content-Type' => 'application/json' } }
    self.class.post("/tests/#{plan_id}/terminate", options)
  end

  def graceful_shutdown
    options = { headers: { 'Content-Type' => 'application/json' } }
    self.class.post("/tests/#{plan_id}/stop", options)
  end

  def get_individual_aggregate(session_id)
    self.class.get("/sessions/#{session_id}/reports/aggregatereport/data")
  end

end
