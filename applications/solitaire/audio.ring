// audio.ring - Audio Loading and Unloading

func sol_loadAudio
    InitAudioDevice()
    sndCardPlace  = LoadSound("sound/card_place.wav")
    sndCardPickup = LoadSound("sound/card_pickup.wav")
    sndCardFnd    = LoadSound("sound/card_fnd.wav")
    sndStockClick = LoadSound("sound/stock_click.wav")
    sndInvalid    = LoadSound("sound/invalid.wav")
    sndUndo       = LoadSound("sound/undo.wav")
    sndHint       = LoadSound("sound/hint.wav")
    sndWin        = LoadSound("sound/win.wav")
    sndShuffle    = LoadSound("sound/shuffle.wav")
    bgMusic = LoadMusicStream("sound/bgmusic.wav")
    SetMusicVolume(bgMusic, 1.0)
    PlayMusicStream(bgMusic)

func sol_unloadAudio
    UnloadMusicStream(bgMusic)
    UnloadSound(sndCardPlace)
    UnloadSound(sndCardPickup)
    UnloadSound(sndCardFnd)
    UnloadSound(sndStockClick)
    UnloadSound(sndInvalid)
    UnloadSound(sndUndo)
    UnloadSound(sndHint)
    UnloadSound(sndWin)
    UnloadSound(sndShuffle)
    CloseAudioDevice()
