require './Site.rb'
require './Configure.rb'

class Starter
  def initialize
    @pidTable = Hash.new
    c = Configure.new
    c.configTable[:sites].each do |s|
      ip = c.configTable[s.to_sym][:ip]
      port = c.configTable[s.to_sym][:port]
      pid = fork
      if (pid)
        @pidTable[s.to_sym] = pid
      else
        SiteHelper.new(s, port)
      end
    end


  end
  def run
    while true
      trap ("INT") {
        @pidTable.each { |k,v| Process.kill(9, v) }
        exit
      }
    end
  end
end


if $0 == __FILE__
  s = Starter.new
  s.run
end
