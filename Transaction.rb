#Transaction
#State: running, blocked, commited, aborted
#AccessTable: SiteID => First Access Time

class Transaction

  attr_reader :id, :birth_time, :status, :isReadOnly, :accessTable, :accessVariableTable

  def initialize(id, birth_time, isReadOnly=false)
    @id= id
    @birth_time= birth_time
    @status= "running"
    @isReadOnly= isReadOnly
    @operationList= Array.new
    @accessTable= Hash.new
    @accessVariableTable= Hash.new
  end

  def readV(v_id, value, s_id, time)
    @operationList << ["read", v_id, value, s_id, time]
    if not @accessVariableTable.include?(s_id)
      @accessVariableTable[s_id] = Array.new
    end
    @accessVariableTable[s_id] << v_id
    if not @accessTable.has_key?(s_id) then
      @accessTable[s_id]= time
    end
  end

  def writeV(v_id, value, s_id, time)
    @operationList << ["write", v_id, value, s_id, time]
    if not @accessVariableTable.include?(s_id)
      @accessVariableTable[s_id] = Array.new
    end
    @accessVariableTable[s_id] << v_id
    if not @accessTable.has_key?(s_id) then
        @accessTable[s_id]= time
    end
  end

  def abort(time)
    @status= "abort"
    @operationList << ["abort", time]
  end

  def commit(time)
    @status= "commit"
    @operationList << ["commit", time]
  end

end
