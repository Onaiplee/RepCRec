#!/usr/bin/env ruby

require './tm.rb'
require './Site.rb'
require './Configure.rb'
require 'xmlrpc/server'

class Starter
  def initialize
    @pidTable = Array.new
    c = Configure.new
    c.configTable[:sites].each do |s|
      ip = c.configTable[s.to_sym][:ip]
      port = c.configTable[s.to_sym][:port]
      pid = fork
      if (pid)
        @pidTable << pid
      else
        server = XMLRPC::Server.new(port, "127.0.0.1", 20)
        server.add_handler("Site", Site.new(s, port))
        server.serve
        exit
      end
    end
    if ARGV[0] =~ /--with_tm/
      pid = fork
      if (pid)
        @pidTable << pid
      else
        tm = XMLRPC::Server.new(20000)
        tm.add_handler("TransactionManager", TM.new)
        tm.serve
        exit
      end
    end
    while true
      trap ("INT") {
        @pidTable.each do |p| 
          Process.kill(9, p) 
        end
        exit
      }
    end
  end
end


if $0 == __FILE__
    s = Starter.new
end
