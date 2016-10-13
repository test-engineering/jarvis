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
    response = self.class.post('/tests/',:body => body, :headers => { 'Content-Type' => 'application/json' })
    project_id = response['result']['projectId']
    test_id = response['result']['id']
    puts "Plan created - #{response['result']['name']}".colorize(:light_blue)
    # if project_id != 38143
    #   $client.chat_postMessage(channel: '#arquitetura-testes', text: "Criação: #{response["result"]["name"]} -- https://a.blazemeter.com/app/#projects/#{project_id}/tests/#{test_id}", as_user: true)
    # end
    puts "https://a.blazemeter.com/app/#projects/#{project_id}/tests/#{test_id}".colorize(:light_blue).underline
    response['result']['id']
  end

  def update_test(body, plan_id)
    self.class.post("/tests/#{plan_id}",:body => body, :headers => { 'Content-Type' => 'application/json' })
  end

  def get_plan_info(plan_id)
    self.class.get("/tests/#{plan_id}", :headers => { 'Content-Type' => 'application/json' })
  end

  ## Using New Jarvis
  def upload_file(file_path, plan_id)
    options = { :headers => { 'Content-Type' => 'multipart/form-data', 'x-api-key' => ENV['APIKEY'] },
                :body => { :file => File.new(file_path)}
              }
    Printer.instance.draw("Uploading file - #{file_path}".colorize(:yellow))
    Retriable.retriable do
      @response = HTTMultiParty.post("https://a.blazemeter.com:443/api/latest/tests/#{plan_id}/files", options )
    end
    Printer.instance.clear.draw("Upload finished - #{file_path}".colorize(:green)).start_new
    return @response
  end

  ## Using New Jarvis
  def create_mult_test(body)
    self.class.post('/collections?populate_tests=true', :body => body, :headers => { 'Content-Type' => 'application/json' })
  end

  def delete_plan(id)
    self.class.delete("/collections/#{id}")
  end

  def get_plans_from_project(project_id)
    response = self.class.get("/tests?limit=20&project_id=#{project_id}", :headers => { 'Content-Type' => 'application/json' })
    plans_info = {}
    response['result'].each do |plan|
      plans_info[plan['name']] = {'id'=>plan['id'],'duration'=>plan['configuration']['plugins']['jmeter']['override']['duration']}
    end
    return plans_info
  end

  def start_plan(plan_id)
    self.class.get("/tests/#{plan_id}/start", :headers => { 'Content-Type' => 'application/json' })
  end

  def get_test_status(test_id)
    options = {:headers => {'Content-Type' => 'application/json'}}
    self.class.get("/masters/#{test_id}/status", options)
  end

  def get_test_metrics(test_id)
    metrics = Hash.new

    options = {:headers => {'Content-Type' => 'application/json'}}
    test_status = nil
    test_metrics = nil

    5.times do
      test_status = self.get_test_status(test_id)
      test_metrics = self.class.get("/masters/#{test_id}/reports/default/summary?label=ALL", options)
      break if test_status != nil && test_metrics != nil
      sleep 0.5
    end

    duration = test_metrics['result']['summary'][0]['duration'] < 1 ? 1 : test_metrics['result']['summary'][0]['duration']

    metrics['started_time'] = test_metrics['result']['summary'][0]['first']
    metrics['duration'] = test_metrics['result']['summary'][0]['duration']
    metrics['last_update'] = test_metrics['result']['summary'][0]['last']
    metrics['max_users'] = test_metrics['result']['maxUsers'].to_s
    metrics['tps'] = test_metrics['result']['summary'][0]['hits'] / duration.to_f
    metrics['errors_rate'] = test_metrics['result']['summary'][0]['failed'].to_f / test_metrics['result']['summary'][0]['hits'] * 100
    metrics['tp90'] = test_metrics['result']['summary'][0]['tp90']
    metrics['test_status'] = test_status['result']['status']

    return metrics
  end

  def share_plan(plan_id)
    options = {:headers => {'Content-Type' => 'application/json'}}
    response = self.class.post("/masters/#{plan_id}/publicToken", options)
    return response['result']['publicToken'] if response['error'] == nil
  end

  def list_projects
    options = {:headers => {'Content-Type' => 'application/json'}}
    response = self.class.get('/user/projects?&limit=25', options)
    projects = {}
    response['result'].each do |plan|
      projects[plan['name']] = plan['id']
    end
    return projects
  end

  def get_aggregate_report(test_id)
    options = {:headers => {'Content-Type' => 'application/json'}}
    response = nil

    5.times do
      response = self.class.get("/masters/#{test_id}/reports/aggregatereport/data", options)
      break if response != nil
      sleep 0.5
    end
    return response
  end

  def list_reports
    options = {:headers => {'Content-Type' => 'application/json'}}
    response = self.class.get('/user/masters?sort%5B%5D=-updated&limit=20', options)

    reports = {}
    response['result'].each do |report|
      reports[report['id']] = report
    end

    return reports
  end

  def get_plans_from_multi(multi_id)
    options = {:headers => {'Content-Type' => 'application/json'}}
    response = self.class.get("/collections/#{multi_id}/masters", options)['result'].last['sessions']
    sessions = {'checkout' => [], 'webstore' => [], 'search' => [], 'app' => [], 'cadastro' => [], 'selfhelp' => [], 'wishlist' => []}

    response.each do |s|
      sessions['checkout'] << s['id'] if s['name'].downcase.include? 'checkout'
      sessions['webstore'] << s['id'] if s['name'].downcase.include? 'webstore'
      sessions['search'] << s['id'] if s['name'].downcase.include? 'search'
      sessions['cadastro'] << s['id'] if s['name'].downcase.include? 'cadastro'
      sessions['app'] << s['id'] if s['name'].downcase.include? 'mobile'
      sessions['selfhelp'] << s['id'] if s['name'].downcase.include? 'self'
      sessions['wishlist'] << s['id'] if s['name'].downcase.include? 'wish'
    end

    return sessions
  end

  def terminate(plan_id)
    options = {:headers => {'Content-Type' => 'application/json'}}
    self.class.post("/tests/#{plan_id}/terminate", options)
  end

  def graceful_shutdown()
    options = {:headers => {'Content-Type' => 'application/json'}}
    self.class.post("/tests/#{plan_id}/stop", options)
  end

  def get_individual_aggregate(session_id)
    self.class.get("/sessions/#{session_id}/reports/aggregatereport/data")
  end

  def mult_aggregate(multi_id)
    aggregate = { 'id' => multi_id, 'labels' => {} }
    sessions = get_plans_from_multi(multi_id)

    sessions.each do |product_sessions|
      aggregate['labels'][product_sessions[0]] = {}
      product_sessions[1].each do |s|
        labels = get_individual_aggregate s
        labels['result'].each do |label|
          if aggregate['labels'][product_sessions[0]].key?(label['labelName'])
            aggregate['labels'][product_sessions[0]][label['labelName']]['samples'] = aggregate['labels'][product_sessions[0]][label['labelName']]['samples'] + label['samples']
            aggregate['labels'][product_sessions[0]][label['labelName']]['errorsCount'] = aggregate['labels'][product_sessions[0]][label['labelName']]['errorsCount'] + label['errorsCount']
            aggregate['labels'][product_sessions[0]][label['labelName']]['duration'] = label['duration'] if aggregate['labels'][product_sessions[0]][label['labelName']]['duration'] < label['duration']
            aggregate['labels'][product_sessions[0]][label['labelName']]['95line'] =+ label['95line'] if aggregate['labels'][product_sessions[0]][label['labelName']]['95line'] < label['95line']
          else
            aggregate['labels'][product_sessions[0]][label['labelName']] = {}
            aggregate['labels'][product_sessions[0]][label['labelName']]['samples'] = label['samples']
            aggregate['labels'][product_sessions[0]][label['labelName']]['errorsCount'] = label['errorsCount']
            aggregate['labels'][product_sessions[0]][label['labelName']]['duration'] = label['duration']
            aggregate['labels'][product_sessions[0]][label['labelName']]['95line'] =+ label['95line']
          end
        end
      end
    end
    generate_kpi_metrics aggregate
  end

  def generate_kpi_metrics(aggregate)
    aggregate['labels'].each{ |key, value| value.each{ |k, v|
      if v['errorsCount'] > 0
        v['errorsRate'] = '%.2f' % ((v['errorsCount'].to_f * 100)/ v['samples'])
      else  v['errorsRate'] = 0
      end
      v['avgThroughput'] = '%.2f' %  (v['samples'].to_f / v['duration']*60)
    }}
    return aggregate
  end

end
