class Money
  class << self

    # Get the object as it was stored in the database, and instantiate
    # this custom class from it.
    def demongoize(object)
      object ? (::BigDecimal.new(object.to_s) / 100) : object
    end

    # Takes any possible object and converts it to how it would be
    # stored in the database.
    def mongoize(object)
      object ? ((object.is_a?(::BigDecimal) ? object : ::BigDecimal.new(object.to_s)).round(2) * 100).to_i : object
    end

    # Converts the object that was supplied to a criteria and converts it
    # into a database friendly form.
    def evolve(object)
      mongoize(object)
    end
  end
end
