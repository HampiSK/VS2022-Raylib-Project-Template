#include "GameWindow/GameWindow.hpp"

int main(int argc, char **argv)
{
    constexpr int SCREEN_WIDTH = 800;
    constexpr int SCREEN_HEIGHT = 450;

    GameWindow game(SCREEN_WIDTH, SCREEN_HEIGHT);
    game.Start();

    return 0;
}
