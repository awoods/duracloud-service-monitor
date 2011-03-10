#! /usr/bin/ruby

require 'date'
require 'yaml'
require 'logger'
require 'ServiceMonitor'

def get_logger
  log_dir = "logs"
  unless File::directory?(log_dir)
    Dir.mkdir(log_dir)
  end
  Logger.new("#{log_dir}/#{$0}.log", 10, 512000)
end

def do_monitor(hosts, auths, notifier)
  log = get_logger

  hosts.each do |host| 
    host << ".duracloud.org"
    log.info "monitoring: #{host}" 
    begin
      monitor = create_authenticated_monitor(host, auths)
      if monitor.nil? then
        log.warn "Unable to authenticate with host: #{host}"
      else
        monitor.notifier = notifier
        monitor.detect_long_running_services(5)
      end
    rescue => e
      log.error e
    end
  end

  log.close
end


def create_authenticated_monitor(host, auths)
  max_tries = 3
  tries = 0
  monitor = nil

  while monitor.nil? && tries < max_tries
    monitor = do_create_authenticated_monitor(host, auths)
    tries += 1
  end 
  return monitor
end


def do_create_authenticated_monitor(host, auths)
  auths.each do |auth|
    monitor = ServiceMonitor.new(host, auth["username"], auth["password"])
    if monitor.authenticates?
      return monitor
    end
  end
  return nil
end


def usage
  puts "Usage: #{$0} <config-filename>"
  puts "\twhere 'config-file' a yaml file of the form:"
  puts "\t\thosts:"
  puts "\t\t\t- bhl"
  puts "\t\t\t- nypl"
  puts "\t\t\t- etc"
  puts "\t\tauths:"
  puts "\t\t\t- username: xx"
  puts "\t\t\t  password: yy"
  puts "\t\t\t- username: aa"
  puts "\t\t\t  password: bb"
  puts "\t\trecipients:"
  puts "\t\t\t- name@gmail.com"
  puts "\t\t\t- other@gmail.com"
end


# main method
if __FILE__ == $0
  config_filename = ARGV[0]
  if config_filename.nil? || !File::exist?(config_filename)
    usage
    exit 1
  end

  config = YAML.load_file(config_filename)

  notifier = Notifier.new(config["recipients"])
  do_monitor(config["hosts"], config["auths"], notifier)
end

