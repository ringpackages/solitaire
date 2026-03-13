// undo.ring - Undo and Hint

func sol_undo
    nUndo = len(undoStack)
    if nUndo = 0  return  ok

    action = undoStack[nUndo]
    del(undoStack, nUndo)
    aType = action[1]
    PlaySound(sndUndo)

    if aType = "stock_to_waste"
        nW = len(waste)
        if nW > 0
            card = waste[nW]
            del(waste, nW)
            card[3] = false
            add(stock, card)
        ok
    ok

    if aType = "recycle"
        recycleCount = action[2]
        nS = len(stock)
        for i = nS to nS - recycleCount + 1 step -1
            if i >= 1
                card = stock[i]
                card[3] = true
                add(waste, card)
                del(stock, i)
            ok
        next
    ok

    if aType = "to_fnd"
        srcType = action[2]
        srcCol  = action[3]
        srcIdx  = action[4]
        fNum    = action[5]
        fndPile = sol_getFnd(fNum)
        nF = len(fndPile)
        if nF > 0
            card = fndPile[nF]
            del(fndPile, nF)
            sol_setFnd(fNum, fndPile)
            if srcType = SRC_WASTE
                add(waste, card)
            but srcType = SRC_FND
                fndSrc = sol_getFnd(srcCol)
                add(fndSrc, card)
                sol_setFnd(srcCol, fndSrc)
            else
                col = sol_getTab(srcCol)
                if len(col) > 0 and srcIdx > len(col)
                    col[len(col)][3] = false
                ok
                add(col, card)
                sol_setTab(srcCol, col)
            ok
        ok
        score -= 10
    ok

    if aType = "to_tab"
        srcType = action[2]
        srcCol  = action[3]
        srcIdx  = action[4]
        dstCol  = action[5]
        nMoved  = action[6]
        dstList = sol_getTab(dstCol)
        movedCards = []
        nDst = len(dstList)
        for i = 1 to nMoved
            add(movedCards, dstList[nDst - nMoved + i])
        next
        for i = 1 to nMoved
            del(dstList, len(dstList))
        next
        sol_setTab(dstCol, dstList)

        if srcType = SRC_WASTE
            for i = 1 to len(movedCards)
                add(waste, movedCards[i])
            next
        but srcType = SRC_FND
            fndSrc = sol_getFnd(srcCol)
            for i = 1 to len(movedCards)
                add(fndSrc, movedCards[i])
            next
            sol_setFnd(srcCol, fndSrc)
        else
            srcList = sol_getTab(srcCol)
            if len(srcList) > 0 and srcIdx > len(srcList)
                srcList[len(srcList)][3] = false
            ok
            for i = 1 to len(movedCards)
                add(srcList, movedCards[i])
            next
            sol_setTab(srcCol, srcList)
        ok
        score -= 5
    ok

    moveCount -= 1
    if moveCount < 0  moveCount = 0  ok
    if score < 0  score = 0  ok


func sol_findHint

    // Try waste -> foundation
    if len(waste) > 0
        card = waste[len(waste)]
        for f = 1 to 4
            if sol_canStackFnd(sol_getFnd(f), card)
                hintSrc = 80  hintDst = 50 + f  hintTime = 2.0
                return
            ok
        next
        // Try waste -> tableau
        for c = 1 to 7
            col = sol_getTab(c)
            nCards = len(col)
            if nCards = 0
                if card[1] = 13
                    hintSrc = 80  hintDst = c  hintTime = 2.0
                    return
                ok
            else
                if col[nCards][3] and sol_canStackTab(col[nCards], card)
                    hintSrc = 80  hintDst = c  hintTime = 2.0
                    return
                ok
            ok
        next
    ok

    // Try tableau top card -> foundation
    for c = 1 to 7
        col = sol_getTab(c)
        nCards = len(col)
        if nCards = 0  loop  ok
        card = col[nCards]
        if !card[3]  loop  ok
        for f = 1 to 4
            if sol_canStackFnd(sol_getFnd(f), card)
                hintSrc = c  hintDst = 50 + f  hintTime = 2.0
                return
            ok
        next
    next

    // Try tableau -> tableau (move runs starting from first face-up)
    for c = 1 to 7
        col = sol_getTab(c)
        nCards = len(col)
        if nCards = 0  loop  ok
        // Find first face-up card
        firstUp = 0
        for i = 1 to nCards
            if col[i][3]
                firstUp = i
                exit
            ok
        next
        if firstUp = 0  loop  ok
        card = col[firstUp]
        for d = 1 to 7
            if d = c  loop  ok
            dCol = sol_getTab(d)
            nDst = len(dCol)
            if nDst = 0
                if card[1] = 13 and firstUp > 1
                    hintSrc = c  hintDst = d  hintTime = 2.0
                    return
                ok
            else
                if dCol[nDst][3] and sol_canStackTab(dCol[nDst], card)
                    hintSrc = c  hintDst = d  hintTime = 2.0
                    return
                ok
            ok
        next
    next

    // Suggest drawing from stock
    if len(stock) > 0
        hintSrc = 90  hintDst = 90  hintTime = 2.0
    ok


