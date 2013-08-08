class MailSender
  include Sidekiq::Worker

  def perform(mailer_klass_name, mailer_method, options)
    return if mailer_klass_name.nil? || mailer_klass_name.empty?
    return if mailer_method.nil? || mailer_method.empty?
    begin
      mailer = mailer_klass_name.to_s.constantize
      if mailer.respond_to?(mailer_method.to_sym)
        mail_message = mailer.send(mailer_method.to_sym, options)
        mail_message.deliver if mail_message
      end
    rescue Exception => e
      logger.error("Mail for #{mailer_klass_name} with #{mailer_method} can not be sent. Exception occurred: #{e.message}")
      false
    end
    true
  end
end