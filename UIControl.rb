# This program implement a simulation of distributed databases
# with replicated concurrency control and recovery

require 'rubygems'
load 'TM.rb'

# This class(UIController) is a user interface with following functions:
# * 1.Read the user input instructions from a file or the standard input
# * 2.Translate the instructions into concrete operations and send them to the Transaction Manager(TM)
# * 3.Get responses from TM and output them

class UIController

  #input format
  attr_reader :inputFile
  #output format
  attr_reader :outputFile
  #pattern for an instruction
  attr_reader :pattern

  # * Initialize input and output format. Use standard input and output as default
  # * Define pattern of an instruction
  # * Bind a transaction manager(TM)
  def initialize(tm, input = STDIN, output = STDOUT)

    @inputFile = input

    @outputFile = output

    @pattern = /([\w]+)([\s]*)\(([\w\s,]*)\)/
    #the transaction manager
    @tm = tm
  end

  # * 1.Read the user input instructions from a file or the standard input
  # * 2.Translate the instructions into concrete operations and send them to the Transaction Manager(TM)
  # * 3.Get responses from TM and output them
  def run
    #check input format, either a file or standard input
    if @inputFile == STDIN
      f = STDIN
    else
      f = File.open(@inputFile, "r")
    end
    #flag to mark whether read the first instruction and be used to check lines before any instruction
    mark = false
    #process instructiions line by line
    f.each do |line|
      #skip comments
      next if line =~ /^\/\//
      #skip an empty line before any instruction
      next if mark == false and line =~ /^[\s]*$/
      opts = format_input(line)
      mark = true if mark == false
      out_put = @tm.read(opts)
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
    #add a time step for TM
    out_put = @tm.read([["advance"]])
    unless out_put.nil?
      if @outputFile == STDOUT or @outputFile.nil?
        STDOUT.puts out_put
      else
        File.open(@outputFile, "a") do |log|
          log.puts out_put
        end
      end
    end

    f.close

  end

  #Method used to return instructions in a given line
  # * return [instruction, instruction, instruction]
  # * instruction: [op_code, param1, param2,...]
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
      raise "Bad Arguments" if data.nil?
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


# * Start an UIControl to communicate with user
# * Start a TM
if $0 == __FILE__
  #if ARGV = []
  #  puts "Usage: ruby UIControl.rb [inputfile] [outputfile]"
  #  puts "If no inputfile or outputfile, STDIN or STDOUT is the default."
  #end
  tm = TM.new
  if ARGV.empty?
    g = UIController.new(tm)
  else
    input, output = ARGV
    g = UIController.new(tm, input, output)
  end
  g.run
end
