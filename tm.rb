require 'xmlrpc/server'
require 'xmlrpc/client'
require 'pp'
require './Transaction.rb'
require './Configure.rb'
require './Message.rb'

# Transaction Manager
# * Send operations of transactions to sites as requests using the available copy algorithm.
class TM

  # Record the time from the first instruction.
  attr_reader :globalTime
  # TransactionTable(Hash): Transaction ID => Transaction Obj
  attr_reader :transactionTable  
  # VariableTable(Hash): Variable ID => Array of Replicated Sites ID
  attr_reader :variableTable
  # SiteStatusTable(Hash): Site ID => Site Status(live, fail)
  attr_reader :siteStatusTable
  # SiteBuffer(Hash): SiteID => Message(to be sent in the time cycle)
  attr_reader :siteBuffer
  # BlockTable(Hash): Transaction ID => Message(to be sent after unblocked)
  attr_reader :blockTable
  # rpcc(Hash): Site ID => XMLRPC_Client #Part2
  attr_reader :rpcc
  # FailTimeTable(Hash): Site ID => Fail Time # used to check long fail
  attr_reader :failTimeTable
  # LiveSiteNum: Number of live sites => # used to do banlance and rebalance
  attr_reader :liveSiteNum
  # SiteRepTable: Site ID => Replicated Variable for the site
  attr_reader :siteRepTable
  
  # Get configuration information
  def initialize
    @globalTime= 0
    @transactionTable= Hash.new
    # @siteTable= Hash.new
    @variableTable= Hash.new
    @siteBuffer= Hash.new
    @rpcc = Hash.new
    @siteStatusTable= Hash.new
    @liveSiteNum= 0
    @failTimeTable= Hash.new
    @siteRepTable= Hash.new
    c = Configure.new
    c.configTable[:sites].each do |s|
    #  @siteTable[s]= Site.new(s) #part1
      @liveSiteNum += 1
      @siteBuffer[s]= Array.new
      @siteStatusTable[s]= "live"
      @siteRepTable[s]= Array.new 
      ip = c.configTable[s.to_sym][:ip]
      port = c.configTable[s.to_sym][:port]
      @rpcc[s] = XMLRPC::Client.new(ip, "/RPC2", port)
    #  @rpcc[s].call("Site.xxx", argument ... )
    end
    c.configTable[:variables].each do |v|
      @variableTable[v]= c.configTable[v.to_sym][:rep_sites]
      if @variableTable[v].length >1
        @variableTable[v].each do |sid|
          @siteRepTable[sid]<<v
        end
      end
    end
    @blockTable= Hash.new
    @debug = File.new("debug.txt", "w+")
  end

  # RPC calls by UIController
  # * Get operations from UIController
  # * Return result of the operations
  def read(operations)
    @globalTime += 1
    output= "\n  Begin time cycle #{@globalTime}"
    longFail
    operations.each do |op|
      output += process(op)
    end
    output += sendMessage
    output += "\n  End time cycle #{@globalTime}\n\n"
  end

  def process(operation)
    #puts "Line #{@globalTime} is #{operation} \n"
    output = ""
    case operation[0]
      when "begin" then output += beginT(operation[1])
      when "beginRO" then output += beginRO(operation[1])
      when "R"  then readV(operation[1],operation[2])
      when "W"  then writeV(operation[1],operation[2],operation[3])
      when "dump1" then dump
      when "dump2" then dumpSite(operation[1])
      when "dump3" then dumpVar(operation[1])
      when "end"  then endT(operation[1])
      when "fail" then output += failS(operation[1])
      when "recover" then output += recoverS(operation[1])
      when "advance" then advance
      else puts "Error! No such operation: #{operation[0]}"
    end
    return output
  end

  def advance

  end

  def beginT(t_id)
    @transactionTable[t_id]= Transaction.new(t_id, @globalTime)
    return "\n\t Transaction #{t_id} begins"
  end

  def beginRO(t_id)
    @transactionTable[t_id]= Transaction.new(t_id, @globalTime, true)
    return "\n\t ReadOnlyTransaction #{t_id} begins"
  end

  def readV(t_id, v_id)
    s_id= @variableTable[v_id].first.clone
    @siteBuffer[s_id] << Message.new(@globalTime, t_id, "read?", v_id, @transactionTable[t_id].birth_time, s_id, nil, @transactionTable[t_id].isReadOnly)
   end

  def writeV(t_id, v_id, value)
   @variableTable[v_id].each do |s_id|
     puts "in WriteV #{s_id}"
     @siteBuffer[s_id] << Message.new(@globalTime, t_id, "write?", v_id, value, s_id, nil, nil)
   end
  end

  def endT(t_id)
    if @transactionTable[t_id].status == "abort" || @transactionTable[t_id].status == "commit"
      return
    end
    @transactionTable[t_id].accessTable.each do |s_id, time|
      @siteBuffer[s_id] << Message.new(@globalTime, t_id, "end?", nil, nil, s_id, nil, time)
    end
  end

  def abortT(t_id)
    @transactionTable[t_id].abort(@globalTime)
    @transactionTable[t_id].accessTable.each do |s_id, time|
      @siteBuffer[s_id] << Message.new(@globalTime, t_id, "abort", nil, nil, s_id, nil, nil)
    end
  end

  def commitT(t_id)
      @transactionTable[t_id].commit(@globalTime)
      @transactionTable[t_id].accessTable.sort
      @transactionTable[t_id].accessTable.each do |s_id, time|
        @siteBuffer[s_id] << Message.new(@globalTime, t_id, "commit", nil, nil, s_id, nil, nil)
      end
  end

  def dump
    @siteBuffer.each do |s, ms|
      dumpSite(s)
    end
  end

  def dumpSite(s_id)
    @siteBuffer[s_id] << Message.new(@globalTime, nil, "dumpSite", nil, nil, s_id, nil, nil)
  end

  def dumpVar(v_id)
    @siteBuffer.each do |s, ms|
      ms << Message.new(@globalTime, nil, "dumpVar", v_id, nil, s, nil, nil)
    end
  end

  def failS(s_id)
    s = "site#{s_id}"
    @rpcc[s].call_async("Site.fail", @globalTime)
    @failTimeTable[s]= @globalTime
    @liveSiteNum -= 1
    @siteStatusTable[s]= "fail"
    return "\n\t Site#{s_id} fails"
  end

  def recoverS(s_id)
    s = "site#{s_id}"
    @rpcc[s].call_async("Site.recover")
    @liveSiteNum += 1
    recoverRebalance(s)
    @siteStatusTable[s]= "live"
    @failTimeTable.delete_if{|site, time| site == s }
    return "\n\t Site#{s_id} recovers"
  end

  def wait?(t_id, v_id, type, ts)
    ts.each do |t|
      if @transactionTable[t].birth_time <= @transactionTable[t_id].birth_time
         return false
      end
    end
    @blockTable.each do |t, m|
      if m.v_id == v_id
        if m.type == "write?" or type == "write?"
          if @transactionTable[t].birth_time <= @transactionTable[t_id].birth_time
           return false
          end
        end
      end
    end
    return true
  end

  def longFail
    @failTimeTable.each do |s, t|
      if @globalTime == t+3
        failRebalance(s)
      end
    end
    @failTimeTable.delete_if{ |s,t| @globalTime==t+3 }
  end

  def recoverRebalance(s)
    @siteRepTable[s] = []
    avg = 30.0/@liveSiteNum
    min = avg.floor
    loop_max= 0
    @siteRepTable.each do |key, value|
      if value.length > loop_max
        loop_max= value.length
      end
    end
    loop_max.downto(min).each do |i|
      @siteRepTable.each do |key, value|
        if value.length == i and @siteStatusTable[key] == "live" and @siteRepTable[s].length < min
          @siteRepTable[key].reverse.each do |v|
            if not @siteRepTable[s].include?(v)
              @siteRepTable[s]<<v
              @siteRepTable[key].delete(v)
              @variableTable[v]<<s
              @variableTable[v].delete(key)
              @siteBuffer[s]<< Message.new(@globalTime, nil, "addRep", v, nil, s, nil, nil)
              @siteBuffer[key]<< Message.new(@globalTime, nil, "rmRep", v, nil, key, nil, nil)
              break
            end
          end
        end
      end
    end
  end

  def failRebalance(s)
    avg = 30.0/@liveSiteNum
    max = avg.ceil
    loop_min = 20
    @siteRepTable.each do |key, value|
      if value.length < loop_min and @siteStatusTable[key] == "live"
        loop_min = value.length
      end
    end
    @siteRepTable[s].each do |v|
      @variableTable[v].delete(s)
    end
    loop_min.upto(max).each do |i|
      @siteRepTable[s].each do |var|
        @siteRepTable.each do |key, value|
          if value.length == i and @siteStatusTable[key] == "live" and value.length < max and not value.include?(var) and @variableTable[var].length < 3
            @siteRepTable[key]<<var
            @variableTable[var]<<key
            @siteBuffer[key].unshift(Message.new(@globalTime, nil, "addRep", var, nil, key, nil, nil))
            break
          end
        end
      end
    end
    pp @variableTable
  end

  def sendMessage
    output = ""
    #longFail
    @blockTable.each do |t_id, message|
      if message.type== "read?"
        message.time = @globalTime
        readV(message.t_id, message.v_id)
      end
      if message.type== "write?"
        message.time = @globalTime
        writeV(message.t_id, message.v_id, message.value)
      end
    end
    @blockTable.clear
    @siteBuffer.each do |s_id, messages|
      if not messages.empty?
        messagesStringArray = []
        messages.each do |m|
          @debug.puts "#{s_id} #{m.time} #{m.t_id} #{m.type} #{m.v_id} #{m.value} #{m.var} #{m.s_id}"
          messageArray = [m.time, m.t_id, m.type, m.v_id, m.value, m.s_id, m.result, m.var]
          messagesStringArray << messageArray.to_s
        end
        puts "Sent Messages"
        pp messagesStringArray
        rmsStringArray = @rpcc[s_id].call_async("Site.getMessage", messagesStringArray)
        puts "Return Messages"
        pp rmsStringArray
        rms = []
        rmsStringArray.each { |s| rms << Message.new(*eval(s)) }
        rms.each do |rm|
          @debug.puts "return: #{rm.time} #{rm.t_id} #{rm.type} #{rm.v_id} #{rm.value} #{rm.result} #{rm.s_id}"
          if rm.type== "read?" 
            if rm.result== "fail" 
              i= @variableTable[rm.v_id].index(s_id)
              if i== @variableTable[rm.v_id].length-1 
                m= rm.clone
                m.result= nil
                @blockTable[rm.t_id]= m
                output += "\n\t Transaction #{m.t_id} is blocked on #{m.type} #{m.v_id}"
              else
                i += 1
                new_s= @variableTable[rm.v_id][i].clone
                m= rm.clone
                m.result= nil
                @siteBuffer[new_s] << m
              end
            elsif rm.result== "blocked"
                  if wait?(rm.t_id, rm.v_id, rm.type, rm.value)
                      m= rm.clone
                      m.result= nil
                      @blockTable[rm.t_id]= m
                      output += "\n\t Transaction #{m.t_id} is blocked on #{m.type} #{m.v_id}"
                  else
                    abortT(rm.t_id)
                    @variableTable[rm.v_id].each do |s|
                      @siteBuffer[s].delete_if{|x| x.t_id== rm.t_id and x.type== rm.type and x.v_id== rm.v_id}
                    end
                    output += "\n\t Transaction #{rm.t_id} aborts"
                  end

            elsif rm.result== "success" 
              @transactionTable[rm.t_id].readV(rm.v_id, rm.value, s_id, rm.time)
              output += "\n\t Transaction #{rm.t_id} reads from #{rm.v_id} #{rm.value}"
            else
            end
            messages.delete_if{ |x| x.t_id== rm.t_id and x.type== rm.type and x.v_id== rm.v_id}
          elsif rm.type== "write?" 
            if rm.result== "no"
              if wait?(rm.t_id, rm.v_id, rm.type, rm.var) 
                m= rm.clone
                m.result= nil
                @blockTable[rm.t_id]= m
                @variableTable[rm.v_id].each do |s|
                  @siteBuffer[s].delete_if{|x| x.t_id== rm.t_id and x.type== rm.type and x.v_id== rm.v_id}
                end
                output += "\n\t Transaction #{m.t_id} is blocked on #{m.type} #{m.v_id}"
              else
                  abortT(rm.t_id)
                  @variableTable[rm.v_id].each do |s|
                    @siteBuffer[s].delete_if{|x| x.t_id== rm.t_id and x.type== rm.type and x.v_id== rm.v_id}
                  end
                  output += "\n\t Transaction #{rm.t_id} aborts"
              end
            elsif @variableTable[rm.v_id].index(s_id)== @variableTable[rm.v_id].length - 1
              if rm.result== "yes" 
                @variableTable[rm.v_id].each do |s|
                  m= rm.clone
                  m.result= nil
                  m.type= "write"
                  m.s_id= s
                  @siteBuffer[s] << m
                  @transactionTable[rm.t_id].writeV(rm.v_id, rm.value, s, rm.time)
                end
                output += "\n\t Transaction #{rm.t_id} writes to #{rm.v_id} #{rm.value}"
              elsif rm.result== "fail"
                totalFail= true
                @variableTable[rm.v_id].each do |s|
                  @siteBuffer[s].each do |x|
                    if rm.t_id==x.t_id and rm.v_id==x.v_id and rm.type== x.type
                      if rm.result== "yes"
                        totalFail= false
                      end
                    end
                  end
                end
                if totalFail
                  m= rm.clone
                  m.result= nil
                  if wait?(m.t_id, m.v_id, m.type, rm.var)
                      @blockTable[rm_tid]= m
                      output += "\n\t Transaction #{m.t_id} is blocked on #{m.type} #{m.v_id}"
                  else
                    abortT(rm.t_id)
                    @variableTable[rm.v_id].each do |s|
                      @siteBuffer[s].delete_if{|x| x.t_id== rm.t_id and x.type== rm.type and x.v_id== rm.v_id}
                    end
                    output += "\n\t Transaction #{m.t_id} aborts"
                  end
                else
                  m= rm.clone
                  m.result= nil
                  m.type= "write"
                  @variableTable[rm.v_id].each do |s|
                    m.s_id = s
                    @siteBuffer[s] << m
                  end
                  @transactionTable[rm.t_id].writeV(rm.v_id, rm.value, s, rm.time)
                  output += "\n\t Transaction #{m.t_id} writes to #{m.v_id} #{m.value}"
                end
              else
              end
              @variableTable[rm.v_id].each do |s|
                 @siteBuffer[s].delete_if{|x| x.t_id== rm.t_id and x.type== rm.type and x.v_id== rm.v_id}
              end
            else
            end
          elsif rm.type== "end?"
             if rm.result== "no"
               abortT(rm.t_id)
               @transactionTable[rm.t_id].accessTable.each do |s, time|
                  @siteBuffer[s].delete_if{|x| x.t_id== rm.t_id and x.type== rm.type}
               end
               output += "\n\t Transaction #{rm.t_id} aborts"
             elsif rm.result== "fail" and rm.var > @transactionTable[rm.t_id].accessTable[s_id]
               abortT(rm.t_id)
               @transactionTable[rm.t_id].accessTable.each do |s, time|
                  @siteBuffer[s].delete_if{|x| x.t_id== rm.t_id and x.type== rm.type}
               end
               output += "\n\t Transaction #{rm.t_id} aborts"
             elsif @transactionTable[rm.t_id].accessTable.keys.index(s_id)== @transactionTable[rm.t_id].accessTable.length - 1
                commitT(rm.t_id)
                @transactionTable[rm.t_id].accessTable.each do |s, time|
                  @siteBuffer[s].delete_if{|x| x.t_id== rm.t_id and x.type== rm.type}
                end
                output += "\n\t Transaction #{rm.t_id} commits"
             else
             end
          elsif rm.type== "dumpSite"
              result = rm.var
              output += "\n\t Dump #{rm.s_id}: "
              pp result
              result.each do |v_id, vs|
                output += "\n\t\t #{v_id}:"
                vs.each do |value|
                  output += " #{value}"
                end
              end
              @siteBuffer[s_id].delete_if{|x| x.s_id == rm.s_id and x.type== rm.type}
          elsif rm.type== "dumpVar" 
             result = rm.var
             output += "\n\t\t Dump #{rm.v_id} on #{rm.s_id}: "
             result.each do |value|
              output += " #{value}"
             end
             @siteBuffer[s_id].delete_if{|x| x.s_id== rm.s_id and x.type== rm.type}
          elsif rm.type== "write" or rm.type== "abort" or rm.type== "commit" then
              @siteBuffer[s_id].delete_if{|x| x.t_id== rm.t_id and x.type== rm.type}
          elsif rm.type== "addRep" or rm.type== "rmRep"
             @siteBuffer[s_id].delete_if{|x| x.s_id== rm.s_id and x.type== rm.type}
          else
          end
        end
      end
    end
    @debug.puts " "
    return output
  end

  def returnMessage(rms)
  end



end

if $0 == __FILE__
  s = XMLRPC::Server.new(20000)
  s.add_handler("TransactionManager", TM.new)
  s.serve
end
