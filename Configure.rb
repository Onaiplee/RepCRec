require 'rubygems'
require 'parseconfig'
require 'pp'

class Configure
  include Enumerable

  attr_reader :configTable

  def initialize(conf = "repcrec.conf")
    @configTable = Hash.new
    @myConfig = ParseConfig.new('repcrec.conf')
    @configTable[:sites] = @myConfig.params['global config']['sites'].split(", ")
    @configTable[:variables] = @myConfig.params['global config']['variables'].split(",")
    @configTable[:variables].each do |v|
      value = @myConfig.params[v]['init_value']
      rep_sites = @myConfig.params[v]['sites'].split(", ")
      @configTable[v.to_sym] = {:value => value, :rep_sites => rep_sites}
    end
  end

  def each
    @configTable.each { |c| yield c}
  end
end
