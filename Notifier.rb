#! /usr/bin/ruby

class Notifier

  def initialize(emails)
    @emails = emails
  end

  def get_logger
    log_dir = "logs"
    unless File::directory?(log_dir)
      Dir.mkdir(log_dir)
    end
    Logger.new("#{log_dir}/#{$0}.log", 10, 512000)
  end

  def puts(host, service, start_time, uptime)
    msg = "ALERT! #{host}: #{service} "
    msg << "was started #{start_time} "
    msg << "and has been running for #{uptime} hours!"

    @log.warn msg
    system(%Q{echo #{msg}  mail -s "DuraCloud Service Alert" #{@emails.join(" ")}})
  end
end

if __FILE__ == $0 then
  emails = ["a","b","c"]
  Notifier.new(emails).send_alert("x","y","z","w")
end
