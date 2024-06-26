#pragma once

#include <raylib.h>

class GameWindow
{
public:
    GameWindow(const int screenWidth, const int screenHeight);
    ~GameWindow();

    void Start();

private:
#ifdef TEST_MODE
    friend class GameWindowFriend;
#endif

    int m_screenWidth;
    int m_screenHeight;

    Vector2 m_ballPosition;
};
