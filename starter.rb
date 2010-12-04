require './Site.rb'
require './Configure.rb'

class Starter
  def initialize
    c = Configure.new
    c.configTable[:sites].each do |s|
      ip = c.configTable[s.to_sym][:ip]
      port = c.configTable[s.to_sym][:port]
      SiteHelper.new(s, port)
    end
  end
end


if $0 == __FILE__
  s = Starter.new
end
