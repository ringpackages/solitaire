// drawing.ring - Drawing Functions

func sol_updateWinParts
    if winTime < 8.0
        for k = 1 to 3
            add(winParts, [
                GetRandomValue(50, SCREEN_W - 50),
                GetRandomValue(50, SCREEN_H - 50),
                GetRandomValue(-200, 200) / 100.0,
                GetRandomValue(-300, -50) / 100.0,
                2.0,
                GetRandomValue(100, 255),
                GetRandomValue(100, 255),
                GetRandomValue(100, 255)
            ])
        next
    ok

    i = 1
    while i <= len(winParts)
        p = winParts[i]
        p[1] += p[3] * dt * 60       // x += vx
        p[2] += p[4] * dt * 60       // y += vy
        p[4] += 2.0 * dt             // gravity
        p[5] -= dt                    // lifetime
        if p[5] <= 0
            del(winParts, i)
        else
            winParts[i] = p
            i += 1
        ok
    end

// =============================================================
// Drawing: Card from Sprite Sheet
// =============================================================

/*
    Uses DrawTexturePro() with Rectangle() and Vector2() convenience
    functions, following the standard RingRayLib pattern shown in the
    official samples (TextureSource.ring, ImageDrawing.ring).

    The Rectangle() and Vector2() functions (defined in functions.ring)
    create RayLib objects with proper init(). The DrawTexturePro()
    wrapper calls GPData() on each argument to extract the C struct.
*/


func sol_drawCard px, py, nRank, nSuit, faceUp, highlight
    ix = floor(px)
    iy = floor(py)

    if !faceUp
        DrawTexturePro(cardsTexture,
            Rectangle(BACK_COL * SPRITE_CW, BACK_ROW * SPRITE_CH, SPRITE_CW, SPRITE_CH),
            Rectangle(ix, iy, CARD_W, CARD_H),
            Vector2(0, 0), 0.0, WHITE)
        return
    ok

    if highlight
        DrawRectangle(ix - 3, iy - 3, CARD_W + 6, CARD_H + 6,
            RAYLIBColor(255, 255, 0, 200))
    ok

    spriteCol = nRank - 1
    spriteRow = suitToRow[nSuit]
    DrawTexturePro(cardsTexture,
        Rectangle(spriteCol * SPRITE_CW, spriteRow * SPRITE_CH, SPRITE_CW, SPRITE_CH),
        Rectangle(ix, iy, CARD_W, CARD_H),
        Vector2(0, 0), 0.0, WHITE)


func sol_drawSlot px, py, cLabel
    ix = floor(px)
    iy = floor(py)
    DrawRectangleLines(ix, iy, CARD_W, CARD_H, RAYLIBColor(100, 180, 100, 150))
    if cLabel != ""
        lw = MeasureText(cLabel, 16)
        DrawText(cLabel, ix + (CARD_W - lw) / 2, iy + (CARD_H - 16) / 2, 16,
            RAYLIBColor(100, 180, 100, 120))
    ok


func sol_drawTable

    // --- Stock pile ---
    stockX = MARGIN_X
    stockY = ROW_TOP
    nStock = len(stock)
    if nStock > 0
        isHint = (hintTime > 0 and hintSrc = 90)
        sol_drawCard(stockX, stockY, 0, 0, false, isHint)
        DrawText("" + nStock, stockX + 30, stockY + CARD_H + 4, 12,
            RAYLIBColor(200, 220, 200, 200))
    else
        sol_drawSlot(stockX, stockY, "DRAW")
    ok

    // --- Waste pile ---
    wasteX = MARGIN_X + COL_SPACING
    wasteY = ROW_TOP
    if dragging and dragSrcType = SRC_WASTE
        // Show card beneath the one being dragged
        if len(waste) > 1
            showCard = waste[len(waste) - 1]
            sol_drawCard(wasteX, wasteY, showCard[1], showCard[2], true, false)
        else
            sol_drawSlot(wasteX, wasteY, "")
        ok
    else
        if len(waste) > 0
            topCard = waste[len(waste)]
            isHl = (hintTime > 0 and hintSrc = 80)
            sol_drawCard(wasteX, wasteY, topCard[1], topCard[2], true, isHl)
        else
            sol_drawSlot(wasteX, wasteY, "")
        ok
    ok

    // --- Foundation piles ---
    for f = 1 to 4
        fx = MARGIN_X + (f + 2) * COL_SPACING
        fy = ROW_TOP
        fndPile = sol_getFnd(f)
        nFnd = len(fndPile)

        showFnd = nFnd
        if dragging and dragSrcType = SRC_FND and dragSrcCol = f
            showFnd = nFnd - 1
        ok

        isHl = (hintTime > 0 and hintDst = 50 + f)
        if dragging and dropTarget = 2 and dropCol = f  isHl = true  ok

        if showFnd > 0
            topCard = fndPile[showFnd]
            sol_drawCard(fx, fy, topCard[1], topCard[2], true, isHl)
        else
            sol_drawSlot(fx, fy, suitSyms[f])
            if isHl
                DrawRectangle(floor(fx) - 2, floor(fy) - 2, CARD_W + 4, CARD_H + 4,
                    RAYLIBColor(255, 255, 0, 100))
            ok
        ok
    next

    // --- Tableau columns ---
    for c = 1 to 7
        cx = MARGIN_X + (c - 1) * COL_SPACING
        col = sol_getTab(c)
        nCards = len(col)

        drawCount = nCards
        // During deal animation, only show revealed cards
        if gameState = GS_DEAL
            drawCount = sol_getDealShow(c)
        ok
        if dragging and dragSrcType = SRC_TABLEAU and dragSrcCol = c
            drawCount = dragSrcIdx - 1
        ok

        isHlCol = (hintTime > 0 and hintDst = c)
        if dragging and dropTarget = 1 and dropCol = c  isHlCol = true  ok

        if drawCount = 0
            sol_drawSlot(cx, ROW_TAB, "K")
            if isHlCol
                DrawRectangle(floor(cx) - 2, floor(ROW_TAB) - 2, CARD_W + 4, CARD_H + 4,
                    RAYLIBColor(255, 255, 0, 100))
            ok
        else
            cy = ROW_TAB
            for i = 1 to drawCount
                card = col[i]
                isHl = false
                if isHlCol and i = drawCount  isHl = true  ok
                if hintTime > 0 and hintSrc = c and i = nCards  isHl = true  ok
                sol_drawCard(cx, cy, card[1], card[2], card[3], isHl)
                if card[3]
                    cy += FACE_GAP
                else
                    cy += CARD_GAP
                ok
            next
        ok
    next


func sol_drawDraggedCards
    nDrag = len(dragCards)
    if nDrag = 0  return  ok

    // Drop shadow
    DrawRectangle(floor(dragX) + 5, floor(dragY) + 5,
        CARD_W, CARD_H + (nDrag - 1) * FACE_GAP,
        RAYLIBColor(0, 0, 0, 80))

    cy = dragY
    for i = 1 to nDrag
        card = dragCards[i]
        sol_drawCard(dragX, cy, card[1], card[2], true, false)
        cy += FACE_GAP
    next


func sol_drawDealFly
    if !dealFlying  return  ok
    if dealVisible < 1 or dealVisible > len(dealQueue)  return  ok

    // The flying card is the next unrevealed card in this column
    flyCol = dealQueue[dealVisible]
    flyIdx = sol_getDealShow(flyCol) + 1   // Next card to be revealed

    // Get card data from the actual tableau
    col = sol_getTab(flyCol)
    if flyIdx > len(col)  return  ok
    card = col[flyIdx]

    // Source: stock pile position
    srcX = MARGIN_X
    srcY = ROW_TOP

    // Target: card position in tableau column
    dstX = MARGIN_X + (flyCol - 1) * COL_SPACING
    dstY = ROW_TAB
    for k = 1 to flyIdx - 1
        dstY += CARD_GAP
    next

    // Interpolate with easeOut (smooth deceleration)
    t = dealFlyT
    easeT = 1 - (1 - t) * (1 - t)

    // Position: linear interpolation along x and y
    curX = srcX + (dstX - srcX) * easeT
    curY = srcY + (dstY - srcY) * easeT

    // Sine wave offset perpendicular to path (arc above)
    curY -= sin(t * 3.14159) * DEAL_WAVE

    // Draw shadow
    DrawRectangle(floor(curX) + 4, floor(curY) + 4, CARD_W, CARD_H,
        RAYLIBColor(0, 0, 0, 60))

    // Draw the card face-down while flying
    sol_drawCard(curX, curY, card[1], card[2], false, false)


func sol_drawHUD
    DrawRectangle(0, SCREEN_H - 40, SCREEN_W, 40, RAYLIBColor(20, 60, 30, 200))
    DrawText("Moves: " + moveCount, 20, SCREEN_H - 30, 16,
        RAYLIBColor(200, 220, 200, 220))
    DrawText("Score: " + score, 160, SCREEN_H - 30, 16,
        RAYLIBColor(255, 220, 100, 220))
    DrawText("N=New  U=Undo  H=Hint  M=Mute  RClick=Send",
        320, SCREEN_H - 30, 14, RAYLIBColor(150, 180, 150, 180))


func sol_drawWin
    // Particles
    for i = 1 to len(winParts)
        p = winParts[i]
        alpha = floor(p[5] / 2.0 * 255)
        if alpha > 255  alpha = 255  ok
        if alpha < 0    alpha = 0    ok
        sz = floor(4 + p[5] * 3)
        DrawRectangle(floor(p[1]) - sz/2, floor(p[2]) - sz/2, sz, sz,
            RAYLIBColor(p[6], p[7], p[8], alpha))
    next

    // Victory banner
    DrawRectangle(SCREEN_W/4, SCREEN_H/3, SCREEN_W/2, SCREEN_H/3,
        RAYLIBColor(0, 0, 0, 180))
    DrawRectangleLines(SCREEN_W/4, SCREEN_H/3, SCREEN_W/2, SCREEN_H/3,
        RAYLIBColor(255, 215, 0, 200))

    t1 = "YOU WIN!"
    t1w = MeasureText(t1, 48)
    pulse = sin(animTime * 4) * 5
    DrawText(t1, (SCREEN_W - t1w)/2, SCREEN_H/3 + 30 + floor(pulse), 48,
        RAYLIBColor(255, 215, 0, 255))

    t2 = "Score: " + score + "   Moves: " + moveCount
    t2w = MeasureText(t2, 20)
    DrawText(t2, (SCREEN_W - t2w)/2, SCREEN_H/3 + 90, 20, WHITE)

    t3 = "Press N or ENTER for New Game"
    t3w = MeasureText(t3, 18)
    DrawText(t3, (SCREEN_W - t3w)/2, SCREEN_H/3 + 130, 18,
        RAYLIBColor(180, 200, 180, 200))


