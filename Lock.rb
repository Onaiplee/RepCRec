# This class is used as a lock for each variable
class Lock

###### Variables

  # The variable which binds this lock
  attr_reader :v_id

  # Status: read, write, null
  attr_reader :status
  
  # ownerTable(Hash): Transaction ID => Lock Type(read, write, null)
  attr_reader :ownerTable
  
###### Methods
  
  def initialize(v_id)
    @v_id= v_id
    @status= "null"
    @ownerTable= Hash.new
  end

  # Assign the lock to the transaction
  def lock(type, t_id)
    @ownerTable[t_id]= type
    @status= type
  end

  # Remove the lock from the transaction and return the lock type  
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