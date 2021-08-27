require "optparse"

require_relative "compiler"

module Wrapper

  class Runner

    def self.run *arguments
      new.run(arguments)
    end

    def run arguments
      compiler=Compiler.new
      compiler.options = args = parse_options(arguments)
      begin
        if filename=args[:file]
          ok=compiler.compile(filename)
        else
          raise "need a VHDL file : wrapper [options] <file.vhd>"
        end
        return ok
      rescue Exception => e
        puts e unless compiler.options[:mute]
        return false
      end
    end

    def header
      puts "wrapper (#{VERSION}) - (c) JC Le Lann 2021"
    end

    private
    def parse_options(arguments)

      parser = OptionParser.new

      no_arguments=arguments.empty?

      options = {}

      parser.on("-h", "--help", "Show help message") do
        puts parser
        exit(true)
      end

      parser.on("-d N", "--data_bitwidth N", "number of bits for data bus") do |n|
        options[:data_bitwidth]=n
      end

      parser.on("-a N", "--addr_bitwidth N", "number of bits for data bus") do |n|
        options[:addr_bitwidth]=n
      end

      parser.on("--mute","mute") do
        options[:mute]=true
      end

      parser.on("-v", "--version", "Show version number") do
        puts VERSION
        exit(true)
      end

      parser.parse!(arguments)

      header unless options[:mute]

      options[:file]=arguments.shift #the remaining file

      if no_arguments
        puts parser
      end
      options[:addr_bitwidth]||=8
      options[:data_bitwidth]||=32

      options
    end
  end
end
