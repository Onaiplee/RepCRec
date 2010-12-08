require './Lock.rb'
require 'pp'

# Lock Manager: Used to maintain locks for the whole site
class LM

###### Variables
  # The site ID for this LM
  attr_reader :s_id
  
  # Lock Table: Variable ID => lock
  attr_reader :lockTable

###### Methods

  def initialize(s_id, variableTable)
    @s_id= s_id
    @lockTable= Hash.new
    variableTable.each do |v_id, value|
      @lockTable[v_id]= Lock.new(@v_id)
    end
  end

  # Assign a new lock for new variable
  def addRep(v_id)
    @lockTable[v_id]=Lock.new(@v_id)
  end
  
  # Remove variable and its lock
  def rmRep(v_id)
    @lockTable.delete(v_id)
  end

  # Return whether the transaction can read (success or blocked)
  # * sucess: assign a read lock to the transaction
  # * blocked: return the ids of the transactions it is waiting for
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

  # Return whether the transaction can write (yes or no)
  # * yes: return nil value
  # * no: return the ids of the transaction it is waiting for
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

  # Assign the write lock to the transacion 
  def writeV(t_id, v_id)
    @lockTable[v_id].lock("write", t_id)
  end

  # * Remove all the locks for the transaction
  # * Return the ids of all the variables which have write locks for the transactions
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