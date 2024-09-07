#ifndef _INCLUDE_CONFIG_H_
#define _INCLUDE_CONFIG_H_

// common config
#define CONFIG_HA			1	// Home Assistant?

// Config specific to a project tag
#ifdef ESPMAKE_PROJECT_lily
  #define CONFIG_DISPLAY		1	// touchscreen display?
#endif // ESPMAKE_PROJECT_lily
 
// Config specific to specific $USER
#ifdef _USER_blort
  #undef CONFIG_HA				// USER blort doesnt use HA
#endif // _USER_blort

#endif // _INCLUDE_CONFIG_H_
