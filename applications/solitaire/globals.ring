// globals.ring - Constants and Global State

// =============================================================
// Constants
// =============================================================

// Screen dimensions
SCREEN_W    = 1024
SCREEN_H    = 768

// Card display dimensions (scaled from sprite)
CARD_W      = 80
CARD_H      = 110
CARD_GAP    = 22      // Vertical gap for face-down cards in tableau
FACE_GAP    = 30      // Vertical gap for face-up cards in tableau

// Layout
MARGIN_X    = 40
MARGIN_Y    = 30
COL_SPACING = CARD_W + 16
ROW_TOP     = MARGIN_Y
ROW_TAB     = MARGIN_Y + CARD_H + 30

// Hit-test tolerance for drag-and-drop
HIT_PAD     = 10

// Suits
SUIT_HEART  = 1
SUIT_DIAM   = 2
SUIT_CLUB   = 3
SUIT_SPADE  = 4

// Game states
GS_PLAY     = 1
GS_WIN      = 2
GS_DEAL     = 3

// Drag source types
SRC_TABLEAU = 1
SRC_WASTE   = 8
SRC_FND     = 9

// Sprite sheet: each card cell is 79x123 pixels
SPRITE_CW   = 79
SPRITE_CH   = 123

// Map game suit index to sprite row
// SUIT_HEART=1->row2, SUIT_DIAM=2->row1, SUIT_CLUB=3->row0, SUIT_SPADE=4->row3
suitToRow   = [2, 1, 0, 3]

// Card back: row 4, column 0
BACK_COL    = 0
BACK_ROW    = 4

// =============================================================
// Global State
// =============================================================

gameState   = GS_PLAY
animTime    = 0.0
dt          = 0.0
moveCount   = 0
score       = 0

// Tableau columns (7 piles)
tab1 = []  tab2 = []  tab3 = []  tab4 = []
tab5 = []  tab6 = []  tab7 = []

// Foundation piles (4 piles, one per suit)
fnd1 = []  fnd2 = []  fnd3 = []  fnd4 = []

// Stock and waste piles
stock = []
waste = []

// Drag state
dragging    = false
dragCards   = []
dragSrcType = 0
dragSrcCol  = 0
dragSrcIdx  = 0
dragOffX    = 0.0
dragOffY    = 0.0
dragX       = 0.0
dragY       = 0.0

// Undo stack - each entry is a list describing the action
undoStack   = []

// Hint highlight
hintSrc     = 0
hintDst     = 0
hintTime    = 0.0

// Drop target highlight (while dragging)
dropTarget  = 0
dropCol     = 0

// Win celebration
winTime     = 0.0
winParts    = []

// Display helpers
suitSyms    = ["H", "D", "C", "S"]

// Deal animation state
dealQueue   = []      // Order of dealing: each entry is a column number
dealVisible = 0       // How many entries from dealQueue have been revealed
dealTimer   = 0.0     // Time accumulator for dealing pace
DEAL_SPEED  = 0.04    // Seconds between starting each card deal
DEAL_FLY    = 0.075   // Seconds for one card to fly to its target
dealFlyT    = 0.0     // Current flying card progress (0.0 to 1.0)
dealFlying  = false   // Is a card currently in flight?
DEAL_WAVE   = 60      // Sine wave amplitude (pixels)
// How many cards to show per column during deal (all 7 start at 0)
dealShow1 = 0  dealShow2 = 0  dealShow3 = 0  dealShow4 = 0
dealShow5 = 0  dealShow6 = 0  dealShow7 = 0

// Audio - sounds and music (loaded after InitAudioDevice)
sndCardPlace  = NULL
sndCardPickup = NULL
sndCardFnd    = NULL
sndStockClick = NULL
sndInvalid    = NULL
sndUndo       = NULL
sndHint       = NULL
sndWin        = NULL
sndShuffle    = NULL
bgMusic       = NULL
musicPaused   = false
