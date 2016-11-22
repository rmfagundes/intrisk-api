require_relative './mailer'
module Modules
  # Class that enables reading workflow configuration and objects status
  # changing
  class Workflow
    include Modules::Mailer

    attr_reader :wflow

    def initialize(file)
      @wflow = YAML.load_file(file) unless file.nil?
    end

    def exec(model, action)
      flow_action = find_action_config(model, action)
      raise ArgumentError, 'Invalid Workflow Action' if flow_action.nil?
      assess_policies(model, flow_action['policies'])
      change_status(model, flow_action['transition_to'])
      notify(model, flow_action['notify'])
    end

    private

    def find_action_config(model, action)
      return @wflow['statuses']['init'] if action.eql?('init')
      @wflow['statuses'].each do |key, value|
        next if key.eql?('init') || !key.eql?(model.status)
        value['actions'].each do |key_action, value_action|
          return value_action if action.eql?(key_action)
        end
      end
      nil
    end

    def change_status(model, status)
      model.send('status=', status) unless status.nil?
    end

    def assess_policies(model, policies)
      return nil if policies.nil?
      policies.each do |pol|
        @wflow['policies'].each do |key, value|
          if pol.eql?(key)
            policy_instance = cls_from_string(value['class']).new
            policy_instance.send('run', model)
          end
        end
      end
    end

    def cls_from_string(str)
      str.split('::').inject(Object) do |mod, class_name|
        mod.const_get(class_name)
      end
    end

    def notify(model, msg_config)
      return nil if msg_config.nil?
      msg_config.each do |notification|
        recipients = find_recipients(model, notification['recipients'])
        sender = find_sender(model, notification['sender'])
        case notification['deliver_by']
        when 'e-mail'
          send("send_#{notification['format']}",
               build_mail_options(recipients, sender, notification))
        end
      end
    end

    def build_mail_options(recipients, sender, notification)
      { to: recipients[:emails], to_name: recipients[:names],
        from_name: sender[:name], from: sender[:email],
        subject: notification['subject'], content: notification['content'] }
    end

    def find_recipients(model, rec_cfg)
      recipients = { emails: [], names: [] }
      unless rec_cfg['method'].nil?
        recipients = build_recipients(recipients,
                                      model.send(rec_cfg['method'],
                                                 rec_cfg['arguments']))
      end
      recipients = build_recipients(recipients,
                                    names: rec_cfg['names'],
                                    emails: rec_cfg['emails'])
      recipients
    end

    def build_recipients(recipients, rec)
      rec = { emails: [], names: [] } if rec.nil?
      recipients[:emails].concat(rec[:emails]) unless rec[:emails].nil?
      recipients[:names].concat(rec[:names]) unless rec[:names].nil?
      recipients
    end

    def find_sender(model, sender_cfg)
      if sender_cfg['method'].nil?
        return { email: sender_cfg['email'], name: sender_cfg['name'] }
      else
        return model.send(sender_cfg['method'],
                          sender_cfg['arguments'])
      end
    end
  end
end
