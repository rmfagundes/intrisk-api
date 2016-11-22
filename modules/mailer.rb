require 'net/smtp'
module Modules
  # Module that enables sending e-mail notifications
  module Mailer
    def send_mail(options)
      conf = YAML.load_file('conf/mailer.yml')
      conf.merge!(options)
      Net::SMTP.start(conf[:host], conf[:port], conf[:fqdn],
                      conf[:user], conf[:pwd]) do |smtp|
        smtp.send_message conf[:message], conf[:from], conf[:to]
      end
    end

    def stringify_to(to, to_name)
      if to.is_a?(Array)
        to_str = ''
        to.zip(to_name).each do |it_mail, it_name|
          to_str << ', ' unless to_str.empty?
          to_str << "#{it_name} <#{it_mail}>"
        end
        return to_str
      end
      "#{to_name} <#{to}>"
    end

    def send_text(options)
      to_str = stringify_to(options[:to], options[:to_name])
      options[:message] = <<-MESSAGE_END
From: #{options[:from_name]} <#{options[:from]}>
To: #{to_str}
Subject: #{options[:subject]}

#{options[:content]}
MESSAGE_END

      send_mail(options)
    end

    def send_html(options)
      to_str = stringify_to(options[:to], options[:to_name])
      options[:message] = <<-MESSAGE_END
From: #{options[:from_name]} <#{options[:from]}>
To: #{to_str}
MIME-Version: 1.0
Content-type: text/html
Subject: #{options[:subject]}

#{options[:content]}
MESSAGE_END

      send_mail(options)
    end
  end
end
