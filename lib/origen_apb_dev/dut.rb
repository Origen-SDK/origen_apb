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

      # APB Bridge Signals

      add_pin :pclk
      add_pin :preset
      add_pin :paddr, size: 32
      add_pin :pprot, size: 3
      add_pin :psel # One psel per slave
      add_pin :penable
      add_pin :pwrite
      add_pin :pwdata, size: 32
      add_pin :pstrb, size: 4 # psrtb[n] = pwdata[(8n+7):(8n)]

      # Slave Interface Signals

      add_pin :pready
      add_pin :prdata, size: 32
      add_pin :pslverr
    end

    # Create a top-level test register
    def instantiate_registers(options = {})
      add_reg :top_reg, 0x20000000, 32, data: { pos: 0, bits: 32 }
    end

    # Create a sub-block for test dut
    def instantiate_sub_blocks(options = {})
      sub_block :block, class_name: 'OrigenApbDev::BLOCK', base_address: 0x2200_0000

      sub_block :apb, class_name:  'OrigenApb::Driver',
                      psel_pin:    pin(:psel),
                      paddr_pin:   pin(:paddr),
                      penable_pin: pin(:penable),
                      pwrite_pin:  pin(:pwrite),
                      pwdata_pin:  pin(:pwdata),
                      pstrb_pin:   pin(:pstrb),
                      prdata_pin:  pin(:prdata)
    end
  end
end
