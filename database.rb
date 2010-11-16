require "pstore"
require 'pp'

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
