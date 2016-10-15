class Athana
  API_KEY = "dZ1IQbQI99D5KAdVxfnojPzV4T1RiCzvdnaQ4WFDFmBRTX9RrZcij15GFoVQsG64"
  API_SECRET = "VNK4EgggWhiXsxT21pU60kdwjVV29DFKrUYgiuLuLCvP72gR3t9w83SRwlIPvjKz"
  API_URL = "https://uscoachwaysonline.com/xml_server.php"

  # <application>apis</application>
  # <package>subout</package>
  # <controller>integration</controller>
  # <action>subout_award_job</action>
  # <key>xx233QSBXIabGfpo</key>
  # <timestamp>1337325750</timestamp>
  # <hash>
  # c5b8cf50bb2f6e2d1601272e19c0847603aaa737f2ef51df417b49cdff9d516f
  # </hash>

  def self.prepare_request(xml)
    xml.tag! 'application', "apis"
    xml.tag! 'package', "subout"
    xml.tag! 'controller', "integration"
    xml.tag! 'key', API_KEY
    timestamp = Time.now.to_i
    hash  = Digest::SHA256.hexdigest("#{timestamp}#{API_SECRET}")
    xml.tag! 'timestamp', timestamp
    xml.tag! 'hash', hash
    xml
  end

  # <request>
  #   <application>apis</application>
  #   <package>subout</package>
  #   <controller>integration</controller>
  #   <action>subout_get_vendor_by_reference</action>
  #   <key>xx233QSBXIabGfpo</key>
  #   <timestamp>1337325750</timestamp>
  #   <hash>
  #   c5b8cf50bb2f6e2d1601272e19c0847603aaa737f2ef51df417b49cdff9d516f
  #   </hash>
  #   <arguments>
  #     <subout_vendor_id type="string">XXXXXXXX</subout_vendor_id>
  #   </arguments>
  # </request>

  def self.get_vendor_by_reference
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.request do
      prepare_request(xml)
      xml.tag! 'action', "subout_get_vendor_by_reference"
      xml.arguments do
        xml.subout_vendor_id offer.vendor.id, :type=>"string"
      end
    end

    uri = URI(API_URL)
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      @xml = xml.target!
      @response = http.post(uri, @xml, initheader = {'Content-Type' =>'text/xml'})
    end
  end


  # <request>
  #   <application>apis</application>
  #   <package>subout</package>
  #   <controller>integration</controller>
  #   <key>xx233QSBXIabGfpo</key>
  #   <timestamp>1337325750</timestamp>
  #   <hash>
  #   c5b8cf50bb2f6e2d1601272e19c0847603aaa737f2ef51df417b49cdff9d516f
  #   </hash>
  #   <action>subout_get_vendors</action>
  # </request>

  def self.get_vendors
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.request do
      prepare_request(xml)
      xml.tag! 'action', "subout_get_vendors"
    end

    uri = URI(API_URL)

    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      @xml = xml.target!
      @response = http.post(uri, @xml, initheader = {'Content-Type' =>'text/xml'})
      @doc = Nokogiri::XML(@response.body)
      vendors = @doc.xpath("//vendor")
      @doc_vendors = Nokogiri::Slop("<vendors>#{vendors.to_xml}</vendors>")
      # @doc_vendors.vendors.vendor.first.vendor_id.content
    end

    vendors = @doc_vendors.vendors.vendor.map do |vendor|
      { 
        vendor_id: vendor.vendor_id.content,
        vendor_email: vendor.vendor_email.content,
        vendor_name: vendor.vendor_name.content,
        vendor_city: vendor.vendor_city.content,
        vendor_state: vendor.vendor_state.content 
      }
    end
    return vendors
  end

  # <request>
  #   <application>apis</application>
  #   <package>subout</package>
  #   <controller>integration</controller>
  #   <action>subout_award_job</action>
  #   <key>xx233QSBXIabGfpo</key>
  #   <timestamp>1337325750</timestamp>
  #   <hash>
  #   c5b8cf50bb2f6e2d1601272e19c0847603aaa737f2ef51df417b49cdff9d516f
  #   </hash>
  #   <arguments>
  #     <subout_opp_ref_num type="string">XXXXXXXX</subout_opp_ref_num>
  #     <amount type="float">100.00</amount>
  #     <subout_vendor_id type="string">XXXXXXXX</subout_vendor_id>
  #     OR
  #     <vendor_email type="string">X@XXXX.XXX</vendor_email>
  #     <vehicle type="string">Vehicle type</vehicle>
  #   </arguments>
  # </request>


  def self.award_job(offer_id)
    offer = Offer.find(offer_id)
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.request do
      prepare_request(xml)
      xml.tag! 'action', "subout_award_job"
      xml.arguments do
        xml.subout_opp_ref_num offer.opportunity.reference_number, :type=>"string"
        xml.subout_opp_ref_num offer.amount, :type=>"float"
        xml.vendor_email offer.vendor.email, :type=>"string"
        xml.vehicle offer.vehicle_type, :type=>"string"
      end
    end

    uri = URI(API_URL)
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      @xml = xml.target!
      @response = http.post(uri, @xml, initheader = {'Content-Type' =>'text/xml'})
    end
  end

  # <request>
  #   <application>apis</application>
  #   <package>subout</package>
  #   <controller>integration</controller>
  #   <action>subout_confirm_job</action>
  #   <key>xx233QSBXIabGfpo</key>
  #   <timestamp>1337325750</timestamp>
  #   <hash>
  #   c5b8cf50bb2f6e2d1601272e19c0847603aaa737f2ef51df417b49cdff9d516f
  #   </hash>
  #   <arguments>
  #     <subout_opp_ref_num type="string">XXXXXXXX</subout_opp_ref_num>
  #   </arguments>
  # </request>

  def self.confirm_job(offer_id)
    offer = Offer.find(offer_id)
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.request do
      prepare_request(xml)
      xml.tag! 'action', "subout_confirm_job"
      xml.arguments do
        xml.subout_opp_ref_num offer.opportunity.reference_number, :type=>"string"
      end
    end

    uri = URI(API_URL)
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      @xml = xml.target!
      @response = http.post(uri, @xml, initheader = {'Content-Type' =>'text/xml'})
    end
  end

  # <request>
  #   <application>apis</application>
  #   <package>subout</package>
  #   <controller>integration</controller>
  #   <action>subout_cancel_job</action>
  #   <key>xx233QSBXIabGfpo</key>
  #   <timestamp>1337325750</timestamp>
  #   <hash>
  #   c5b8cf50bb2f6e2d1601272e19c0847603aaa737f2ef51df417b49cdff9d516f
  #   </hash>
  #   <arguments>
  #     <subout_opp_ref_num type="string">XXXXXXXX</subout_opp_ref_num>
  #   </arguments>
  # </request>

  def self.cancel_job(offer_id)
    offer = Offer.find(offer_id)
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.request do
      prepare_request(xml)
      xml.tag! 'action', "subout_cancel_job"
      xml.arguments do
        xml.subout_opp_ref_num offer.opportunity.reference_number, :type=>"string"
      end
    end

    uri = URI(API_URL)
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      @xml = xml.target!
      @response = http.post(uri, @xml, initheader = {'Content-Type' =>'text/xml'})
    end
  end


end