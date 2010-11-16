require 'rubygems'
load 'TM.rb'

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
    mark = false
    f.each do |line|
      next if line =~ /^\/\//
      next if line =~ /^[\s]*$/ and mark == false
      opts = format_input(line)
      mark = true if mark == false
      out_put = tm.read(opts)
      unless out_put.nil?
        if @outputFile == STDOUT or @outputFile.nil?
          #print "Message from output of TM: "
          STDOUT.puts out_put.strip!
        else
          File.open(@outputFile, "a") do |log|
            log.puts out_put.strip!
          end
        end
      end
    end
    out_put = tm.read([["advance"]])
    unless out_put.nil?
      if @outputFile == STDOUT or @outputFile.nil?
        #print "Message from output of TM: "
        STDOUT.puts out_put
      else
        File.open(@outputFile, "a") do |log|
          log.puts out_put
        end
      end
    end
    f.close
  end

 private
  def format_input(line)
    result = []
    if line =~ /^[\s]*$/
      return result << ["advance"]
    end
    opts = line.split(';')
    for op in opts
      @pattern =~ op
      data = Regexp.last_match
      raise "bad arguments" if data.nil?
      op_code, place_holder, params = data[1..3]
      if op_code =~ /dump/
        op_code << (params.length+1).to_s
      end
      params = params.split(",")
      params.map { |p| p.strip! }
      result << [op_code, params].flatten
    end
    result
  end
end


##### Run it ####
if $0 == __FILE__
  #if ARGV = []
  #  puts "Usage: ruby UIControl.rb [inputfile] [outputfile]"
  #  puts "If no inputfile or outputfile, STDIN or STDOUT is the default." 
  #end
  if ARGV.empty?
    g = UIController.new
  else
    input, output = ARGV
    g = UIController.new(input, output)
  end
  g.run
end
