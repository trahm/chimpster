require 'uakari'
module Mail
  class Chimpster
    
    attr_accessor :settings, :uakari
    
    def initialize(values)
      self.settings = { :api_key => nil }.merge(values)
      self.uakari = Uakari.new(self.settings[:api_key])
    end
    
    def deliver!(mail)
      ::Chimpster.api_key = settings[:api_key]
      ::Chimpster.uakari = uakari
      ::Chimpster.send_through_chimpster(mail)
    end
    
  end
end