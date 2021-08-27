require "vertigo"

module Wrapper

  class Compiler

    attr_accessor :options
    attr_accessor :project_name

    def initialize options={}
      @options=options
    end

    def compile filename
      parse(filename)
      detect_entity
      generate_reggae_sexp
    end

    def parse filename
      @ast=Vertigo::Compiler.new.parse(filename)
    end

    def detect_entity
      print "=> detect entity : "
      @entity=@ast.design_units.find{|du| du.is_a? Vertigo::Entity}
      puts "found '#{@entity.name.str}'"
    end

    def generate_reggae_sexp
      print "=> generating reggae s-exp : "
      code=Code.new
      code << "(memory_map wrapper_#{name=@entity.name.str}"
      code.indent=2
      code << generate_parameters
      code << generate_zone
      code.indent=0
      code << ")"
      #puts code.finalize
      code.save_as filename="#{name}.sexp"
      puts filename
    end

    def generate_parameters
      nb_regs=@entity.ports.size-1 #exclude clock
      code=Code.new
      code << "(parameters"
      code.indent=2
      code << "(bus"
      code.indent=4
      code << "(address_size #{@options[:addr_bitwidth]})"
      code << "(data_size #{@options[:data_bitwidth]})"
      code << "(frequency 100)"
      code.indent=2
      code << ")"
      code << "(range 0x00 #{nb_regs.to_s(16)})"
      code.indent=0
      code << ")"
      code
    end

    def generate_zone
      code=Code.new
      code << "(zone ip_#{@entity.name.str}"
      code.indent=2
      nb_regs=@entity.ports.size-1 #exclude clk
      code << "(range 0x0 0x#{nb_regs.to_s(16)})"
      code.newline
      @entity.ports.each_with_index do |port,addr|
        next if port.name.str=="ap_clk"
        code << generate_reg(port,addr)
      end
      code << generate_instance()
      code.indent=0
      code << ")"
      code
    end

    def generate_reg port,addr
      code=Code.new
      code << "(register reg_#{port.name.str}"
      code.indent=2
      code << "(address 0x#{addr.to_s(16)})"
      code << "(init 0x0)"
      code << "(sampling true)" if port.is_a?(Vertigo::Output)
      case port.type.str
      when "std_logic"
        code << "(bit 0"
        code.indent=4
        code << "(name lsb)"
        code.indent=2
        code << ")"
      when /std_logic_vector\((\d+) downto (\d+)\)/
        code << "(bitfield #{$1}..#{$2}"
        code.indent=4
        code << "(name value)"
        code.indent=2
        code << ")"
      end
      code.indent=0
      code << ")"
      code
    end

    def generate_instance
      code=Code.new
      code << "(instance #{@entity.name.str}"
      code.indent=2
      @entity.ports.each_with_index do |port,addr|
        next if port.name.str=="ap_clk"
        code << generate_connect(port)
      end
      code.indent=0
      code << ")"
      code
    end

    def generate_connect port
      code=Code.new
      dir=port.is_a?(Vertigo::Input) ? "input" : "output"
      pname=port.name.str
      reg="(register reg_#{pname} "
      case port.type.str
      when "std_logic"
        reg << "lsb)"
      when /std_logic_vector\((\d+) downto (\d+)\)/
        reg << "value)"
      end
      code << "(connect (#{dir} #{pname}) #{reg})"
      code
    end

  end
end
