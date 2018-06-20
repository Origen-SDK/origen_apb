module OrigenApb
  class Driver
    REQUIRED_PINS = [:paddr_pin, :penable_pin, :pwrite_pin, :pwdata_pin, :pstrb_pin, :psel_pin]

    include Origen::Model
    attr_reader :owner

    # Initialize owner
    def initialize(owner, options = {})
      if owner.is_a?(Hash)
        @owner = parent
        options = owner
      else
        @owner = owner
      end

      validate_pins(options)

      if defined?(owner.class::APB_CONFIG)
        options = owner.class::APB_CONFIG.merge(options)
      end

      options = {
        verbose:    false,
        init_state: :unknown
      }.merge(options)
    end

    def validate_pins(options)
      @pclk_pin = options[:pclk_pin] if options[:pclk_pin]
      @paddr_pin = options[:paddr_pin] if options[:paddr_pin]
      @pprot_pin = options[:pprot_pin] if options[:pprot_pin]
      @psel_pin = options[:psel_pin] if options[:psel_pin]
      @penable_pin = options[:penable_pin] if options[:penable_pin]
      @pwrite_pin = options[:pwrite_pin] if options[:pwrite_pin]
      @pwdata_pin = options[:pwdata_pin] if options[:pwdata_pin]
      @pstrb_pin = options[:pstrb_pin] if options[:pstrb_pin]
      @prdata_pin = options[:prdata_pin] if options[:prdata_pin]
      @pslverr_pin = options[:pslverr_pin] if options[:pslverr_pin]

      #
      @pclk_pin = @owner.pin(:pclk) if @pclk_pin.nil?
      @psel_pin = @owner.pin(:psel0) if @psel_pin.nil?
      @paddr_pin = @owner.pin(:paddr) if @paddr_pin.nil?
      @pprot_pin = @owner.pin(:pprot) if @pprot_pin.nil?
      @penable_pin = @owner.pin(:penable) if @penable_pin.nil?
      @pwrite_pin = @owner.pin(:pwrite) if @pwrite_pin.nil?
      @pwdata_pin = @owner.pin(:pwdata) if @pwdata_pin.nil?
      @pstrb_pin = @owner.pin(:pstrb) if @pstrb_pin.nil?
      @prdata_pin = @owner.pin(:prdata0) if @prdata_pin.nil?
      @pslverr_pin = @owner.pin(:pslverr) if @pslverr_pin.nil?
    rescue
      puts 'Missing APB pins!'
      puts "In order to use the APB driver your #{owner.class} class must either define"
      puts 'the following pins (an alias is fine):'
      puts REQUIRED_PINS
      puts '-- or --'
      puts 'Pass the pins in the initialization options:'
      puts "sub_block :apb, class_name: 'OrigenApb::Driver', paddr: dut.pin(:paddr), penable: dut.pin(:penable), pwrite: dut.pin(:pwrite), pwdata: dut.pin(:pwdata), pstrb: dut.pin(:pstrb)"
      raise 'APB driver error!'
    end

    # Read register. Handles register model as input or data/address pair.
    # Sets up APB parameters values and passes along to pin-layer apb
    # transaction method.
    def read_register(reg_or_val, options = {})
      options = {
        paddr: options[:address] || reg_or_val.address,
        pdata: reg_or_val,
        pread: 1
      }.merge(options)
      #      options[:paddr] = options[:paddr].to_hex
      cc '==== APB Read Transaction ===='
      if reg_or_val.respond_to?('data')
        data = reg_or_val.data
        name_string = 'Reg: ' + reg_or_val.name.to_s + ' '
      else
        data = reg_or_val
        name_string = ''
      end
      cc name_string + 'Addr: 0x' + options[:paddr].to_s(16) + ' Data: 0x' + data.to_s(16)
      apb_read_trans(options)
    end

    # Read register. Handles register model as input or data/address pair.
    # Sets up APB parameters values and passes along to pin-layer apb
    # transaction method.
    def write_register(reg_or_val, options = {})
      options = {
        paddr:  options[:address] || reg_or_val.address,
        pdata:  reg_or_val,
        pwrite: 1
      }.merge(options)
      cc '==== APB Write Transaction ===='
      if reg_or_val.respond_to?('data')
        data = reg_or_val.data
        name_string = 'Reg: ' + reg_or_val.name.to_s + ' '
      else
        data = reg_or_val
        name_string = ''
      end
      cc name_string + 'Addr: 0x' + options[:paddr].to_s(16) + ' Data: 0x' + data.to_s(16)
      apb_write_trans(options)
    end

    def apb_read_trans(options = {})
      # INITIAL INPUT STAGES TO BE SETUP HERE.
      @psel_pin.drive(0)
      @pwrite_pin.drive(0)
      @penable_pin.drive(0)
      @pstrb_pin.drive(0)
      @pwdata_pin.drive(0)
      tester.cycle
      # This is the SETUPa
      @paddr_pin.drive(options[:paddr])
      @pwrite_pin.drive(0)
      @psel_pin.drive(1) # User or Test (0 or 1)
      @pstrb_pin.drive(0)
      @penable_pin.drive(1)
      @prdata_pin.assert(options[:pdata])
      tester.cycle
      @prdata_pin.dont_care
      # This is next phase?
      @pwrite_pin.drive(0)
      @psel_pin.drive(0)
      @penable_pin.drive(0)
      @pstrb_pin.drive(0)
      @pwdata_pin.drive(0)
      tester.cycle
    end

    def apb_write_trans(options = {})
      # INITIAL INPUT STAGES TO BE SETUP HERE.
      @psel_pin.drive(0)
      @pwrite_pin.drive(0)
      @penable_pin.drive(0)
      @pstrb_pin.drive(0)
      @pwdata_pin.drive(0)
      tester.cycle
      # This is the SETUPa
      @paddr_pin.drive(options[:paddr])
      @pwrite_pin.drive(options[:pwrite])
      @psel_pin.drive(1) # User or Test (0 or 1)
      @pstrb_pin.drive(15)
      @pwdata_pin.drive(options[:pdata])
      @penable_pin.drive(1)
      tester.cycle
      @prdata_pin.dont_care
      # This is next phase?
      @pwrite_pin.drive(0)
      @psel_pin.drive(0)
      @penable_pin.drive(0)
      @pstrb_pin.drive(0)
      @pwdata_pin.drive(0)
      tester.cycle
    end
  end
end
