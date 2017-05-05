
#include "hookutils.h"
#include <stdlib.h>

#import <Foundation/Foundation.h>

typedef struct
{
    void *lr;
    
    //void *r0;
    //void *r1;
    
    void *pad; //pad for 8 bytes align
    
} bi_thread_context;

typedef struct
{
    int max;
    int index;
    bi_thread_context *data;
    
} bi_stack_ctrl;

//init a stack to save stack context
//we just save lr
//max is the max call level, you can set 100 for example
void *bi_stack_init(int max)
{
    bi_stack_ctrl *ctrl = (bi_stack_ctrl *)malloc(sizeof(bi_stack_ctrl));
    if (ctrl)
    {
        ctrl->index = 0;
        ctrl->max = max;
        
        size_t align_len = max * sizeof(bi_thread_context) + 7;
        void *p = calloc(align_len, 1);

        if (p)
        {
            char *ptr = (char *)p;
            size_t offset = (size_t)p % 8;
            if (offset != 0)
            {
                ptr += offset;          //*********notice this offset(restore it when freee)*************
                p = (void *)ptr;
            }
        }
        
        ctrl->data = p;
    }
    
    return ctrl;
}

//return the addr to save hr
void *bi_stack_push(void *stack)
{
    bi_stack_ctrl *p = (bi_stack_ctrl *)stack;
    
    void *lr = &(p->data[p->index++]);
    
#if 1
     if (p->index >= p->max)
     {
         NSLog(@"---------------------stack is full------------");
         assert(0);
     }
#endif
         
    return lr;
}

//return lr
void *bi_stack_pop(void *stack)
{
    bi_stack_ctrl *p = (bi_stack_ctrl *)stack;
    void *lr = &(p->data[--p->index]);
    
#if 1
    if (p->index < 0)
    {
        NSLog(@"---------------------stack is error------------");
        assert(0);
    }
#endif
    
    return *((void **)lr);
}

int bi_stack_depth(void *stack)
{
    bi_stack_ctrl *p = (bi_stack_ctrl *)stack;
    return p->index - 1;
}

void *bi_stack_top(void *stack)
{
    bi_stack_ctrl *p = (bi_stack_ctrl *)stack;
    void *lr = &(p->data[p->index - 1]);
    return lr;
}
