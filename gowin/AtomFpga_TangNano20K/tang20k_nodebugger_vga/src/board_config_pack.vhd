
package board_config_pack is

    constant G_CONFIG_DEBUGGER : boolean := false;

    constant G_CONFIG_VGA      : boolean := true;

    -- Note: Please use the PiTube build for tracing as the VGA .cst
    -- file is incompatible due to it's use of differential drivers.

    constant G_CONFIG_TRACE    : boolean := false;

    constant G_CORE_ID         : integer := -1;

end board_config_pack;


package body board_config_pack is

end board_config_pack;
