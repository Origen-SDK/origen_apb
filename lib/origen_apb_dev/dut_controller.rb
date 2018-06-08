module OrigenApbDev
  class DUTController
    include Origen::Controller

    # Method called on any pattern startup to init timeset and pin values
    def startup(options = {})
      tester.set_timeset('apb', 40)

      init_pins     # Give pattern a known start up

      # Do some startup stuff here
      pin(:resetb).drive(0)
      tester.wait time_in_ns: 250
      pin(:resetb).drive(1)
    end

    # Method called on any pattern shutdown to leave pin values in known state
    def shutdown(options = {})
      # Shut everything down
      tester.wait time_in_ns: 250
      pin(:resetb).drive(0)

      cleanup_pins  # Give patterns a known exit condition
    end

    # Set pins to initial pin value
    def init_pins
      pin(:resetb).drive(0)
      pin(:tclk).drive(0)
      pin(:tdi).drive(0)
      pin(:tms).drive(0)
      pin(:tdo).dont_care
    end

    # Set pins to safe state for pattern end
    def cleanup_pins
      pin(:resetb).drive(0)
      pin(:tclk).drive(0)
      pin(:tdi).drive(0)
      pin(:tms).drive(0)
      pin(:tdo).dont_care
    end

    # Dut-level register write using APB driver
    def write_register(reg_or_val, options = {})
      apb.write_register(reg_or_val, options)
    end

    # Dut-level register read using APB driver
    def read_register(reg_or_val, options = {})
      apb.read_register(reg_or_val, options)
    end

    # Pin driver layer of APB protocol, used by APB
    def apb_trans(options = {})
    end
  end
end
