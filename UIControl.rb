#!/usr/bin/env ruby

# This program implement a simulation of distributed databases
# with replicated concurrency control and recovery
require 'rubygems'
require 'xmlrpc/client'

# This class(UIController) is a user interface with following functions:
# * 1.Read the user input instructions from a file or the standard input
# * 2.Translate the instructions into concrete operations and send them to the Transaction Manager(TM)
# * 3.Get responses from TM and output them

class TM
  def initialize(host="localhost", path="/RPC2", port=20000) 
    @server = XMLRPC::Client.new(host, path, port)
  end

  def read(opts)
    @server.call_async("TransactionManager.read", opts)
  end
end
    

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
  def initialize(tm, input = STDIN, output = STDOUT, step = false)

    @inputFile = input

    @outputFile = output

    @step = step

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

      line_tmp = line.dup
      line_tmp.chop! if line_tmp[-1] == "\n"
      if @step == true
        print "\t\t\t\t\t\t\t", line_tmp
        while true
          print ".....Press Enter to continue!", "\n"
          if STDIN.gets == "\n"
            break
          end
        end
      end
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
  if ARGV == []
    puts "Usage: UIControl.rb [-d] [--with_input=inputfile] [--with_output=outputfile] [--with_single_step]"
    puts "       If no input or output file arguments, STDIO and STDOUT is for default."
    puts "       --with_single_step enables the single step mode to run the test file."
  end
  if ARGV[0] == "-d"
    tm = TM.new
    if ARGV.empty?
      g = UIController.new(tm)
    else
      input = STDIN
      output = STDOUT
      step = false
      ARGV.each do |arg|
        if arg =~ /--with_input/
          input = arg.split('=')[1]
          input.strip!
        elsif arg =~ /--with_output/
          output = arg.split('=')[1]
          output.strip!
        elsif arg =~ /--with_single/
          step = true
        end
      end
      g = UIController.new(tm, input, output, step)
    end
    g.run
  end
end
