#ifdef near
    #undef near
#endif

#ifdef far
    #undef far
#endif

#include <raylib.h>
#include <raymath.h>
#include <rlgl.h>

int main()
{
    InitWindow(1280, 720, GAME_NAME);
    SetTargetFPS(60);

    Texture2D texture = LoadTexture("../Resource/tile.png");

    while (!WindowShouldClose())
    {
        const Vector2 pos = GetMousePosition();

        BeginDrawing();
        ClearBackground(BLACK);

        DrawTexture(texture, GetScreenWidth() / 2.0f, GetScreenHeight() / 2.0f, WHITE);
        DrawCircleV(pos, 4, WHITE);

        EndDrawing();
    }

    UnloadTexture(texture);

    CloseWindow();
    return 0;
}
