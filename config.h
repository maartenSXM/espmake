#ifndef _INCLUDE_CONFIG_H_
#define _INCLUDE_CONFIG_H_

// common config
#define CONFIG_HA			1	// Home Assistant?

// Config specific to a project tag
#if _PROJTAG_0
  #define CONFIG_DISPLAY		1	// touchscreen display?
#endif // _PROJTAG == 0
 
// Config specific to specific $USER
#if _USER_blort
  #undef CONFIG_HA				// USER blort doesnt use HA
#endif // _USER_blort

#endif // _INCLUDE_CONFIG_H_
