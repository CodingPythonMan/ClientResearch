#include "Network.h"

SOCKET clientSock;

void NetworkInit()
{
	// ���� �ʱ�ȭ
	WSADATA wsa;
	if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0)
		return;

	// socket
	clientSock = socket(AF_INET, SOCK_STREAM, 0);
	if (clientSock == NULL)
		return;
}

void Connect(WCHAR IP[])
{
	// connect
	SOCKADDR_IN serverAddr;
	memset(&serverAddr, 0, sizeof(serverAddr));
	serverAddr.sin_family = AF_INET;
	InetPton(AF_INET, IP, &serverAddr.sin_addr);
	serverAddr.sin_port = htons(SERVER_PORT);
	int retval = connect(clientSock, (SOCKADDR*)&serverAddr,
		sizeof(serverAddr));

	if (retval == SOCKET_ERROR)
		return;
}

void Chat()
{
	char buf[BUFSIZE + 1];
	int len;

	int retval;

	// ������ ������ ���
	while (1)
	{
		printf("\n[Send Data] ");
		std::cin >> buf;

		// '\n' ���� ����
		len = (int)strlen(buf);
		if (buf[len - 1] == '\n')
			buf[len - 1] = '\0';
		if (strlen(buf) == 0)
			break;

		// ������ ������
		retval = send(clientSock, buf, (int)strlen(buf), 0);
		if (retval == SOCKET_ERROR)
			break;

		printf("[TCP Client] %d Bytes Send.\n", retval);

		// ������ �ޱ�
		retval = recv(clientSock, buf, retval, 0);
		if (retval == SOCKET_ERROR)
		{
			break;
		}
		else if (retval == 0)
			break;

		// ���� ������ ���
		buf[retval] = '\0';
		printf("[TCP Client] %d Bytes Recv.\n", retval);
		printf("[Recv Data] %s\n", buf);
	}

	closesocket(clientSock);

	// ���� ����
	WSACleanup();

	return;
}