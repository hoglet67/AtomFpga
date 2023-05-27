from vunit import VUnit


def encode(tb_cfg):
    return ", ".join(["%s:%s" % (key, str(tb_cfg[key])) for key in tb_cfg])

# Create VUnit instance by parsing command line arguments
vu = VUnit.from_argv()

# Create library 'lib'
lib = vu.add_library("lib")

# Add source files

lib.add_source_files("../../src/AtomFpga_TangNano9K.vhd")
lib.add_source_files("../../src/psram_controller.vhd")
lib.add_source_files("../../src/bootstrap.vhd")
lib.add_source_files("../../src/tmds_encoder.vhd")
lib.add_source_files("../../src/VideoRam.vhd")
lib.add_source_files("../../src/dpram_8k/dpram_8k.vhd")

lib.add_source_files("../../../../src/xilinx/spi_flash.vhd")

lib.add_source_files("../../../../src/common/AlanD/R65Cx2.vhd")
lib.add_source_files("../../../../src/common/T6502/T65_Pack.vhd")
lib.add_source_files("../../../../src/common/T6502/T65_ALU.vhd")
lib.add_source_files("../../../../src/common/T6502/T65_MCode.vhd")
lib.add_source_files("../../../../src/common/T6502/T65.vhd")
lib.add_source_files("../../../../src/common/CpuWrapper.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/MC6847/CharRam.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/MC6847/CharRom.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/MC6847/mc6847.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/MINIUART/Rxunit.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/MINIUART/Txunit.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/MINIUART/utils.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/MINIUART/miniuart.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/mouse/mouse_controller.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/mouse/ps2interface.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/mouse/resolution_mouse_informer.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/mouse/MouseRefComp.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/pointer/PointerRamBlack.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/pointer/PointerRamWhite.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/pointer/Pointer.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/SID/sid_components.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/SID/sid_coeffs.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/SID/sid_filters.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/SID/sid_voice.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/SID/sid_6581.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/VGA80x40/ctrm.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/VGA80x40/losr.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/VGA80x40/vga80x40.vhd")
lib.add_source_files("../../../../src/common/AtomGodilVideo/AtomGodilVideo.vhd")
lib.add_source_files("../../../../src/common/AtomPL8.vhd")
lib.add_source_files("../../../../src/common/i82C55/i82c55.vhd")
lib.add_source_files("../../../../src/common/MC6522/m6522.vhd")
lib.add_source_files("../../../../src/common/ps2kybrd/ps2_intf.vhd")
lib.add_source_files("../../../../src/common/ps2kybrd/keyboard.vhd")
lib.add_source_files("../../../../src/common/RamRom_Atom2015.vhd")
lib.add_source_files("../../../../src/common/RamRom_None.vhd")
lib.add_source_files("../../../../src/common/RamRom_Phill.vhd")
lib.add_source_files("../../../../src/common/RamRom_SchakelKaart.vhd")
lib.add_source_files("../../../../src/common/SPI/spi.vhd")
lib.add_source_files("../../../../src/common/AtomFpga_Core.vhd")

lib.add_source_files("../gowin/prim_sim.vhd")
lib.add_source_files("../s27kl0642/s27kl0642.v", file_type="verilog")

lib.add_source_files("test_tb.vhd")

# Dummy modules
lib.add_source_files("../src/AVR8.vhd")
#lib.add_source_files("../src/dvi_tx.vhd")

tb = lib.test_bench("test_tb")

cfg = tb.add_config("defaults", generics=dict(
#    CImplAtoMMC2 = false,
#    CImplSDDOS = true,
#    CImplBootstrap = false
#    CImplTrace = true
))


lib.set_sim_option("disable_ieee_warnings", True)

# Run vunit function
vu.main()
