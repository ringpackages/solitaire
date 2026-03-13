// input.ring - Input Handling

func sol_handleMouse
    mx = GetMouseX()
    my = GetMouseY()

    if IsMouseButtonPressed(MOUSE_RIGHT_BUTTON)
        if !dragging  sol_autoSendClick()  ok
        return
    ok

    if IsMouseButtonPressed(MOUSE_LEFT_BUTTON)
        if !dragging  sol_tryPickUp(mx, my)  ok
    ok

    if IsMouseButtonDown(MOUSE_LEFT_BUTTON)
        if dragging
            dragX = mx - dragOffX
            dragY = my - dragOffY
            sol_findDropTarget(mx, my)
        ok
    ok

    if IsMouseButtonReleased(MOUSE_LEFT_BUTTON)
        if dragging  sol_dropCards(mx, my)  ok
    ok


func sol_tryPickUp mx, my

    // Stock pile: click to draw, no dragging
    stockX = MARGIN_X
    stockY = ROW_TOP
    if sol_hitTest(mx, my, stockX, stockY, CARD_W, CARD_H, 0)
        sol_clickStock()
        return
    ok

    // Waste pile: pick up top card
    wasteX = MARGIN_X + COL_SPACING
    wasteY = ROW_TOP
    if len(waste) > 0
        if sol_hitTest(mx, my, wasteX, wasteY, CARD_W, CARD_H, 0)
            dragging    = true
            dragSrcType = SRC_WASTE
            dragSrcCol  = 0
            dragSrcIdx  = len(waste)
            dragCards   = [waste[len(waste)]]
            dragOffX    = mx - wasteX
            dragOffY    = my - wasteY
            dragX       = wasteX
            dragY       = wasteY
            PlaySound(sndCardPickup)
            return
        ok
    ok

    // Foundation piles: pick up top card
    for f = 1 to 4
        fx = MARGIN_X + (f + 2) * COL_SPACING
        fy = ROW_TOP
        fndPile = sol_getFnd(f)
        if len(fndPile) > 0
            if sol_hitTest(mx, my, fx, fy, CARD_W, CARD_H, 0)
                dragging    = true
                dragSrcType = SRC_FND
                dragSrcCol  = f
                dragSrcIdx  = len(fndPile)
                dragCards   = [fndPile[len(fndPile)]]
                dragOffX    = mx - fx
                dragOffY    = my - fy
                dragX       = fx
                dragY       = fy
                PlaySound(sndCardPickup)
                return
            ok
        ok
    next

    // Tableau: pick up face-up card and all cards below it
    for c = 1 to 7
        col = sol_getTab(c)
        cx = MARGIN_X + (c - 1) * COL_SPACING
        nCards = len(col)
        if nCards = 0  loop  ok

        for i = nCards to 1 step -1
            if !col[i][3]  loop  ok
            cy = sol_cardY(col, i)
            cardBot = cy + CARD_H
            if i < nCards
                cardBot = sol_cardY(col, i + 1)
            ok
            if mx >= cx and mx <= cx + CARD_W and my >= cy and my < cardBot
                dragging    = true
                dragSrcType = SRC_TABLEAU
                dragSrcCol  = c
                dragSrcIdx  = i
                dragCards   = []
                for j = i to nCards
                    add(dragCards, col[j])
                next
                dragOffX = mx - cx
                dragOffY = my - cy
                dragX    = cx
                dragY    = cy
                PlaySound(sndCardPickup)
                return
            ok
        next
    next


func sol_clickStock
    nStock = len(stock)
    if nStock > 0
        card = stock[nStock]
        del(stock, nStock)
        card[3] = true
        add(waste, card)
        add(undoStack, ["stock_to_waste"])
        moveCount += 1
        PlaySound(sndStockClick)
    else
        nWaste = len(waste)
        if nWaste > 0
            add(undoStack, ["recycle", nWaste])
            for i = nWaste to 1 step -1
                card = waste[i]
                card[3] = false
                add(stock, card)
            next
            waste = []
            moveCount += 1
            PlaySound(sndShuffle)
        ok
    ok


func sol_findDropTarget mx, my
    dropTarget = 0
    dropCol = 0
    nDrag = len(dragCards)
    if nDrag = 0  return  ok
    card = dragCards[1]

    // Foundation (single card only)
    if nDrag = 1
        for f = 1 to 4
            fx = MARGIN_X + (f + 2) * COL_SPACING
            fy = ROW_TOP
            if sol_hitTest(mx, my, fx, fy, CARD_W, CARD_H, HIT_PAD)
                if sol_canStackFnd(sol_getFnd(f), card)
                    dropTarget = 2
                    dropCol = f
                    return
                ok
            ok
        next
    ok

    // Tableau columns
    for c = 1 to 7
        cx = MARGIN_X + (c - 1) * COL_SPACING
        col = sol_getTab(c)
        nCards = len(col)

        effCards = nCards
        if dragSrcType = SRC_TABLEAU and dragSrcCol = c
            effCards = dragSrcIdx - 1
        ok

        if effCards = 0
            if sol_hitTest(mx, my, cx, ROW_TAB, CARD_W, CARD_H + 50, HIT_PAD)
                if card[1] = 13
                    if dragSrcType = SRC_TABLEAU and dragSrcCol = c  loop  ok
                    dropTarget = 1
                    dropCol = c
                    return
                ok
            ok
        else
            topY = sol_cardY(col, effCards)
            if mx >= cx - HIT_PAD and mx <= cx + CARD_W + HIT_PAD and
               my >= topY - 30 and my <= topY + CARD_H + 50
                if dragSrcType = SRC_TABLEAU and dragSrcCol = c  loop  ok
                topCard = col[effCards]
                if topCard[3] and sol_canStackTab(topCard, card)
                    dropTarget = 1
                    dropCol = c
                    return
                ok
            ok
        ok
    next


func sol_dropCards mx, my
    if !dragging  return  ok
    nDrag = len(dragCards)
    if nDrag = 0
        dragging = false
        return
    ok

    sol_findDropTarget(mx, my)
    card = dragCards[1]
    placed = false

    // Drop on foundation
    if dropTarget = 2 and nDrag = 1
        fndPile = sol_getFnd(dropCol)
        if sol_canStackFnd(fndPile, card)
            sol_removeDragFromSource()
            add(fndPile, card)
            sol_setFnd(dropCol, fndPile)
            add(undoStack, ["to_fnd", dragSrcType, dragSrcCol, dragSrcIdx, dropCol])
            moveCount += 1
            score += 10
            if dragSrcType = SRC_TABLEAU  sol_flipTopCard(dragSrcCol)  ok
            placed = true
            PlaySound(sndCardFnd)
        ok
    ok

    // Drop on tableau
    if !placed and dropTarget = 1
        col = sol_getTab(dropCol)
        nCol = len(col)
        canPlace = false

        if nCol = 0
            if dragSrcType = SRC_TABLEAU and dragSrcCol = dropCol
                canPlace = false
            but card[1] = 13
                canPlace = true
            ok
        else
            if dragSrcType = SRC_TABLEAU and dragSrcCol = dropCol
                canPlace = false
            else
                topCard = col[nCol]
                if topCard[3] and sol_canStackTab(topCard, card)
                    canPlace = true
                ok
            ok
        ok

        if canPlace
            sol_removeDragFromSource()
            for i = 1 to nDrag
                sc = dragCards[i]
                sc[3] = true
                add(col, sc)
            next
            sol_setTab(dropCol, col)
            add(undoStack, ["to_tab", dragSrcType, dragSrcCol, dragSrcIdx, dropCol, nDrag])
            moveCount += 1
            score += 5
            if dragSrcType = SRC_TABLEAU  sol_flipTopCard(dragSrcCol)  ok
            placed = true
            PlaySound(sndCardPlace)
        ok
    ok

    // Invalid drop - card returns to source
    if !placed
        PlaySound(sndInvalid)
    ok

    dragging = false
    dragCards = []
    dropTarget = 0
    dropCol = 0


func sol_removeDragFromSource

    if dragSrcType = SRC_WASTE
        if len(waste) > 0
            del(waste, len(waste))
        ok
    ok

    if dragSrcType = SRC_FND
        fndPile = sol_getFnd(dragSrcCol)
        if len(fndPile) > 0
            del(fndPile, len(fndPile))
            sol_setFnd(dragSrcCol, fndPile)
        ok
    ok

    if dragSrcType = SRC_TABLEAU
        col = sol_getTab(dragSrcCol)
        nDrag = len(dragCards)
        for i = 1 to nDrag
            nNow = len(col)
            if nNow >= dragSrcIdx
                del(col, nNow)
            ok
        next
        sol_setTab(dragSrcCol, col)
    ok


func sol_autoSendClick
    mx = GetMouseX()
    my = GetMouseY()

    // Try waste pile: first to foundation, then to tableau
    wasteX = MARGIN_X + COL_SPACING
    wasteY = ROW_TOP
    if len(waste) > 0
        if sol_hitTest(mx, my, wasteX, wasteY, CARD_W, CARD_H, 5)
            if sol_trySendToFnd(waste, len(waste), SRC_WASTE, 0)  return  ok
            if sol_trySendToTab(waste, len(waste), SRC_WASTE, 0)  return  ok
            return
        ok
    ok

    // Try clicked tableau column: first to foundation, then to another column
    for c = 1 to 7
        col = sol_getTab(c)
        nCards = len(col)
        if nCards = 0  loop  ok
        cx = MARGIN_X + (c - 1) * COL_SPACING
        lastY = sol_cardY(col, nCards)
        colBottom = lastY + CARD_H
        if mx >= cx and mx <= cx + CARD_W and my >= ROW_TAB and my <= colBottom
            if !col[nCards][3]  loop  ok
            if sol_trySendToFnd(col, nCards, SRC_TABLEAU, c)  return  ok
            if sol_trySendToTab(col, nCards, SRC_TABLEAU, c)  return  ok
        ok
    next

    // Fallback: try any available card
    if len(waste) > 0
        if sol_trySendToFnd(waste, len(waste), SRC_WASTE, 0)  return  ok
        if sol_trySendToTab(waste, len(waste), SRC_WASTE, 0)  return  ok
    ok
    for c = 1 to 7
        col = sol_getTab(c)
        nCards = len(col)
        if nCards = 0  loop  ok
        if !col[nCards][3]  loop  ok
        if sol_trySendToFnd(col, nCards, SRC_TABLEAU, c)  return  ok
        if sol_trySendToTab(col, nCards, SRC_TABLEAU, c)  return  ok
    next


func sol_trySendToFnd aPile, nIdx, nSrcType, nSrcCol
    card = aPile[nIdx]
    for f = 1 to 4
        fndPile = sol_getFnd(f)
        if sol_canStackFnd(fndPile, card)
            del(aPile, nIdx)
            if nSrcType = SRC_TABLEAU
                sol_setTab(nSrcCol, aPile)
            ok
            add(fndPile, card)
            sol_setFnd(f, fndPile)
            add(undoStack, ["to_fnd", nSrcType, nSrcCol, nIdx, f])
            moveCount += 1
            score += 10
            if nSrcType = SRC_TABLEAU  sol_flipTopCard(nSrcCol)  ok
            PlaySound(sndCardFnd)
            return true
        ok
    next
    return false


func sol_trySendToTab aPile, nIdx, nSrcType, nSrcCol
    card = aPile[nIdx]
    for d = 1 to 7
        // Don't move to same column
        if nSrcType = SRC_TABLEAU and d = nSrcCol  loop  ok
        dstCol = sol_getTab(d)
        nDst = len(dstCol)
        canMove = false
        if nDst = 0
            if card[1] = 13  canMove = true  ok
        else
            if dstCol[nDst][3] and sol_canStackTab(dstCol[nDst], card)
                canMove = true
            ok
        ok
        if canMove
            del(aPile, nIdx)
            if nSrcType = SRC_TABLEAU
                sol_setTab(nSrcCol, aPile)
            ok
            add(dstCol, card)
            sol_setTab(d, dstCol)
            add(undoStack, ["to_tab", nSrcType, nSrcCol, nIdx, d, 1])
            moveCount += 1
            score += 5
            if nSrcType = SRC_TABLEAU  sol_flipTopCard(nSrcCol)  ok
            PlaySound(sndCardPlace)
            return true
        ok
    next
    return false


