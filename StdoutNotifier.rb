#! /usr/bin/ruby

class Notifier
  def send_alert(host, service, start_time, uptime)
    msg = "ALERT! #{host}: #{service} "
    msg << "was started #{start_time} "
    msg << "and has been running for #{uptime} hours!"

    puts msg
  end
end

if __FILE__ == $0 then
  x = "*.rb"
  puts system("ls #{x}")
end
