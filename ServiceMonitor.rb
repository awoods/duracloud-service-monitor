require 'rubygems'
require 'rexml/document'
require 'httpclient'
require 'date'
require 'Notifier'

class ServiceMonitor

  def initialize(host, username, password)
    @host = host
    @domain = "https://#{@host}/duraservice"

    @clnt = HTTPClient.new
    @clnt.ssl_config.set_trust_ca("/etc/ssl/certs")
    @clnt.set_auth(@domain, username, password)

    @notifier = $stdout
  end

  def notifier=(n)
    @notifier = n
  end

  def authenticates?
    status = 0
    begin
      status = @clnt.get(@domain + '/services').status
    rescue => e
    end
    status == 200
  end

  def detect_long_running_services(max_hours)
    deployed = @clnt.get_content(@domain + '/services?show=deployed')
    doc = REXML::Document.new(deployed)
    doc.elements.each("dur:services/service") do |svc|
      service_name = svc.attribute("displayName").to_s
      id = svc.attribute("id")

      svc.elements.each("deployments/deployment") do |deployment|
        dep_id = deployment.attribute("id")
        props = get_properties(id, dep_id)

        start_time = get_prop(props, "Job Started")
        job_status = get_prop(props, "Job State")

        if is_running?(job_status)
          uptime = get_uptime(start_time)
          if max_hours < uptime
            @notifier.puts(@host, service_name, start_time, uptime)
          end
        end

      end
    end
  end

  def get_properties(id, dep_id)
    props = @clnt.get_content(@domain + "/#{id}/#{dep_id}/properties")
    props_doc = REXML::Document.new(props)
    props_doc.get_elements("map/entry")
  end

  def get_prop(props, search_key)
    props.each do |prop|
      pair = prop.get_elements("string")
      if search_key == pair[0].text then
        return pair[1].text
      end
    end
  end

  def is_running?(status)
    unless status.nil?
      return status == "RUNNING" || status == "STARTING"
    end
  end

  def get_uptime(start_time)
    start = DateTime.parse(start_time)
    now = DateTime::now.new_offset(5/24) # set to UTC, not local time
    diff = now - start
    hours,mins,secs,frac = Date.day_fraction_to_time(diff)
    return hours
  end

end

