class Snailmail::LobIntegration

  ADDRESS_KEYS = %i.address_line1 address_line2 city state zip.

  def initialize
    @lob = Lob(api_key: Snailmail::LOB_APIKEY)
  end

  def can_mail_to?(address)
    @lob.addresses.verify(
      address.select {|k,_| ADDRESS_KEYS.include?(k)}\
      )
  end
end
