# Lock Manager
# LockTable: variableID => lock

load 'Lock.rb'

class LM

  attr_reader :lockTable

  def initialize(s_id, variableTable)
    @s_id= s_id
    @lockTable= Hash.new
    variableTable.each do |v_id, value|
      @lockTable[v_id]= Lock.new(@v_id)
    end
  end

  #sucess:
  #fail:
  def readV(t_id, v_id)
    if @lockTable[v_id].status== "null" or @lockTable[v_id].status== "read"
      @lockTable[v_id].lock("read", t_id)
      return "success"
    end
    if @lockTable[v_id].ownerTable[t_id]== "write"
      return "success"
    end
    ["blocked", @lockTable[v_id].ownerTable.keys]
  end

  #yes or no
  def write?(t_id, v_id)
    if @lockTable[v_id].status== "null" then
      return ["yes", nil]
    elsif @lockTable[v_id].status== "read" then
      if @lockTable[v_id].ownerTable.length > 1 then
        return ["no", @lockTable[v_id].ownerTable.keys]
      elsif @lockTable[v_id].ownerTable[t_id]== "read" then
        return ["yes", nil]
      else
        return ["no", @lockTable[v_id].ownerTable.keys]
      end
    elsif @lockTable[v_id].status== "write" then
        if @lockTable[v_id].ownerTable[t_id]== "write" then
          return ["yes", nil]
        else
          return ["no", @lockTable[v_id].ownerTable.keys]
        end
    end
  end

  def writeV(t_id, v_id)
    @lockTable[v_id].lock("write", t_id)
  end

  def endT(t_id)
    vs= Array.new
    @lockTable.each do |v_id, l|
      r= l.unlock(t_id)
      if r== "write"
        vs << v_id
      end
    end
    return vs
  end

end