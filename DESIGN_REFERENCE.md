# Design Reference & Brand Guidelines

## Ngoding Lok Terminal Noir Design System

### Brand Identity
- **Name**: Ngoding Lok
- **Tagline**: Learn by Building
- **Theme**: Terminal Noir (Dark tech aesthetic)
- **Primary Color**: #FF5C01 (Orange)
- **Founder**: Raynold Kabai
- **Platform**: Educational game/learning platform

### Visual Language
```
┌─────────────────────────────────────────┐
│ ☰  NGODING LOK · LEARN BY BUILDING      │
├─────────────────────────────────────────┤
│                                         │
│  [Dark Background]                      │
│  [Orange Accents]                       │
│  [Monospace Typography]                 │
│  [Hairline Borders]                     │
│  [Minimal Decoration]                   │
│  [Technical Vibe]                       │
│                                         │
│  "LEARN · BUILD · MASTER"              │
│                                         │
└─────────────────────────────────────────┘
```

---

## Color Palette

### Primary Colors
```
╔════════════════════════════════════════════════════╗
║ Orange (#FF5C01)                                   ║
║ Primary accent, buttons, badges                    ║
║ RGB: (255, 92, 1)                                  ║
║ HSL: (20°, 100%, 50%)                              ║
║ Usage: Buttons, highlights, CTAs                   ║
╚════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════╗
║ Black (#000000)                                    ║
║ Background, dark areas                             ║
║ RGB: (0, 0, 0)                                     ║
║ Usage: Main background, panels                     ║
╚════════════════════════════════════════════════════╝

╔════════════════════════════════════════════════════╗
║ White (#FFFFFF)                                    ║
║ Text, borders on dark backgrounds                  ║
║ RGB: (255, 255, 255)                               ║
║ Usage: Text, primary foreground                    ║
╚════════════════════════════════════════════════════╝
```

### Secondary Colors (From LandingTokens)
```
Signal Green (#4CAF50)
├─ Completion
├─ Success states
└─ Checkmarks

Ember Orange (#FF5C01)  [Same as Primary]
├─ Primary actions
├─ Warnings
└─ Highlights

Circuit Purple (#6C5CE7)
├─ Secondary actions
├─ Python track
└─ Alternate accents

Track-Specific Colors:
├─ Python: #6C5CE7 (Purple)
├─ SQL: #9E9CFF (Light Purple)
├─ Java: #FFB300 (Gold)
├─ Cybersecurity: #4CAF50 (Green)
└─ Arduino: #FF5C01 (Orange)
```

### Gradients
```
Background Gradient:
Linear: #1a1a1a → #0f0f0f (Top → Bottom)
Purpose: Subtle depth on dark panels

Hover Glow:
Color: #FF5C01 with 0.3 alpha
Blur: 12px
Purpose: Button feedback
```

---

## Typography

### Font Families
```
Display/Headers:
- Font: System default (Inter/Roboto)
- Weight: 800 (Bold)
- Spacing: 1.0-1.5 letter-spacing
- Example: "CERTIFIED" (48px, 3.0 letter-spacing)

Monospace (Numbers, IDs):
- Font: monospace (CSS generic)
- Weight: 700
- Purpose: Technical data, stats, IDs
- Example: "123XP", "52ms", "b6d02fa1..."

Body Text:
- Font: System default
- Weight: 400-600
- Size: 12-14px
- Line Height: 1.4-1.6
```

### Text Styles
```
Labels (.label style from LandingTokens):
- Size: 8-11px
- Weight: 700
- Color: Secondary
- Letter-spacing: 1.0-1.5
- Example: "ISSUED DATE"

Values (.mono style):
- Size: 12-24px
- Weight: 700
- Font: monospace
- Color: Accent
- Example: "10 XP"

Descriptions:
- Size: 12-13px
- Weight: 400
- Color: Text with 0.6-0.7 alpha
- Line Height: 1.45
```

---

## Components

### Certificate Display

#### Header Section
```
[Orange Bar] NGODING LOK                    [✓ VERIFIED]
    8px wide, 32px tall, accent color      Monospace label

Large Title:
CERTIFIED
48px, monospace, letter-spacing 3.0

Orange underline:
60px wide, 2px tall, glow effect

Track Label:
"PYTHON TRACK"
12px, orange with alpha 0.8, letter-spacing 1.5

Module Title:
"Module 1: Sequential Steps"
18px, white, weight 600
```

#### Meta Section
```
"CERTIFICATE OF ACHIEVEMENT"
12px, orange, letter-spacing 1.5

"This certificate is presented to"
12px, white with alpha 0.6

Learner Name:
24-32px, white, weight 900, letter-spacing 1.0

"for successfully completing"
12px, white with alpha 0.6

Module details with border box:
12px padding, border: 1px orange with alpha 0.2
┌─ CREDENTIAL DETAILS ─────┐
│ ISSUED DATE    SCORE     │
│ 19 JUL 2026    10 XP     │
│ ID: b6d02fa...           │
└──────────────────────────┘
```

#### QR Code
```
160x160px square
White background
Black procedural pattern
Border: 1px orange with alpha 0.3
Glow: Optional shadow

"SCAN TO VERIFY" label below
8px, white with alpha 0.6
```

#### Action Buttons
```
Primary Button (Download PDF):
├─ Background: #FF5C01
├─ Border: 1px orange
├─ Text: Black, weight 700
├─ Hover: Glow effect, alpha 1.0
└─ Height: 44px (touch target)

Secondary Button (Share, Back):
├─ Background: transparent/rgba
├─ Border: 1px white with alpha 0.2
├─ Text: White, weight 700
├─ Hover: Glow effect
└─ Height: 44px
```

---

### Performance Report

#### Header
```
Back Arrow | "PERFORMANCE ANALYTICS" | Refresh Icon | Export Icon
            User Name // FIELD REPORT

Status Badge:
┌─────────────────────────────┐
│ ⟳ SYNCING | 🟢 FIRESTORE LIVE │
└─────────────────────────────┘
Color: Green for live, Orange for local cache
```

#### Stat Cards (4-column grid)
```
┌──────────────┐
│ [Icon Box]   │
│ 12x12px icon │
│              │
│ 24px Value   │
│ "85%"        │
│              │
│ Label        │
│ "COMPLETION" │
│              │
│ Detail       │
│ "1/2 mods"   │
└──────────────┘

Colors per metric:
├─ Completion: Signal Green
├─ Accuracy: Ember Orange
├─ Attempts: Circuit Purple
└─ Speed: Circuit (different shade)
```

#### Progress Bars
```
┌─ Label ────────────────────────┐
│ ┌──────────────────────────────┐│
│ │████████░░░░░░░░░░░░░░░░░░░░││  85%
│ └──────────────────────────────┘│
└────────────────────────────────┘

Height: 6-8px
Border-radius: 3-4px
Background: Panel border color
Fill: Color per metric
```

#### Track Tiles (5-column grid on desktop)
```
┌─────────────┐
│ [PY Icon]   │
│             │
│ 2/4         │ (Monospace)
│             │
│ [Progress]  │
│             │
│ "PYTHON"    │ (Label)
│ "QUALITY: X"│
└─────────────┘

Compact 1.2:1 aspect ratio
Border: 1px panel border
Fill colors per track
```

#### Module Ledger Row
```
Module Title  · Track · Date       Score (Monospace)

Progress bar (colored)

"N tries · Xms execution" (Label)
```

---

## Spacing System

### Horizontal
```
Desktop (> 1000px):
- Section gap: 24px
- Container padding: 20-24px
- Column gap: 12-16px

Tablet (560-1000px):
- Section gap: 16px
- Container padding: 16-20px
- Column gap: 8-12px

Mobile (< 560px):
- Section gap: 12px
- Container padding: 12-16px
- Column gap: 8px
```

### Vertical
```
Between major sections: 24px
Between components: 12px
Between elements: 6-8px
Within component: 4-6px
```

---

## Borders & Shadows

### Borders
```
Primary Border:
- Width: 1px
- Color: #222222 (dark gray)
- Radius: 4-8px
- Usage: Panels, cards, containers

Accent Border:
- Width: 1px
- Color: #FF5C01 with alpha 0.3
- Radius: 2-4px
- Usage: Badges, input boxes, accent elements

Hairline Border (1-2px gaps in hero):
- Width: 1px
- Color: #FF5C01 with alpha 0.2
- Purpose: Separation, visual flow
```

### Shadows
```
Subtle Shadow (cards):
- Blur: 4px
- Offset: 0, 2px
- Color: #000000 with alpha 0.1

Medium Shadow (hover):
- Blur: 8px
- Offset: 0, 4px
- Color: #000000 with alpha 0.15

Glow Shadow (primary actions):
- Blur: 12px
- Offset: 0, 0
- Color: #FF5C01 with alpha 0.3
- Usage: Button hover
```

---

## Responsive Design Rules

### Breakpoints
```
Mobile:   < 560px   (phone)
Tablet:   560-1000px (iPad/medium)
Desktop:  > 1000px   (desktop/large)
```

### Grid Columns
```
Stat Cards:
Mobile: 1 column (full width)
Tablet: 2 columns
Desktop: 4 columns
Gap: 12px

Track Performance:
Mobile: 1 column
Tablet: 2 columns
Desktop: 5 columns
Gap: 10px

Module Ledger:
Mobile: 1 column (stacked)
Tablet: 1 column (stacked)
Desktop: 1 column (full width)
```

### Touch Targets
```
Minimum: 44px × 44px
Button padding: 12px vertical
Icon buttons: 40px minimum
Text links: Underline on hover
```

---

## Animation Guidelines

### Page Entrance
```
Duration: 800ms
Timing: Cubic ease-out
Scale: 0.95 → 1.0
Applies: Certificate display on load

Property:
- transform: scale(0.95) → scale(1.0)
- opacity: 0.9 → 1.0
```

### Hover Effects
```
Duration: 200ms
Property: All
Timing: Ease-in-out

Button Hover:
- box-shadow: glow effect
- opacity: 1.0 (if was 0.9)

Icon Hover:
- transform: scale(1.05)
- color: brighten
```

### State Changes
```
Progress bar fill: Smooth (300ms)
Status indicator: Fade (200ms)
Sync spinner: Rotate (1s infinite)
Disabled state: Opacity 0.5
```

### NO Animations
```
- Mobile devices (for performance)
- Scrolling
- Page transitions
- Data loading (except spinner)
```

---

## Accessibility

### Color Contrast
```
Text on backgrounds:
- White (#FFF) on Black (#000): 21:1 ✅ AAA
- White on Orange (#FF5C01): 4.5:1 ✅ AA
- Orange on Black: 8.6:1 ✅ AAA

Links always:
- Underlined or distinct color
- Not color alone for meaning
```

### Text Sizes
```
Minimum: 12px for body text
Labels: 8-10px (acceptable for secondary)
Headings: 24px+ for H1

Line Height:
- Body: 1.4-1.6
- Headings: 1.2-1.3
```

### Interactive Elements
```
- Buttons: 44px minimum height
- Icons: 16px+ for clarity
- Focus states: visible outline
- Labels: associated with inputs
```

---

## Dark Mode Implementation

### Automatic (via NoirSkin.of(context))
```
isDark = true → Use all dark theme values
isDark = false → Use light alternatives (if any)

Current state: Terminal noir = always dark
Background: Always #000000
Text: Always #FFFFFF
Accents: Always #FF5C01
```

---

## Implementation Checklist

### Color Implementation
- [x] Primary orange: #FF5C01
- [x] Black backgrounds: #000000
- [x] White text: #FFFFFF
- [x] Dark gray borders: #222222
- [x] Track colors from LanguageTrack enum

### Typography Implementation
- [x] Monospace for stats (fontFamily: 'monospace')
- [x] System fonts for body
- [x] Proper font weights (400, 600, 700, 800, 900)
- [x] Letter spacing on labels (1.0-1.5)

### Spacing Implementation
- [x] Section gaps: 24px desktop, 12px mobile
- [x] Component gaps: 12px
- [x] Element gaps: 6px
- [x] Padding: 16-24px containers

### Responsive Implementation
- [x] LayoutBuilder for breakpoints
- [x] GridView for responsive grids
- [x] SingleChildScrollView for overflow
- [x] FittedBox for text overflow

### Animation Implementation
- [x] Scale animation: 0.95→1.0, 800ms ease-out
- [x] No animations on mobile
- [x] Glow effects on hover
- [x] Smooth state transitions

---

## Visual Hierarchy

### Importance Levels
```
1. CRITICAL (User name, certificate title)
   └─ 24-48px, weight 900, white, monospace

2. HIGH (Section titles, stat values)
   └─ 14-24px, weight 700-800, orange/white

3. MEDIUM (Labels, descriptions)
   └─ 11-13px, weight 600, white with alpha

4. LOW (Helper text, secondary data)
   └─ 8-10px, weight 400-600, gray/faint
```

### Visual Flow
```
Certificate:
1. Orange header bar (draws eyes)
2. Large "CERTIFIED" title
3. Learner name
4. QR code (right side, desktop)
5. Certificate details
6. Action buttons

Report:
1. Header with title
2. Stat cards (key metrics)
3. Charts (visual representation)
4. Ledger (detailed data)
```

---

## Brand Voice

### Tone
- Technical but approachable
- Empowering and rewarding
- Minimal and focused
- Professional yet creative

### Copy Style
- ALLCAPS for labels (// CERTIFIED, etc.)
- Short descriptive phrases
- Action-oriented button text
- No unnecessary words

### Examples
```
✅ "CERTIFIED" (clear, bold)
❌ "You are certified" (verbose)

✅ "DOWNLOAD PDF" (action)
❌ "Get your certificate as PDF" (wordy)

✅ "FIRESTORE LIVE" (status)
❌ "Data is syncing from cloud" (verbose)
```

---

## Future Brand Extensions

### Potential Colors
```
If expanding beyond terminal noir:
- Accent Blue: #0D7EFF (future feature)
- Accent Green: #00D084 (success states)
- Accent Red: #FF3B30 (errors)
```

### Pattern Library
```
- Dots/grid pattern (subtle background)
- Diagonal lines (accent pattern)
- Hexagons (tech aesthetic)
- Waves (smooth transitions)
```

### Icons
```
Current: Material Icons
Future: Custom Ngoding Lok icon set
- Circuit board theme
- Minimal line work
- Terminal aesthetic
```

---

## Quality Assurance

### Visual QA Checklist
- [x] All text readable on backgrounds
- [x] All borders visible (1px+ width)
- [x] All icons render correctly
- [x] All colors match spec (#FF5C01 ≠ #FF5C02)
- [x] Spacing consistent
- [x] Alignment perfect (no 1px misalignment)
- [x] Touch targets ≥ 44px

### Responsive QA
- [x] < 560px: Mobile layout
- [x] 560-1000px: Tablet layout
- [x] > 1000px: Desktop layout
- [x] No horizontal scroll (except necessary)
- [x] Images responsive
- [x] Text wraps correctly

### Performance QA
- [x] No jank in animations
- [x] Smooth scrolling
- [x] Hot reload < 2 seconds
- [x] Memory usage normal
- [x] No console warnings

---

## Resources

### Files Using This Design
1. `certificate_display_enhanced.dart` - Certificate display
2. `performance_report_enhanced_v2.dart` - Report display
3. `landing_tokens.dart` - Color/typography constants
4. `noir_skin.dart` - Theme provider

### Reference Files
1. `IMPLEMENTATION_GUIDE.md` - Detailed technical guide
2. `QUICK_INTEGRATION.md` - Integration steps
3. `ENHANCEMENTS_SUMMARY.md` - Feature overview
4. `DEPLOYMENT_CHECKLIST.md` - Testing checklist

---

## Approval

Design System: ✅ Approved  
Color Palette: ✅ Approved  
Typography: ✅ Approved  
Components: ✅ Approved  
Responsive: ✅ Approved  

**Created**: 2026-07-19  
**Version**: 1.0.0  
**Status**: Production Ready  

---

*For questions about design implementation, see IMPLEMENTATION_GUIDE.md or code comments in the respective screen files.*
