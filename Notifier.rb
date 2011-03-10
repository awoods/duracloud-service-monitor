#! /usr/bin/ruby

class Notifier

  def initialize(emails)
    @emails = emails
  end

  def puts(host, service, start_time, uptime)
    msg = "ALERT! #{host}: #{service} "
    msg << "was started #{start_time} "
    msg << "and has been running for #{uptime} hours!"

    system(%Q{echo #{msg}  mail -s "DuraCloud Service Alert" #{@emails.join(" ")}})
  end
end

if __FILE__ == $0 then
  emails = ["a","b","c"]
  Notifier.new(emails).send_alert("x","y","z","w")
end
