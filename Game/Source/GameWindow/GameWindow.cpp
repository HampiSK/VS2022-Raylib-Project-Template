#include "GameWindow.hpp"

GameWindow::GameWindow(const int screenWidth, const int screenHeight) :
    m_screenWidth(screenWidth), m_screenHeight(screenHeight)
{
    m_ballPosition = { static_cast<float>(m_screenWidth) / 2.f, static_cast<float>(m_screenHeight) / 2.f };
    InitWindow(m_screenWidth, screenHeight, "Simple Raylib Program");
    SetTargetFPS(60);
}

GameWindow::~GameWindow()
{
    CloseWindow();
}

void GameWindow::Start()
{
    // Main game loop
    while (!WindowShouldClose())
    {
        // Update
        if (IsKeyDown(KEY_RIGHT)) m_ballPosition.x += 6.0f;
        if (IsKeyDown(KEY_LEFT)) m_ballPosition.x -= 6.0f;
        if (IsKeyDown(KEY_UP)) m_ballPosition.y -= 6.0f;
        if (IsKeyDown(KEY_DOWN)) m_ballPosition.y += 6.0f;

        // Draw
        BeginDrawing();

        ClearBackground(RAYWHITE);

        DrawText("Move the ball with arrow keys", 10, 10, 20, DARKGRAY);
        DrawCircleV(m_ballPosition, 50, MAROON);

        EndDrawing();
    }
}
