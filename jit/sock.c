#include <sys/socket.h>
#include <netinet/in.h>
#include <stdio.h>
#include <strings.h>

int main(int argc, char**argv)
{
    int                  listenfd;
    struct sockaddr_in   servaddr;

    listenfd = socket(AF_INET, SOCK_STREAM, 0);

    bzero(&servaddr, sizeof(servaddr));
    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr=htonl(INADDR_ANY);
    servaddr.sin_port=htons(0);

    bind(listenfd, (struct sockaddr *) &servaddr, sizeof(servaddr));

    listen(listenfd, 1024);

    socklen_t len;
    len = sizeof(servaddr);
    if (getsockname(listenfd, (struct sockaddr *) &servaddr, &len) < 0)
         return (-1);

    printf("port: %d\n", ntohs(servaddr.sin_port));
    close (listenfd);
}
