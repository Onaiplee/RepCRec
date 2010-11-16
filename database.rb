require "pstore"

class Database
  def initialize(storeFile = "database.dat")
    @filename = storeFile
    @store ||= PStore.new(storeFile)
  end

  def write(var, val)
    @store.transaction do
      @store[var] = val
    end
  end

  def read(var)
    @store.transaction do
      @store[var]
    end
  end
end


if $0 == __FILE__
  d = Database.new
  d.write("x3", 7)
  puts d.read("x3")
end
