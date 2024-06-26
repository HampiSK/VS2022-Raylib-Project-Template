#include <gtest/gtest.h>

#include "GameWindow/GameWindow.hpp"

class GameWindowFriend
{
public:
    GameWindowFriend() = default;

    static int GetScreenWidth(const GameWindow &game)
    {
        return game.m_screenWidth;
    }

    static int GetScreenHeight(const GameWindow &game)
    {
        return game.m_screenHeight;
    }
};

TEST(GameWindowTest, ScreenSizeCorrectlySet)
{
    constexpr int EXPECTED_SCREEN_WIDTH = 800;
    constexpr int EXPECTED_SCREEN_HEIGHT = 450;

    testing::internal::CaptureStdout();

    GameWindow game(EXPECTED_SCREEN_WIDTH, EXPECTED_SCREEN_HEIGHT);

    const int screenWidth = GameWindowFriend::GetScreenWidth(game);
    const int screenHeight = GameWindowFriend::GetScreenHeight(game);

    testing::internal::GetCapturedStdout();

    EXPECT_EQ(screenWidth, EXPECTED_SCREEN_WIDTH);
    EXPECT_EQ(screenHeight, EXPECTED_SCREEN_HEIGHT);
}
