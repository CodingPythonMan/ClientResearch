#include <windows.h>
#include <iostream>
#include "Player.h"

int main()
{
	Player player;

	while (1)
	{
		system("cls");
		std::cout << "---------------------------------------------------------" << "\n";
		
		std::cout << "X : " << player.X << "\n";
		std::cout << "Y : " << player.Y << "\n";
		std::cout << "HP : " << player.HP << "\n";

		std::cout << "---------------------------------------------------------" << "\n";
		Sleep(1000);
	}
}