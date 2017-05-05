/*
 based on the work of Stefan Esser on his dumpdecrypted.dylib stuff
 and libsubjc from kennytm that i couldn't build from source nor use properly (maybe my bad dude)
 all credz to them srsly, they've done teh work. i've just added some bullshit.
 
 usage(until fronted functionnal):
 root# DYLD_INSERT_LIBRARIES=itrace.dylib /Applications/Calculator.app/Calculator
 
 this dylib just hook objc_msgSend thanks to MobileSubstrate/interpos (just uncomment some
 commented line to switch method) & print out the class and methods called, white/blacklisti
 
 last rev: 2013/02/17
 Sogeti ESEC - sqwall
 */

/*
 This's a short version from(https://github.com/emeau/itrace)
 samuel.song.bc@gmail.com
 */

#ifndef __hookmsg_h
#define __hookmsg_h

#ifdef __cplusplus
extern "C"
{
#endif

//start to log to file
//"/var/BaiduInputMethod/hookmsglog.txt"
void bi_log_start(const char *fname);
    
void bi_log_pause(void);
void bi_log_stop(void);

//add custom flag text for debug(coz there are too many logs in file)
void bi_log_add_flag(const char *text);

#ifdef __cplusplus
}
#endif

#endif //__hookmsg_h
