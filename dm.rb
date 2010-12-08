# Data Manager

# s_id: the site id
# VariableTable: VariableID => Value

load "database.rb"
require 'pp'
require './Configure.rb'

# Data Manager: manage the variables on the site
class DM

####### variables
  # site ID
  attr_reader :s_id
  # Variable Table: VariableID => Value
  attr_reader :variableTable
  # Record the version of commited variables
  # * Data Table: VariableID => [ Value, Version(Time)]
  attr_reader :dataTable
  #  Array of non-replicated variable 
  attr_reader :nonRepList
  # Record whether an variable can be read(not available util written protocol)
  # * Variable ID => true/false
  attr_reader :isReadTable
  # Database to store the site information
  attr_reader :db


###### Methods

  def initialize(s_id= "site0")
    @s_id= s_id
    @variableTable= Hash.new
    @dataTable= Hash.new
    @nonRepList= Array.new
    @isReadTable= Hash.new
    @db= Database.new("#{@s_id}.dat")
    c = Configure.new
    c.configTable[:variables].each do |v|
      c.configTable[v.to_sym][:rep_sites].each do |id|
        if id== @s_id
          @variableTable[v]= c.configTable[v.to_sym][:value].clone
          @isReadTable[v]= true
          @dataTable[v] = Array.new
          @dataTable[v] << [c.configTable[v.to_sym][:value].clone, -1]
          if c.configTable[v.to_sym][:rep_sites].length == 1
            @nonRepList << v
          end
        end
      end
    end
    @dataTable.each do |k, v|
      @db.write("#{k}", v)
    end
  end

  # return all the commited value of variable
  def dumpVar(v_id)
    result = Array.new
    @dataTable[v_id].each do |v|
      result << v[0]
    end
    return result
  end
  
  # return all the commited value of all variables
  def dumpSite
    result = Hash.new
    @dataTable.each do |v, a|
      result[v]=dumpVar(v)
    end
    return result
  end

  def addRep(v_id)
    @variableTable[v_id]= 0
    @isReadTable[v_id]=false
    if not @dataTable.has_key?(v_id)
      @dataTable[v_id]=Array.new
    end
    puts "Add Rep #{v_id}"
    pp @variableTable
  end

  def rmRep(v)
    @variableTable.delete(v)
    @isReadTable.delete(v)
    if @dataTable[v].length == 0
      @dataTable.delete(v)
    end
    puts "Remove Rep #{v}"
    pp @variableTable
  end

  def readV(v_id)
    @variableTable[v_id]
  end

  def readOnly(v_id, birth_time)
    n= @dataTable[v_id].length
    1.upto(n) do |i|
      if birth_time > @dataTable[v_id][-i][1]
        return @dataTable[v_id][-i][0]
      end
    end
  end

  def writeV(v_id, value)
    @variableTable[v_id]= value
    #@isReadTable[v_id]= true
  end

  def abortT (vs)
    vs.each do |v_id|
      @variableTable[v_id] = @dataTable[v_id][-1][0]
    end
  end

  def commitT(vs, time)
    vs.each do |v_id|
      @isReadTable[v_id]= true
      @dataTable[v_id] << [@variableTable[v_id], time]
      @db.write("#{v_id}", [@variableTable[v_id], time])
    end
  end

  def recover()
    @variableTable = Hash.new
    @isReadTable = Hash.new
    @nonRepList.each do |v|
      #@variableTable[v]= @dataTable[v][-1][0]
      @isReadTable[v]=true
    end
   # @isReadTable.each do |v, r|
  #    if @nonRepList.include?(v)
   #     @isReadTable[v]= true
    #  else
     #   @isReadTable[v]= false
     # end
  #  end
  end

end
