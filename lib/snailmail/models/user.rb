class User < Ohm::Model
  attribute :name
  attribute :short_code
  unique :short_code

  attribute :address_line1
  attribute :address_line2
  attribute :city
  attribute :state
  attribute :zip
  attribute :country

  collection :recipients, :Recipient

  def name_and_address
    self.address.merge(name: self.name)
  end
end
