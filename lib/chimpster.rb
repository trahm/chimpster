def require_local(file)
  require File.join(File.dirname(__FILE__), 'chimpster', file)
end

require_local 'message_extensions/shared'
require_local 'message_extensions/mail'
require_local 'handlers/mail'

module Chimpster

  MAX_RETRIES = 2

  class << self
    attr_accessor :api_key, :max_retries, :sleep_between_retries , :uakari

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
         @uakari.send_email(message)
    end

    def send_through_chimpster(message) #:nodoc:
      @retries = 0
      begin
        options= {
            :html       => message.body.raw_source,
            :subject    => message.subject,
            :from_email => (message['from'].to_s  if message.from),
            :to_email   => message['to'].to_s.split(',')
         }
        self.send({
          :track_opens => true,
          :track_clicks => true,
          :message => options,
          :tags => (message.tag.to_s if message.tag)
        })
      rescue Exception => e
        if @retries < max_retries
           @retries += 1
           retry
        else
          raise
        end
      end
    end
  end
end
