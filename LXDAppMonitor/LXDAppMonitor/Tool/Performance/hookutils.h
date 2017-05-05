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

#ifndef __hookutils_h
#define __hookutils_h

#ifdef __cplusplus
extern "C"
{
#endif

//init a stack to save stack context
//we just save lr
//max is the max call level, you can set 200 for example
void *bi_stack_init(int max);
    
//return the addr to save hr
void *bi_stack_push(void *stack);

//return lr
//*****return value not addr
void *bi_stack_pop(void *stack);

int bi_stack_depth(void *stack);

//for debug
void *bi_stack_top(void *stack);
    
#ifdef __cplusplus
}
#endif

#endif //__hookutils_h

