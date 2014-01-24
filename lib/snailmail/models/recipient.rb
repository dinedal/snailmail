class Recipient < Ohm::Model
  attribute :name
  attribute :short_code
  unique :short_code

  attribute :address_line1
  attribute :address_line2
  attribute :city
  attribute :state
  attribute :zip
  attribute :country

  reference :user, :User

  def assign_address(address_hash)
    address_hash.each do |k,v|
      self.__send__(:"#{k}=", v)
    end
  end

  def address_to_hash
    self.attributes.select{|k,_| Snailmail::LobIntegration::ADDRESS_KEYS.include?(k) }
  end
end
