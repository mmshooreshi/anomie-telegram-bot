class String
  def connect_persian_letters
    PersianConnector.transform(self)
  end
end
