module Snailmail::Mocks

  def user_no_uses
    @user_no_uses ||= User.create({
        :name          => "Paul Bergeron",
        :address_line1 => "1999 Foo St.",
        :city          => "San Francisco",
        :state         => "CA",
        :zip           => "94103",
        :short_code    => "1001",
      })
  end

  def user_no_recipients
    if @user_no_recipients.nil?
      @user_no_recipients = User.create({
          :name          => "Paul Bergeron",
          :address_line1 => "1999 Foo St.",
          :city          => "San Francisco",
          :state         => "CA",
          :zip           => "94103",
          :short_code    => "1002",
        })
      @user_no_recipients.incr(:uses_remaining, 10)
    end
    @user_no_recipients
  end

  def user_with_recipient
    if @user_with_recipient.nil?
      @user_with_recipient = User.create({
          :name          => "Paul Bergeron",
          :address_line1 => "1999 Foo St.",
          :city          => "San Francisco",
          :state         => "CA",
          :zip           => "94103",
          :short_code    => "1003",
        })
      @user_with_recipient.incr(:uses_remaining, 10)

      @recipient ||= Recipient.create({
          :name          => "Hedi",
          :address_line1 => "1998 Foo St.",
          :city          => "San Francisco",
          :state         => "CA",
          :zip           => "94103",
          :short_code    => "1000",
          :user          => @user_with_recipient
        })
    end

    @user_with_recipient
  end

  def recipient
    @recipient ||= user_with_recipient.recipients.first
  end
end
