#ifndef _INCLUDE_CONFIG_H_
#define _INCLUDE_CONFIG_H_

// Config specific to a project tag
#ifdef ESPMAKE_PROJECT_lily
  #define CONFIG_DISPLAY		1	// touchscreen display?
#endif // ESPMAKE_PROJECT_lily
 
// Config specific to specific $USER
#ifdef _USER_blort
  #define CONFIG_HA			1	// USER blort likes HA
#endif // _USER_blort

#endif // _INCLUDE_CONFIG_H_
