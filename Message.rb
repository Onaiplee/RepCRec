#Message used to communicate TM and DM

class Message

   attr_accessor :time, :t_id, :s_id, :v_id, :value, :type, :result, :var

  def initialize(time, t_id, type, v_id, value= nil, s_id= nil, result= nil,  var= nil)
    @time= time
    @t_id= t_id
    @type= type
    @v_id= v_id
    @value= value
    @s_id= s_id
    @result= result
    @var= var
  end

end