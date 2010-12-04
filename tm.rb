#Transaction Manager

#Translate read and write requests on variables to read and write requests on copies using the available copy algorithm.
#TransactionTable: Transaction ID => Transaction Obj
#SiteTable: Site ID => Site Obj
#VariableTable: Variable ID => Array of Replicated Sites ID
#BlockTable: TransactionID =>  BlockedOperation
#SiteBuffer: SiteID => Message
require "xmlrpc/server"
require 'pp'
load 'Transaction.rb'
load 'Site.rb'
load 'Configure.rb'
load 'Message.rb'

class TM

  def initialize
    @globalTime= 0
    @transactionTable= Hash.new
    @siteTable= Hash.new
    @variableTable= Hash.new
    @siteBuffer= Hash.new
    c= Configure.new
    c.configTable[:sites].each do |s|
      @siteTable[s]= Site.new(s)
      @siteBuffer[s]= Array.new
    end
    c.configTable[:variables].each do |v|
      @variableTable[v]= c.configTable[v.to_sym][:rep_sites]
    end
    @blockTable= Hash.new
    @debug = File.new("debug.txt", "w+")
  end

  def read(operations)
    @globalTime += 1
    output= "\n  Begin time cycle #{@globalTime}"
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
  end

  def dumpSite(s_id)
  end

  def dumpVar(v_id)
  end

  def failS(s_id)
    s = "site#{s_id}"
    @siteTable[s].fail(@globalTime)
    return "\n\t Site#{s_id} fails"
  end

  def recoverS(s_id)
    s = "site#{s_id}"
    @siteTable[s].recover
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


  def sendMessage
    output = ""
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
        messages.each do |m|
          @debug.puts "#{s_id} #{m.time} #{m.t_id} #{m.type} #{m.v_id} #{m.value} #{m.var} #{m.s_id}"
        end
        rms= @siteTable[s_id].getMessage(messages)
        rms.each do |rm|
          @debug.puts "return: #{rm.time} #{rm.t_id} #{rm.type} #{rm.v_id} #{rm.value} #{rm.result} #{rm.s_id}"
          if rm.type== "read?" then
            if rm.result== "fail" then
              i= @variableTable[rm.v_id].index(s_id)
              if i== @variableTable[rm.v_id].length-1 then
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
            elsif rm.result== "blocked" then
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

            elsif rm.result== "success" then
              @transactionTable[rm.t_id].readV(rm.v_id, rm.value, s_id, rm.time)
              output += "\n\t Transaction #{rm.t_id} reads from #{rm.v_id} #{rm.value}"
            end
            messages.delete_if{ |x| x.t_id== rm.t_id and x.type== rm.type and x.v_id== rm.v_id}
          elsif rm.type== "write?" then
            if rm.result== "no"
              if wait?(rm.t_id, rm.v_id, rm.type, rm.var) then
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
              if rm.result== "yes" then
                @variableTable[rm.v_id].each do |s|
                  m= rm.clone
                  m.result= nil
                  m.type= "write"
                  m.s_id= s
                  @siteBuffer[s] << m
                  @transactionTable[rm.t_id].writeV(rm.v_id, rm.value, s, rm.time)
                end
                output += "\n\t Transaction #{rm.t_id} writes to #{rm.v_id} #{rm.value}"
              elsif rm.result== "fail" then
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
                end
              @variableTable[rm.v_id].each do |s|
                 @siteBuffer[s].delete_if{|x| x.t_id== rm.t_id and x.type== rm.type and x.v_id== rm.v_id}
              end
            end
          elsif rm.type== "end?" then
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
             end
           elsif rm.type== "write" or rm.type== "abort" or rm.type== "commit" then
              @siteBuffer[s_id].delete_if{|x| x.t_id== rm.t_id and x.type== rm.type}
           end
        end
      end
    end
    @debug.puts " "
    return output
  end

end

if $0 == __FILE__
  s = XMLRPC::Server.new(20000)
  s.add_handler("TransactionManager", TM.new)
  s.serve
end
