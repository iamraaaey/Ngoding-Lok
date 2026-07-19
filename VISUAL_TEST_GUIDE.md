# Visual Test Guide - What to Expect

## Certificate Display - Visual Checklist

### Header Section
```
┌───────────────────────────────────────────────────┐
│  🔶 NGODING LOK                        ✓ VERIFIED │  ← Orange bar
├───────────────────────────────────────────────────┤
│                                                   │
│                    CERTIFIED                      │  ← Large monospace
│                        ▬▬▬                        │  ← Orange line
│                  PYTHON TRACK                     │  ← Orange label
│              Module 1: Sequential Steps           │
│                                                   │
└───────────────────────────────────────────────────┘
```

**Verify**:
- [ ] Orange color is #FF5C01 (not too red)
- [ ] "CERTIFIED" text is large (48px+)
- [ ] Underline is orange and glowing
- [ ] Track label in orange
- [ ] All text is monospace/technical style

---

### Content Section (Mobile Layout)
```
┌─────────────────────────────────────┐
│ CERTIFICATE OF ACHIEVEMENT          │  ← Label
│                                     │
│ This certificate is presented to    │
│ RAYNOLD KABAI                       │  ← Large name
│                                     │
│ for successfully completing         │
│ Module 1: Sequential Steps          │
│ Learn basic movement commands...    │
│                                     │
│ ┌───────────────────────────────┐   │
│ │ CREDENTIAL DETAILS            │   │ ← Info box
│ │                               │   │
│ │ ISSUED:  19 JUL 2026          │   │
│ │ SCORE:   10 XP                │   │
│ │ ID: b6d02fa116d3...           │   │
│ └───────────────────────────────┘   │
│                                     │
│  ┌──────────────────┐               │
│  │                  │               │ ← QR CODE (144x144)
│  │ █████ ░░░░ █████│               │
│  │ █   █ ░░░░ █   █│               │
│  │ █ █ █ ░░░░ ░ █ █│               │
│  │ █   █ ░░░░ ░░░░ │               │
│  │ █████ ░░░░ █░░░ │               │
│  │   ░░░░ █ ░█░░░░  │               │
│  │ █████░░░░ ░░░░░░ │               │
│  │ ░░░ ░░░ ░█░░░░░░ │               │
│  │ ░░░ ░░░ ░░░░░░░░ │               │
│  │ ░░░░ ░░░░░░░░ ░░ │               │
│  │ ░░░░░░░░░░░░░░░░ │               │
│  └──────────────────┘               │
│  SCAN TO VERIFY                     │
│                                     │
└─────────────────────────────────────┘
```

**Verify QR Code**:
- [ ] Size is 144x144px (measured or visual)
- [ ] Black pattern on white background
- [ ] 3 large squares in corners (finders)
- [ ] Alternating lines visible
- [ ] Random-looking data pattern
- [ ] "SCAN TO VERIFY" label below
- [ ] Label is smaller orange/gray text

---

### Content Section (Desktop Layout)
```
┌──────────────────────────────────────────────────────────┐
│ CERTIFICATE OF ACHIEVEMENT                               │
│                                                          │
│ This certificate is presented to                         │
│ RAYNOLD KABAI                                            │
│                                                          │
│ for successfully completing                              │
│ Module 1: Sequential Steps                               │
│ Learn basic movement commands...                         │
│                                                          │
│ ┌──────────────────────────┐    ┌──────────────────┐    │
│ │ CREDENTIAL DETAILS       │    │      QR CODE     │    │
│ │                          │    │  144x144px       │    │
│ │ ISSUED:  19 JUL 2026     │    │  ▌▌▌▌ ░░ ▌▌▌    │    │
│ │ SCORE:   10 XP           │    │  ▌ ▌ ░░ ▌ ▌    │    │
│ │ ID: b6d02fa...           │    │  ▌▌▌ ░░ ░░▌    │    │
│ └──────────────────────────┘    │  ...pattern...  │    │
│                                  │  SCAN TO VERIFY │    │
│                                  └──────────────────┘    │
└──────────────────────────────────────────────────────────┘
```

**Verify Layout**:
- [ ] Left column: Certificate details
- [ ] Right column: QR code (144x144)
- [ ] Horizontally centered
- [ ] Good visual balance
- [ ] Proper spacing between elements

---

### Footer Section
```
┌─────────────────────────────────────────┐
│ This credential can be verified online  │
│      at ngoding-lok.web.app             │
│                                         │
│  LEARN BY BUILDING • NGODING LOK       │
└─────────────────────────────────────────┘
```

**Verify**:
- [ ] Footer text visible
- [ ] Verification URL shown
- [ ] Brand text at bottom
- [ ] All text properly styled

---

### Action Buttons
```
Mobile (< 560px):
┌─────────────────────────────┐
│ [← BACK]                    │
├─────────────────────────────┤
│ [📥 DOWNLOAD PDF]           │  ← Orange button
├─────────────────────────────┤
│ [💼 SHARE ON LINKEDIN]      │
└─────────────────────────────┘

Desktop (> 1100px):
┌──────────────────┬────────────────────┬──────────────────┐
│ [← BACK]         │ [📥 DOWNLOAD PDF]  │ [💼 SHARE...]   │
└──────────────────┴────────────────────┴──────────────────┘
```

**Verify Buttons**:
- [ ] All 3 buttons visible
- [ ] Proper colors (orange primary, white secondary)
- [ ] Touch target ≥ 44px tall
- [ ] Icons visible
- [ ] Text readable
- [ ] Hover glow effect on primary button
- [ ] Responsive layout (stacked on mobile)

---

## Performance Report - Visual Checklist

### Header Section
```
┌─────────────────────────────────────────────────┐
│ ← PERFORMANCE ANALYTICS          ⟲ 📥 [Status] │
│ USER NAME // FIELD REPORT                      │
│                                                 │
│ ☁ SYNCING... | 🟢 FIRESTORE LIVE | 📤 LOCAL  │
└─────────────────────────────────────────────────┘
```

**Verify**:
- [ ] Back arrow clickable
- [ ] User name displayed
- [ ] Refresh button present
- [ ] PDF export button present
- [ ] Status indicator shows (green/orange)
- [ ] Status text clear

---

### Stats Grid (Desktop - 4 Columns)
```
┌──────────────┬──────────────┬──────────────┬──────────────┐
│ 📈 85%       │ 🎯 92%       │ 🔁 47        │ ⏱ 1.2s       │
│ COMPLETION   │ ACCURACY     │ ATTEMPTS     │ FASTEST      │
│ 1/2 modules  │ 5 tracked    │ 12 perfect   │ Best time    │
└──────────────┴──────────────┴──────────────┴──────────────┘
```

**Verify Each Stat Card**:
- [ ] Icon visible (colored background)
- [ ] Large value (24px+)
- [ ] Label in smaller text
- [ ] Detail text below
- [ ] Proper colors per metric:
  - Completion: Green (#4CAF50)
  - Accuracy: Orange (#FF5C01)
  - Attempts: Purple (#6C5CE7)
  - Speed: Purple (different shade)
- [ ] Border visible
- [ ] Spacing consistent

---

### Stats Grid (Mobile - 1-2 Columns)
```
Mobile (< 560px):
┌────────────────┐
│ 📈 85%         │
│ COMPLETION     │
│ 1/2 modules    │
└────────────────┘
┌────────────────┐
│ 🎯 92%         │
│ ACCURACY       │
│ 5 tracked      │
└────────────────┘
(And 2 more below)

Tablet (560-1000px):
┌──────────────┬──────────────┐
│ 📈 85%       │ 🎯 92%       │
│ COMPLETION   │ ACCURACY     │
│ 1/2 modules  │ 5 tracked    │
└──────────────┴──────────────┘
(And 2 more below in same layout)
```

**Verify Responsive**:
- [ ] Mobile: 1-column grid
- [ ] Tablet: 2-column grid
- [ ] Desktop: 4-column grid
- [ ] No overflow
- [ ] Proper spacing on all widths

---

### Momentum Panel
```
┌─────────────────────────────────────┐
│ ⚡ // MOMENTUM METRICS              │
│                                     │
│ Curriculum Coverage:        85%     │
│ ████████░░░░░░░░░░░░░░░░░░░░░░░░ │
│                                     │
│ Average Score Quality:      92%     │
│ █████████████████░░░░░░░░░░░░░░░ │
│                                     │
│ ┌─────────┬─────────┬─────────┐   │
│ │ 7d      │ 21d     │ LV 3    │   │
│ │ STREAK  │ BEST    │ LEVEL   │   │
│ └─────────┴─────────┴─────────┘   │
└─────────────────────────────────────┘
```

**Verify**:
- [ ] Progress bars visible and filled correctly
- [ ] Labels clear
- [ ] Percentage values shown
- [ ] Mini stat boxes aligned
- [ ] Color coding correct
- [ ] Smooth bar appearance

---

### Performance Breakdown Panel
```
┌──────────────────────────────┐
│ 📊 // PERFORMANCE BREAKDOWN  │
│                              │
│ Module 1: 95%               │
│ ████████░░░░░░░░░░░░░░░░░ │
│                              │
│ Module 2: 87%               │
│ ███████░░░░░░░░░░░░░░░░░░ │
│                              │
│ Module 3: 76%               │
│ ██████░░░░░░░░░░░░░░░░░░░ │
│ ...                          │
└──────────────────────────────┘
```

**Verify**:
- [ ] Module names visible
- [ ] Accuracy percentages shown
- [ ] Progress bars filled correctly
- [ ] Colors vary based on accuracy:
  - 90%+ = Green
  - 75-90% = Blue
  - <75% = Orange
- [ ] Top 5 modules shown
- [ ] Proper spacing

---

### Track Performance Grid
```
Desktop (5 columns):
┌────┬────┬────┬────┬────┐
│ PY │SQL │JAVA│ CS │ARDNO│
│1/4 │2/3 │1/2 │3/3 │1/2 │
│███░│████│██░ │████│██░ │
└────┴────┴────┴────┴────┘

Mobile (1-2 columns):
┌──────┐
│ PY   │
│ 1/4  │
│ ███░ │
└──────┘
┌──────┐
│ SQL  │
│ 2/3  │
│ ████ │
└──────┘
(etc)
```

**Verify Tracks**:
- [ ] All 5 tracks visible (Python, SQL, Java, Cybersecurity, Arduino)
- [ ] Correct icons for each track
- [ ] Progress bars fill correctly
- [ ] Color matches track color
- [ ] Module count shown (1/4, 2/3, etc)
- [ ] Quality percentage shown
- [ ] Responsive grid on mobile/tablet

### Module Ledger
```
┌───────────────────────────────────────────────────┐
│ 📋 // MODULE LEDGER                              │
│ Most recent verified clears with performance     │
│                                                   │
│ > Sequential Steps      87%  5 tries   1.2s     │
│   ████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│   PYTHON • 19 JUL 2026                           │
│                                                   │
│ > Loop Foundations      92%  3 tries   2.1s     │
│   ██████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│   PYTHON • 18 JUL 2026                           │
│                                                   │
│ > Array Patterns        76%  7 tries   3.4s     │
│   ███████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│   PYTHON • 17 JUL 2026                           │
└───────────────────────────────────────────────────┘
```

**Verify Module Ledger**:
- [ ] Module names visible
- [ ] Accuracy scores shown (monospace)
- [ ] Progress bars with correct colors
- [ ] Try count shown
- [ ] Execution time shown
- [ ] Track label shown
- [ ] Date shown
- [ ] Sorted by most recent
- [ ] All completed modules listed

---

## Color Verification

### Required Colors
```
Primary Orange:     #FF5C01
└─ RGB: (255, 92, 1)
└─ Used for: Buttons, accents, badges
└─ Contrast on black: 8.6:1 ✅ AAA

Black:              #000000
└─ RGB: (0, 0, 0)
└─ Used for: Main background
└─ Contrast with white: 21:1 ✅ AAA

White:              #FFFFFF
└─ RGB: (255, 255, 255)
└─ Used for: Text on dark backgrounds
└─ Contrast with black: 21:1 ✅ AAA

Signal Green:       #4CAF50
└─ RGB: (76, 175, 80)
└─ Used for: Success, completion
└─ Contrast on black: Good ✅

Ember Orange:       #FF5C01 (same as primary)
└─ Used for: Warnings, primary actions

Circuit Purple:     #6C5CE7
└─ RGB: (108, 92, 231)
└─ Used for: Secondary accents
└─ Contrast on black: Good ✅
```

**Verification Test**:
1. Screenshot the app
2. Use color picker on each element
3. Verify hex values match
4. Check contrast ratios

---

## Responsive Breakpoint Test

### Mobile (< 560px)
```
flutter run -d chrome
# Or resize browser to < 560px
```

**Should See**:
- [ ] Single column layout
- [ ] QR code below content
- [ ] Buttons stacked vertically
- [ ] Stats 1-2 per row
- [ ] No horizontal scroll
- [ ] Full width content

### Tablet (560px - 1000px)
```
# Resize browser to 600-900px
```

**Should See**:
- [ ] 2-3 column layout
- [ ] QR code visible
- [ ] Buttons in 2-3 row layout
- [ ] Stats 2 per row
- [ ] Optimal spacing
- [ ] Good visual balance

### Desktop (> 1000px)
```
# Resize browser to 1100px+
```

**Should See**:
- [ ] Full 4-column stat grid
- [ ] QR code on right side
- [ ] Buttons in single row
- [ ] Panels side-by-side
- [ ] Full width utilization
- [ ] Maximum information density

---

## Animation Test

### Certificate Load Animation
```
Expected:
1. Widget appears at 95% scale
2. Smooth scale-up to 100% (800ms)
3. Ease-out curve for natural feel
4. No jank or stutter
```

**Test**:
- [ ] Close and reopen certificate view
- [ ] Animation smooth (60fps)
- [ ] Duration ~800ms
- [ ] No jank at any point

### Hover Effects
```
Expected:
1. Button glows when hovering
2. Glow effect smooth transition
3. No flicker or flash
```

**Test**:
- [ ] Hover over Download button
- [ ] Glow effect appears
- [ ] Smooth (not instant)
- [ ] Color correct (#FF5C01 glow)

---

## Dark Mode Test

### Should Work In Dark Mode
```
NoirSkin.isDark = true
```

**Verify**:
- [ ] Certificate displays correctly
- [ ] All text readable
- [ ] Colors consistent
- [ ] No contrast issues
- [ ] Icons visible
- [ ] Borders visible

---

## Performance Test

### Render Performance
```bash
flutter run --profile
# Check frame rate in DevTools
```

**Expected**:
- [ ] Smooth 60fps scrolling
- [ ] No frame drops
- [ ] Animation smooth
- [ ] QR renders instantly
- [ ] No jank on layout changes

### Memory Usage
```
# Check DevTools Memory tab
```

**Expected**:
- [ ] Normal memory usage
- [ ] No memory leaks
- [ ] GC completes quickly
- [ ] After navigation: memory freed

---

## Final Verification Checklist

### Functionality
- [ ] QR code visible and scannable
- [ ] PDF download works
- [ ] LinkedIn share works
- [ ] Back button navigates
- [ ] Refresh updates data
- [ ] Data syncs from Firestore

### Visual
- [ ] Colors match specification
- [ ] Typography correct
- [ ] Spacing consistent
- [ ] Icons visible
- [ ] Borders clear
- [ ] Layout responsive

### Performance
- [ ] Smooth animations
- [ ] No jank
- [ ] Fast rendering
- [ ] Normal memory usage
- [ ] Efficient scrolling

### Accessibility
- [ ] Text readable
- [ ] Color contrast good
- [ ] Touch targets large
- [ ] No flashing content
- [ ] Semantic structure

### Quality
- [ ] No console errors
- [ ] No warnings
- [ ] Code clean
- [ ] Animations smooth
- [ ] All features work

---

## Troubleshooting Visual Issues

### QR Not Visible
1. Check size (should be 144x144)
2. Check colors (black on white)
3. Try larger size temporarily
4. Check z-index (not hidden)

### Colors Wrong
1. Use color picker to check hex
2. Compare to specification
3. Check CSS color values
4. Verify theme provider

### Layout Broken
1. Test on exact breakpoint (560px, 1000px)
2. Check width constraints
3. Verify LayoutBuilder
4. Check overflow handling

### Animations Janky
1. Profile with `--profile` flag
2. Check frame rate in DevTools
3. Look for expensive widgets
4. Verify animations not overlapping

---

**Status**: Ready for visual testing ✅

*Refer to DEBUG_AND_FIX.md for technical details*  
*Refer to IMPLEMENTATION_GUIDE.md for integration*
