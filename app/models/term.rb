require 'open-uri'
class Term
  include Mongoid::Document
  include Mongoid::Timestamps

  mount_uploader :pdf, PdfUploader

  field :pdf
  field :template_id

  def file_name
    File.basename(self.pdf.url)
  end

  def create_docsign_template
    client = DocusignRest::Client.new
    @template_response = client.create_template(
      description: 'Subout Terms And Conditions',
      name: self.file_name,
      signers: [
        {
          embedded: true,
          name: 'xing',
          email: 'chollimee@gmail.com',
          role_name: 'User',
          sign_here_tabs: [
            {
              anchor_x_offset: '140',
              anchor_y_offset: '8'
            }
          ]
        }
      ],
      files: [
        {io: open(self.pdf.url), name: self.file_name}
      ]
    )
    self.template_id = @template_response["templateId"]
    self.save
  end

  def create_docsign_envelop
    client = DocusignRest::Client.new
    @envelope_response = client.create_envelope_from_template(
      status: 'sent',
      email: {
        subject: "Subout Terms And Conditions",
        body: "Please sign subout terms and conditions to use suboutapp.com"
      },
      template_id: self.template_id,
      signers: [
        {
          embedded: true,
          name: 'chollimee',
          email: 'chollimee@gmail.com',
          role_name: 'User'
        }
      ]
    )
  end
  
  def self.signers
    Company.all.map do |c|
      {
        embedded: true,
        name: c.name,
        email: c.email,
        role_name: 'User',
        sign_here_tabs: [
          {
            anchor_x_offset: '140',
            anchor_y_offset: '8'
          }
        ]
      }
    end
  end
end
