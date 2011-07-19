require 'spec_helper'

describe "Chimpster" do

  let :mail_message do
    Mail.new do
      from    "mike@fotomoto.com"
      to      "mike@fotomoto.com"
      subject "Hello!"
      body    "Hello Sheldon!"
    end
  end

  let :mail_html_message do
    mail = Mail.new do
      from          "mike@fotomoto.com"
      to            "mike@fotomoto.com"
      subject       "Hello!"
      html_part do
        body        "<b>Hello Sheldon!</b>"
      end
    end
  end
  
  let :mail_multipart_message do
    mail = Mail.new do
      from          "mike@fotomoto.com"
      to            "mike@fotomoto.com"
      subject       "Hello!"
      text_part do
        body        "Hello Sheldon!"
      end
      html_part do
        body        "<b>Hello Sheldon!</b>"
      end
    end
  end



  
  context "mail delivery method" do
    it "should be able to set delivery_method" do
      mail_message.delivery_method Mail::Chimpster
      puts mail_message.delivery_method
    end
    
    it "should wrap Chimpster.send_through_chimpster" do
      message = mail_message
      @error_response={'status'=>'sent'}
      Chimpster.should_receive(:send).and_return(@error_response)

      mail_message.delivery_method Mail::Chimpster  , {:api_key => 'api-key'}

      mail_message.deliver
    end
    
    it "should allow setting of api_key" do
      mail_message.delivery_method Mail::Chimpster, {:api_key => 'api-key'}
      mail_message.delivery_method.settings[:api_key].should == 'api-key'
    end

    it "should throw an exception when the request fails " do
      @error_response={'status'=>'error'}
      Chimpster.should_receive(:send).and_return(@error_response)
      lambda{
        mail_message.delivery_method Mail::Chimpster  , {:api_key => 'api-key'}
        mail_message.deliver
      }.should raise_exception

    end
  end



end
