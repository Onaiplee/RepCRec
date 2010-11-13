########  This is a advance database project #########
########  Transaction manager                #########


class SortedList
  def initialize
    @data = []
  end

  def <<(element)
    (@data << element).sort! {|m,n| n.length <=> m.length}
  end

  def empty?
    @data.empty?
  end
end

class LockWaitList < SortedList
  def initialize
    super
  end

  def <<(transaction)
    (@data << transaction).sort! {|m,n| n.birth_time <=> m.birth_time}
  end
  
  def oldest
    @data[-1]
  end
  
  def youngest
    @data[0]
  end
end

class Transaction
  
end

class Lock
  def initialize(lock_id)
    @lock_id = lock_id
    @state = :idle
    @owner = SortedList.new()
    @waiters = {}
    @wait_read_transactions = SortedList.new()
    @wait_write_transactions = SortedList.new()
  end

  def acqire_read(transaction)
    if owner.include? transaction
      transaction.do_pending_action()
      return
    end
    
    if @state == :idle
      @state = :read
      @owner << transaction 
    elsif @state == :read
      @owner << transaction
      unless @wait_write_transactions.empty?
        unless @wait_write_transactions.oldest.older_than?(transaction)
          losers = @wait_write_transactions
          @wait_write_transactions = []
          loser.each
      
      if @wait_write_transactions.not_empty?
        if 
    

class Transaction
  def initialize(id, birth_time, action_abort, is_readonly=False)
    @id = id
    @birth_time = birth_time
    @state = 'normal'
    @pending_action = nil
    @result_message = ""
    @locks = []
    @waiting_lock = nil
    @action_abort = action_abort
    @variables_visited = []
    @site_visited = []
    @wait_var = nil
  end
  
  def do_pending_action
    if @pending_action
    end
  end

  def abort
    action_abort
  end

  def release_locks
    if @state == :blocked and waiting_lock
      lock = @waiting_lock
      lock.give_up_wait
    end
    @locks.each { |l| l.release }
  end
  
  def older_than?(lock)
    @birth_time < lock.birth_time
  end
end
