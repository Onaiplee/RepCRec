# Data Manager

# s_id: the site id
# VariableTable: VariableID => Value

load "database.rb"
require 'pp'

class DM

  attr_reader :variableTable, :dataTable, :nonRepList, :isReadTable, :db

  def initialize(s_id= "site0")
    @s_id= s_id
    @variableTable= Hash.new
    @dataTable= Hash.new
    @nonRepList= Array.new
    @isReadTable= Hash.new
    @db= Database.new("#{@s_id}.dat")
    c= Configure.new
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
    #@db.write("dataTable", @dataTable)
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
    @isReadTable[v_id]= true
  end

  def abortT (vs)
    vs.each do |v_id|
      #从数据库restore数据
      @variableTable[v_id] = @dataTable[v_id][-1][0]
    end
  end

  def commitT(vs, time)
    vs.each do |v_id|
      #把数据copy数据库
      @dataTable[v_id] << [@variableTable[v_id], time]
      @db.write("#{v_id}", [@variableTable[v_id], time])
    end
  end

  def recover()
    @variableTable.each do |v, r|
      @variableTable[v]= @dataTable[v][-1][0]
    end
    @isReadTable.each do |v, r|
      if @nonRepList.include?(v)
        @isReadTable[v]= true
      else
        @isReadTable[v]= false
      end
    end
  end

end