module OrigenApbDev
  # Top-level chip model for development and unit testing
  class DUT
    include Origen::TopLevel
    include OrigenApb

    # Initializer method to setup dut
    def initialize(options = {})
      instantiate_pins(options)
      instantiate_registers(options)
      instantiate_sub_blocks(options)
    end

    # Add standard DUT pins and pins necessary for APB protocol
    def instantiate_pins(options = {})
      # Standard DUT pins
      add_pin :tclk
      add_pin :tdi
      add_pin :tdo
      add_pin :tms
      add_pin :resetb

      # APB Control Signals


      # APB Data Signals

    end

    # Create a top-level test register
    def instantiate_registers(options = {})
      add_reg :top_reg, 0x20000000, 32, data: { pos: 0, bits: 32 }
    end

    # Create a sub-block for test dut
    def instantiate_sub_blocks(options = {})
      sub_block :block, class_name: 'OrigenApbDev::BLOCK', base_address: 0x2200_0000
    end
  end
end
