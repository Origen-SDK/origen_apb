module OrigenApb
  class Driver
    attr_reader :owner

    # Initialize owner
    def initialize(owner, options = {})
      @owner = owner
    end

    # Read register. Handles register model as input or data/address pair.
    # Sets up APB parameters values and passes along to pin-layer apb
    # transaction method.
    def read_register(reg_or_val, options = {})
    end

    # Read register. Handles register model as input or data/address pair.
    # Sets up APB parameters values and passes along to pin-layer apb
    # transaction method.
    def write_register(reg_or_val, options = {})
    end
  end
end
