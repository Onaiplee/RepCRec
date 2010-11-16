# Site
# Data Manager
# Lock Manager
# Status: live, fail

load 'DM.rb'
load 'LM.rb'
load 'Message.rb'

class Site

  attr_reader :s_id, :status, :failTime

  def initialize (id= "site0")
    @s_id= id
    @status= "live"
    @dm= DM.new(@s_id)
    @lm= LM.new(@s_id, @dm.variableTable)
    @failTime= -1
  end

  def getMessage(messages)
    rms= Array.new
    messages.each do |m|
      rm= processMessage(m)
      rms << rm
    end
    return rms
  end

  def processMessage(message)
    if @status== "fail" then
      rm= message.clone
      rm.result= "fail"
      rm.var= @failTime
    elsif message.type== "read?" then
        rm= message.clone
        r, value= readV(message.t_id, message.v_id, message.var, message.value)
        rm.result= r
        rm.value= value
    elsif message.type== "write?" then
        r, ts= write?(message.t_id, message.v_id)
        rm= message.clone
        rm.result= r
        rm.var= ts
    elsif message.type== "end?" then
        r= end?(message.var)
        rm= message.clone
        rm.result= r
      elsif message.type== "write" then
        writeV(message.t_id, message.v_id, message.value)
        rm= message.clone
    elsif message.type== "abort" then
        abortT(message.t_id)
        rm= message.clone
    elsif message.type== "commit" then
        commitT(message.t_id, message.time)
        rm= message.clone
    end
    return rm
   end


# r: success or blocked
# value: nil or value
  def readV(t_id, v_id, isReadOnly, birth_time)
    if not @dm.isReadTable[v_id]
      return ["fail", nil]
    end
    if isReadOnly then
      value= @dm.readOnly(v_id, birth_time)
      return ["success", value]
    end

     r, ts= @lm.readV(t_id, v_id)
     if r== "blocked"
        return [r, ts]
     end
     value= @dm.readV(v_id)
     ["success", value]
  end

# yes or no
  def write?(t_id, v_id)
    r, ts= @lm.write?(t_id, v_id)
    return [r, ts]
  end

#yes or no
  def end?(time)
    if time > @failTime then
      return "yes"
    else
      return "no"
    end
  end

  def writeV(t_id, v_id, value)
    @lm.writeV(t_id, v_id)
    @dm.writeV(v_id, value)
  end

  def show
    puts "\t#{@s_id}:"
    @dm.variableTable.each do |name, value|
      puts "\t\t#{name}: #{value}"
    end
    @lm.lockTable.each do |v_id, l|
      puts "\t\t lock of #{v_id}: #{l.status}"
    end
  end

  def abortT(t_id)
    vs= @lm.endT(t_id)
    @dm.abortT(vs)
  end

  def commitT(t_id, time)
    vs= @lm.endT(t_id)
    @dm.commitT(vs, time)
  end

  def fail(time)
    @status= "fail"
    @failTime= time
  end

  def recover
    @status= "live"
  end

end