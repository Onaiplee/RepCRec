require 'pp'

class TM
  def initialize
  end
  
  def read(opts)
    pp opts
    return
  end
end
    
class UIController
  def initialize(input = STDIN, output = STDOUT)
    @inputFile = input
    @outputFile = output
    @pattern = /([\w]+)([\s]*)\(([\w\s,]*)\)/
  end

  def run
    tm = TM.new
    if @inputFile == STDIN
      f = STDIN
    else
      f = File.open(@inputFile, "r")
    end
    f.each do |line|
      next if line =~ /^\/\// or line =~ /^[\s]*$/
      opts = format_input(line)
      out_put = tm.read(opts)
      unless out_put.nil?
        if @outputFile == STDOUT or @outputFile.nil?
          STDOUT.puts out_put
        else
          File.open(@outputFile, "a") do |log|
            log.puts out_put
          end
        end
      end
    end
    f.close
  end

 private
  def format_input(line)
    opts = line.split(';')
    result = []
    for op in opts
      @pattern =~ op
      data = Regexp.last_match
      raise "bad arguments" if data.nil?
      op_code, place_holder, params = data[1..3]
      if op_code =~ /dump/
        op_code << (params.length+1).to_s
      end
      params = params.split(",")
      result << [op_code, params].flatten
    end
    result
  end
end


##### Run it ####
if $0 == __FILE__
  if ARGV.empty?
    g = UIController.new
  else
    input, output = ARGV
    g = UIController.new(input, output)
  end
  g.run
end
