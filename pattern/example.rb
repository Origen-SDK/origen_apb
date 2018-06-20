Pattern.create do

  cc 'Write to top-level register using reg model'
  $dut.reg(:top_reg).write!(0x5555_AAAA)

  cc 'Write to top-level register using data/address'
  $dut.write_register(0xAAAA_5555, address: 0x20000000)

  cc 'Read from top-level register using data/address'
  $dut.read_register(0xAAAA_5555, address: 0x20000000)

   cc 'Write to block-level register'
  $dut.block.reg(:control).write!(0xBA5E_BA11)

  cc 'Read from block-level register'
  $dut.block.reg(:status).read!(0x0022_0000)

end
