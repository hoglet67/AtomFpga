
package board_config_pack is

    constant G_CONFIG_DEBUGGER : boolean := true;

    constant G_CONFIG_VGA      : boolean := true;

    -- Note: Please use the PiTube build for tracing as the VGA .cst
    -- file is incompatible due to it's use of differential drivers.

    constant G_CONFIG_TRACE    : boolean := false;

end board_config_pack;


package body board_config_pack is

end board_config_pack;
