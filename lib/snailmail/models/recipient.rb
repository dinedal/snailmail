class Recipient < Ohm::Model
  ##
  # Attributes
  #

  attribute :name
  attribute :short_code
  unique :short_code
  attribute :address_line1
  attribute :address_line2
  attribute :city
  attribute :state
  attribute :zip
  attribute :country

  ##
  # Relations
  #

  reference :user, :User

  ##
  # Validations
  #

  def validate
    assert_present :name
    assert_present :short_code
    assert_present :address_line1
    assert_present :city
    assert_present :state
    assert_present :zip
    assert_present :user

    assert_format  :short_code, /[0-9]+/

    assert Snailmail::LobIntegration.verify(address_to_hash), :invalid_address
  end

  def assign_address(address_hash)
    address_hash.each do |k,v|
      self.__send__(:"#{k}=", v)
    end
  end

  def address_to_hash
    self.attributes.select{|k,_| Snailmail::LobIntegration::ADDRESS_KEYS.include?(k) }
  end
end
