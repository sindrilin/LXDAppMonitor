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

/*
 
 ****************WARNING********************
 
 scheme must be iPhone device(real iOS device) but not simulator to compile asm
 必须使用真机才能编译汇编代码
 
 otherwise "Unknown register name 'r0' in asm"
 
 */

#include "hookmsg.h"
#include "hookutils.h"

#include <time.h>
#include <stdio.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <regex.h>
#include <strings.h>
#include <pthread.h>
#include <objc/objc.h>
#include <mach-o/dyld.h>
#include <objc/runtime.h>
#include <objc/message.h>
#include <Foundation/Foundation.h>


typedef id (*objc_msg_function)(id self, SEL op, ...);

//mobile substrate
extern void MSHookFunction(void *symbol, void *replace, void **result);

//thread specific funtions
//called by asm so can't be static
void *bi_add_context();
uint32_t bi_save_context();
void *bi_delete_context();

static pthread_key_t bi_key; //each thread has a specific data
static uint32_t log_enabled = 0;

//多进程访问文件，是否需要加文件锁？
//http://www.gnu.org/savannah-checkouts/gnu/libc/manual/html_node/File-Locks.html
static FILE *log_fp;

objc_msg_function s_originalObjcMsgSend;

static void *bi_get_thread_stack(void)
{
    void *stack = pthread_getspecific(bi_key);
    
    if (stack == 0)
    {
        stack = bi_stack_init(200);
        pthread_setspecific(bi_key, stack);
    }
    
    return stack;
}

static char *get_padding(char *buffer, char pad, uint32_t len)
{
    uint32_t i;
    for (i = 0; i < len; i++)
    {
        buffer[i] = pad;
    }
    
    buffer[i] = 0;
    return buffer;
}

/* hook callback, do whatever you want to 14 DWORD on teh stack before optionnals variadic arguments
 ***/
void hook_callback( id self , SEL op)
{
    if (!log_enabled)
    {
        return;
    }
    
    void *p = bi_get_thread_stack();
    
    int depth = bi_stack_depth(p);
    const char *className = object_getClassName(self);
    if( !className )
    {
        className = "nill";
    }
    
    if (log_fp)
    {
        char pad[200] = {0};
        char *padding = get_padding(pad, ' ', depth);
        fprintf(log_fp, "%s%s: \t%s\n", padding, className, sel_getName(op));
        
        //DO not open this when hook objc_msgSend, it is too slow
        //NSLog(@"%s%s: \t%s\n", padding, className, sel_getName(op));
    }
    
    return;
}

/* add a new context and return handle in r0
 ***/
void *bi_add_context()
{
    void *stack = bi_get_thread_stack();
    void *lr = bi_stack_push(stack);
    return lr;
}

void *bi_delete_context()
{
    void *stack = bi_get_thread_stack();
    void *lr = bi_stack_pop(stack);
    return lr;
}

//create objc_msgSend call's trace
__attribute__((naked))
uint32_t bi_save_context()
{
#if !TARGET_IPHONE_SIMULATOR
	__asm__ __volatile__(
        "stmdb sp!, {r0-r12,lr}\n"
		"push {r0-r11}\n"
		"push {r12}\n"

		"blx _bi_add_context\n"
                         
		"mov r12, r0\n"
		//"add r12, #16\n"
		"pop {r0}\n"
		"str r0, [r12]!\n"          //save lr to context
		//"add r12, #4\n"
		"pop {r0-r11}\n"
        // r9 = p_context->lr
		//"stmia r12!, {r0-r11}\n"    //save r0-r11 to context
	//prologue
		"ldmia sp!, {r0-r12,lr}\n"
		//"mov pc, lr\n"
	);
    
	__asm__ __volatile__( "ldr r0, %0\n" :/*output(no)*/:/*input*/"m" (s_originalObjcMsgSend) : "r0", "r1", "r2", "r3", "r4", "r5", "r6", "r7", "r8", "r10", "r11", "r12", "lr" );
#endif
}

/* main hook wrapper**/
__attribute__((naked))
static id bi_itrace(id self, SEL op)
{
#if !TARGET_IPHONE_SIMULATOR
	__asm__ __volatile__(
		"stmdb sp!, {r0-r8,r10-r12,lr}\n" //push lr, r12, r11, r10, r8, r7, ...r0

		"mov r12, lr\n"

		"bl _bi_save_context\n"             //save context and return original_msgSend in r0

		"mov r9, r0\n"
		"ldmia sp!, {r0-r8,r10-r12,lr}\n"
		//call hook callback
		"stmdb sp!, {r0-r12,lr}\n"
		"bl _hook_callback\n"               //log with the same(r0, r1, r2, r3, sp)
		"ldmia sp!, {r0-r12,lr}\n"

        "blx r9\n"                          //call original objc_msgSend

		"stmdb sp!, {r0-r12}\n"
		"bl _bi_delete_context\n"                 //delete context and return saved lr in r0
		"mov lr, r0\n"
		//epilogue
		"ldmia sp!, {r0-r12}\n"

		"bx lr\n"                           //return to callee
	);
#endif
}

#pragma mark - Public

id bi_hook_test(id self, SEL op)
{
    NSLog(@"---------------------I'm hooked function------");
    return self;
}

__attribute__((constructor))
static void bi_log_hook(void)
{
    pthread_key_create(&bi_key, 0);
    
    NSLog(@"-----------------hook objc_msgSend is now working--------");
    MSHookFunction(objc_msgSend, bi_itrace, (void**)&s_originalObjcMsgSend);
}

//"/var/BaiduInputMethod/hookmsglog.txt"
void bi_log_start(const char *fname)
{
    if (log_fp == 0)
    {
        log_fp = fopen(fname, "w+");
        if (log_fp == 0)
        {
            NSLog(@"-----------bi_log_start: error open file: %s", fname);
        }
    }
    
    time_t start_time;
    start_time = time(&start_time);
    char *text = ctime(&start_time);
    
    log_enabled = 1;
    NSLog(@"-------------bi_log_start(%s): %s", text, fname);
}

void bi_log_pause(void)
{
    log_enabled = 0;
    fflush(log_fp);
    
    time_t end_time;
    end_time = time(&end_time);
    char *text = ctime(&end_time);
    
    NSLog(@"-------------bi_log_pause(%s)", text);
}

void bi_log_stop(void)
{
    log_enabled = 0;
    if (log_fp)
    {
        fclose(log_fp);
        log_fp = 0;
    }
}

void bi_log_add_flag(const char *text)
{
    fprintf(log_fp, "%s\n", text);
}
