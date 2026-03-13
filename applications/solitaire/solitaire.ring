/*
**  Solitaire - RingRayLib
**  ======================
**  Classic single-player card game with sprite graphics.
**
**  Controls:
**    Left Click+Drag  -  Pick up and move cards
**    Right Click      -  Auto-send card to foundation/tableau
**    N = New game   U = Undo   H = Hint   M = Mute   ESC = Exit
**
**  Source Files:
**    solitaire.ring  -  Main game loop
**    globals.ring    -  Constants and global variables
**    audio.ring      -  Audio loading and unloading
**    gamelogic.ring  -  Game logic (new game, pile helpers, rules)
**    input.ring      -  Input handling (mouse, pickup, drop, auto-send)
**    undo.ring       -  Undo and hint
**    drawing.ring    -  All drawing functions
*/

load "raylib.ring"
load "globals.ring"
load "gamelogic.ring"
load "input.ring"
load "undo.ring"
load "drawing.ring"
load "audio.ring"

InitWindow(SCREEN_W, SCREEN_H, "Solitaire")
SetTargetFPS(60)

cardsImage = LoadImage("image/icon.png")
SetWindowIcon(cardsImage)
cardsTexture = LoadTexture("image/cards.png")
sol_loadAudio()
sol_newGame()

while !WindowShouldClose()

    UpdateMusicStream(bgMusic)
    if !IsMusicStreamPlaying(bgMusic) and !musicPaused
        PlayMusicStream(bgMusic)
    ok
    if IsKeyPressed(KEY_M)
        musicPaused = !musicPaused
        if musicPaused
            PauseMusicStream(bgMusic)
        else
            ResumeMusicStream(bgMusic)
        ok
    ok

    dt = GetFrameTime()
    if dt > 0.05  dt = 0.05  ok
    animTime += dt

    if gameState = GS_DEAL
        if dealFlying
            dealFlyT += dt / DEAL_FLY
            if dealFlyT >= 1.0
                dealFlyT = 1.0
                dealFlying = false
                dqCol = dealQueue[dealVisible]
                sol_incDealShow(dqCol)
                PlaySound(sndCardPlace)
            ok
        ok
        if !dealFlying
            dealTimer += dt
            if dealTimer >= DEAL_SPEED and dealVisible < len(dealQueue)
                dealTimer -= DEAL_SPEED
                dealVisible += 1
                dealFlyT = 0.0
                dealFlying = true
            ok
        ok
        if dealVisible >= len(dealQueue) and !dealFlying
            gameState = GS_PLAY
        ok
        if IsKeyPressed(KEY_N)  sol_newGame()  ok
    but gameState = GS_PLAY
        if IsKeyPressed(KEY_N)  sol_newGame()  ok
        if IsKeyPressed(KEY_U)  sol_undo()     ok
        if IsKeyPressed(KEY_H)
            sol_findHint()
            if hintTime > 0  PlaySound(sndHint)  ok
        ok
        sol_handleMouse()
        if hintTime > 0  hintTime -= dt  ok
        sol_checkWin()
    but gameState = GS_WIN
        winTime += dt
        sol_updateWinParts()
        if IsKeyPressed(KEY_N) or IsKeyPressed(KEY_ENTER)
            sol_newGame()
        ok
    ok

    BeginDrawing()
        ClearBackground(RAYLIBColor(25, 100, 50, 255))
        if gameState = GS_DEAL or gameState = GS_PLAY or gameState = GS_WIN
            sol_drawTable()
            if gameState = GS_DEAL  sol_drawDealFly()  ok
            if dragging  sol_drawDraggedCards()  ok
            sol_drawHUD()
        ok
        if gameState = GS_WIN
            sol_drawWin()
        ok
        DrawFPS(SCREEN_W - 90, SCREEN_H - 25)
    EndDrawing()

end

UnloadImage(cardsImage)
UnloadTexture(cardsTexture)
sol_unloadAudio()
CloseWindow()
