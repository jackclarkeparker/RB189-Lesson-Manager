require_relative "escapable"

class Venue
  include Escapable
  PAGINATION_SIZE = 5

  attr_reader :id, :name, :address

  def initialize(id, name, address)
    @id = id.to_i
    @name = name.strip
    @address = address.strip
  end

  def ==(other_venue)
    self.id == other_venue.id &&
    self.name == other_venue.name &&
    self.address == other_venue.address
  end

  def to_s
    h self.name
  end
end
