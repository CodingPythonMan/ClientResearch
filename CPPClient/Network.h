#pragma comment(lib, "ws2_32")
#include <WS2tcpip.h>
#include <stdlib.h>
#include <iostream>

#define SERVER_PORT 9000
#define BUFSIZE 512

void NetworkInit();

void Connect(WCHAR IP[]);

void Chat();