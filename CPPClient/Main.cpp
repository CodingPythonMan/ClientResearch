#include "Network.h"
#include <windows.h>
#include <iostream>
#include "Player.h"

int main()
{
	Player player;

	printf("접속할 IP 주소를 입력하세요 : ");
	WCHAR IP[16];
	wscanf_s(L"%s", IP, 16);

	NetworkInit();
	Connect(IP);

	Chat();


	/*
	while (1)
	{
		system("cls");
		std::cout << "---------------------------------------------------------" << "\n";
		
		std::cout << "X : " << player.X << "\n";
		std::cout << "Y : " << player.Y << "\n";
		std::cout << "HP : " << player.HP << "\n";

		std::cout << "---------------------------------------------------------" << "\n";
		Sleep(1000);
	}*/
}