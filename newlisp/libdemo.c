/* libdemo.c - demo for importing libnewlisp.so
 * 
 * compile using: 
 *    gcc -ldl libdemo.c -o libdemo && ./libdemo '(+ 3 4)'
 *
 * use:
 *
 *    ./libdemo '(+ 3 4)'
 *    ./libdemo '(symbols)'
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
 
int main(int argc, char * argv[])
{
    void * hLibrary;
    char * result;
    char * (*func)(char *);
    char * error;
     
    if((hLibrary = dlopen("/usr/local/lib/libnewlisp.so",
                           RTLD_GLOBAL | RTLD_LAZY)) == 0)
    {
        printf("%s\n", dlerror());
        exit(-1);
    }
     
    func = dlsym(hLibrary, "newlispEvalStr");
    if((error = dlerror()) != NULL)
    {
        printf("error: %s\n", error);
        exit(-1);
    }
    
    printf("%s\n", (*func)(argv[1]));
    
    dlclose(hLibrary);
    
    return(0);
}