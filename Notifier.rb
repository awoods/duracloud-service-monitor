#! /usr/bin/ruby

require 'logger'

class Notifier

  def initialize(emails)
    @emails = emails
    @log = get_logger
  end

  def get_logger
    log_dir = "#{File.expand_path(File.dirname(__FILE__))}/logs"
    unless File::directory?(log_dir)
      Dir.mkdir(log_dir)
    end
    Logger.new("#{log_dir}/#{File.basename($0)}.log", 10, 512000)
  end

  def puts(host, service, start_time, uptime)
    msg = "ALERT! #{host}: #{service} "
    msg << "was started #{start_time} "
    msg << "and has been running for #{uptime} hours!"

    @log.warn msg
    system(%Q{echo #{msg} | mail -s "DuraCloud Service Alert" #{@emails.join(" ")}})
  end
end

if __FILE__ == $0 then
  emails = ["a","b","c"]
  Notifier.new(emails).send_alert("x","y","z","w")
end
