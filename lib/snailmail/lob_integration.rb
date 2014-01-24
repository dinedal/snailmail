class Snailmail::LobIntegration

  ADDRESS_KEYMAP = {
    "address_line1"   => :address_line1,
    "address_line2"   => :address_line2,
    "address_city"    => :city,
    "address_state"   => :state,
    "address_zip"     => :zip,
    "address_country" => :country,
    "name"            => :name,
  }

  ADDRESS_KEYS = ADDRESS_KEYMAP.values

  def initialize
    @lob = Lob(api_key: Snailmail::LOB_APIKEY)
  end

  def verify(address)
    name = address[:name]
    verified_address = cleanup_verified_address @lob.addresses.verify(
      address.select {|k,_| ADDRESS_KEYS.include?(k)}\
    )
    verified_address.merge!(name: name)
  end

  def mail_postcard(to_address, from_address, front, message)

    to = verify(to_address)
    from = verify(from_address)

    @lob.postcards.create(
      to: to,
      from: from,
      front: front,
      message: message,
    )
  end

  private
  def cleanup_verified_address(address)
    clean_address = {}

    address["address"].each do |k,v|
      if ADDRESS_KEYMAP[k]
        clean_address[ADDRESS_KEYMAP[k]] = v
      end
    end

    clean_address
  end
end
