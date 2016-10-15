class Sms
  
  SMS_URL = ENV['SMS_URL'] || "api.smscloud.com"
  SMS_PATH = ENV['SMS_PATH'] || "/xmlrpc?apiVersion=1.0&key=359B97E0832315A68655C73EB3323E52937CC401"

  def self.new_opportunity(opportunity, company)

    number_bank = %w(12052674927 12055336910 12055336913 12055336915 12055336909)
    msg_bank = [
      "Subout : A new opportunity for you ",
      "Subout : A new entry just arrived ",
      "Subout : A new opportunity now available ",
      "Subout : Something new just showed up ",
      "Subout : A new opportunity is available for you ",
    ]

    begin
      bitly = Bitly.new("suboutdev", "R_8ba0587adb559eb9b2576826a915b557")
      short_url = bitly.shorten("https://#{DEFAULT_HOST_WITH_PORT}/#/opportunities/#{opportunity.reference_number}").short_url
    rescue Exception => e
      puts e.backtrace
      short_url = ""    
    end

    message = msg_bank.shuffle.first + "from #{opportunity.buyer.abbreviated_name}: #{opportunity.name} #{short_url}"
    if Rails.env.production?
      server = XMLRPC::Client.new(Sms::SMS_URL, Sms::SMS_PATH)
      begin
        server.call("sms.send", number_bank.shuffle.first, company.cell_phone, message, 1)
      rescue Exception => e
        puts e.backtrace
        puts e.inspect
      end
    else
      puts "Sending SMS to #{company.name}"
      puts message
    end
  end

  def self.test(phone_number, message)
    number_bank = %w(12052674927 12055336910 12055336913 12055336915 12055336909)
    server = XMLRPC::Client.new(Sms::SMS_URL, Sms::SMS_PATH)
    begin
      server.call("sms.send", number_bank.shuffle.first, phone_number, message, 1)
    rescue Exception => e
      puts e.backtrace
      puts e.inspect
    end
  end
end
