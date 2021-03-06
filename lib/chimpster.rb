def require_local(file)
  require File.join(File.dirname(__FILE__), 'chimpster', file)
end

require_local 'message_extensions/shared'
require_local 'message_extensions/mail'
require_local 'handlers/mail'
require 'logging'

module Chimpster

  MAX_RETRIES = 2

  class << self
    attr_accessor :api_key, :max_retries, :sleep_between_retries , :uakari, :logger

    def logger
      Logging.logger(STDOUT)
    end

    def max_retries
      @max_retries ||= 3
    end

    def sleep_between_retries
      @sleep_between_retries ||= 10
    end

    def configure
      yield self
    end

    def send (message)
         response = @uakari.send_email(message)

         response
    end

    def send_through_chimpster(message) #:nodoc:
      puts 'sending email'
      @retries = 0
      options= {
          :html       => message.body.raw_source,
          :subject    => message.subject,
          :from_email => (message['from'].to_s  if message.from),
          :to_email   => message['to'].to_s.split(',')
       }
      response = self.send({
        :track_opens => true,
        :track_clicks => true,
        :message => options,
        :tags => (message.tag.to_s if message.tag)
      })
      c=response['status']
      v= ['queued','sent'].include?(c)
      if v == false
        logger.info "ERROR Sending Email via Chimpster #{response.to_s}"
      else
        logger.info "Email Sent via Chimpster #{response.to_s}"
      end
      v
    end
  end
end
