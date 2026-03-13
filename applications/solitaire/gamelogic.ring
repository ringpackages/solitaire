// gamelogic.ring - Game Logic

func sol_newGame

    // Build and shuffle deck: each card = [rank, suit, faceUp]
    deck = []
    for nSuit = 1 to 4
        for nRank = 1 to 13
            add(deck, [nRank, nSuit, false])
        next
    next
    for i = len(deck) to 2 step -1
        j = GetRandomValue(1, i)
        tmp = deck[i]
        deck[i] = deck[j]
        deck[j] = tmp
    next

    // Reset all game state
    tab1 = []  tab2 = []  tab3 = []  tab4 = []
    tab5 = []  tab6 = []  tab7 = []
    fnd1 = []  fnd2 = []  fnd3 = []  fnd4 = []
    stock = []  waste = []
    dragging = false  dragCards = []
    dragSrcType = 0  dragSrcCol = 0  dragSrcIdx = 0
    undoStack = []
    hintSrc = 0  hintDst = 0  hintTime = 0.0
    moveCount = 0  score = 0
    winTime = 0.0  winParts = []
    dropTarget = 0  dropCol = 0

    // Deal cards to tableau directly (proven original approach)
    // Each tab gets its cards with top card face-up
    di = 1
    for c = 1 to 1
        add(tab1, deck[di])  di += 1
    next
    for c = 1 to 2
        add(tab2, deck[di])  di += 1
    next
    for c = 1 to 3
        add(tab3, deck[di])  di += 1
    next
    for c = 1 to 4
        add(tab4, deck[di])  di += 1
    next
    for c = 1 to 5
        add(tab5, deck[di])  di += 1
    next
    for c = 1 to 6
        add(tab6, deck[di])  di += 1
    next
    for c = 1 to 7
        add(tab7, deck[di])  di += 1
    next

    tab1[len(tab1)][3] = true
    tab2[len(tab2)][3] = true
    tab3[len(tab3)][3] = true
    tab4[len(tab4)][3] = true
    tab5[len(tab5)][3] = true
    tab6[len(tab6)][3] = true
    tab7[len(tab7)][3] = true

    // Remaining cards go to stock
    for i = di to 52
        card = deck[i]
        card[3] = false
        add(stock, card)
    next

    // Build deal animation order: column by column
    // Record how many cards each column should show at each step
    dealQueue = []
    for nC = 1 to 7
        for nP = 1 to nC
            add(dealQueue, nC)
        next
    next
    dealVisible = 0
    dealTimer = 0.0
    dealFlyT = 0.0
    dealFlying = false
    dealShow1 = 0  dealShow2 = 0  dealShow3 = 0  dealShow4 = 0
    dealShow5 = 0  dealShow6 = 0  dealShow7 = 0

    // Start deal animation
    gameState = GS_DEAL
    PlaySound(sndShuffle)


func sol_getTab nCol
    switch nCol
        on 1  return tab1
        on 2  return tab2
        on 3  return tab3
        on 4  return tab4
        on 5  return tab5
        on 6  return tab6
        on 7  return tab7
    off
    return []


func sol_setTab nCol, aList
    switch nCol
        on 1  tab1 = aList
        on 2  tab2 = aList
        on 3  tab3 = aList
        on 4  tab4 = aList
        on 5  tab5 = aList
        on 6  tab6 = aList
        on 7  tab7 = aList
    off


func sol_getFnd nPile
    switch nPile
        on 1  return fnd1
        on 2  return fnd2
        on 3  return fnd3
        on 4  return fnd4
    off
    return []


func sol_setFnd nPile, aList
    switch nPile
        on 1  fnd1 = aList
        on 2  fnd2 = aList
        on 3  fnd3 = aList
        on 4  fnd4 = aList
    off


func sol_getDealShow nCol
    switch nCol
        on 1  return dealShow1
        on 2  return dealShow2
        on 3  return dealShow3
        on 4  return dealShow4
        on 5  return dealShow5
        on 6  return dealShow6
        on 7  return dealShow7
    off
    return 0


func sol_incDealShow nCol
    switch nCol
        on 1  dealShow1 += 1
        on 2  dealShow2 += 1
        on 3  dealShow3 += 1
        on 4  dealShow4 += 1
        on 5  dealShow5 += 1
        on 6  dealShow6 += 1
        on 7  dealShow7 += 1
    off


func sol_isRed nSuit
    if nSuit = SUIT_HEART or nSuit = SUIT_DIAM  return true  ok
    return false


func sol_canStackTab topCard, botCard
    if topCard[1] != botCard[1] + 1  return false  ok
    if sol_isRed(topCard[2]) = sol_isRed(botCard[2])  return false  ok
    return true


func sol_canStackFnd fndPile, card
    nFnd = len(fndPile)
    if nFnd = 0
        return card[1] = 1
    ok
    topCard = fndPile[nFnd]
    if card[2] != topCard[2]  return false  ok
    if card[1] != topCard[1] + 1  return false  ok
    return true


func sol_cardY aCol, nIdx
    nY = ROW_TAB
    for k = 1 to nIdx - 1
        if aCol[k][3]
            nY += FACE_GAP
        else
            nY += CARD_GAP
        ok
    next
    return nY


func sol_flipTopCard nCol
    if nCol < 1 or nCol > 7  return  ok
    col = sol_getTab(nCol)
    nLen = len(col)
    if nLen > 0
        if !col[nLen][3]
            col[nLen][3] = true
            sol_setTab(nCol, col)
        ok
    ok


func sol_hitTest mx, my, rx, ry, rw, rh, nPad
    if mx >= rx - nPad and mx <= rx + rw + nPad and
       my >= ry - nPad and my <= ry + rh + nPad
        return true
    ok
    return false


func sol_checkWin
    if len(fnd1) = 13 and len(fnd2) = 13 and
       len(fnd3) = 13 and len(fnd4) = 13
        if gameState != GS_WIN
            gameState = GS_WIN
            winTime = 0.0
            winParts = []
            PlaySound(sndWin)
        ok
    ok


