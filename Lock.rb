# Lock for variables
# Status: read, write, null
# v_id
# OwnerTable: TransactionID => LockType(Status)

class Lock

  attr_reader :status, :ownerTable

  def initialize(v_id)
    @v_id= v_id
    @status= "null"
    @ownerTable= Hash.new
  end

  def lock(type, t_id)
    @ownerTable[t_id]= type
    @status= type
  end

  def unlock(t_id)
    type= @ownerTable[t_id]
    @ownerTable.delete(t_id)
    if type== "write" or type== "read"
      if @ownerTable.empty?
        @status= "null"
      else
        @status= "read"
      end
    end
    type
  end

end