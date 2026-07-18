# Responsive Design Breakpoints

**Reference Guide for Mobile, Tablet, and Desktop Layouts**

---

## Breakpoint Definitions

```dart
// Extra Small: Small phones (width < 360px)
isExtraSmall = constraints.maxWidth < 360;

// Small: Large phones (360px ≤ width < 560px)
isSmall = constraints.maxWidth < 560;

// Medium: Tablets (560px ≤ width < 900px)
isMedium = constraints.maxWidth < 900;

// Large: Desktops (width ≥ 900px)
isLarge = constraints.maxWidth >= 900;
```

---

## Device Mapping

| Category | Devices | Width | Breakpoint |
|----------|---------|-------|-----------|
| **Extra Small** | iPhone SE, older phones | 320-375px | < 360px |
| **Small** | iPhone 13/14/15 | 390-430px | 360-560px |
| **Small Plus** | iPhone 13/14 Pro Max | 430-450px | 360-560px |
| **Medium** | iPad (10.9"), small tablets | 560-768px | 560-900px |
| **Medium Plus** | iPad Pro (11"), large tablets | 768-900px | 560-900px |
| **Large** | Desktop, large monitors | 900-1920px+ | ≥ 900px |

---

## Hint Banner Responsive Design

### Extra Small Layout (< 360px)
```
┌─────────────────────────────┐
│ 🤖 > generating...         │ (1 line, truncated)
└─────────────────────────────┘
Padding: 8px horizontal, 10px vertical
Icon: 16px
Font: 11px
Max lines: 2
```

### Small Layout (360-560px)
```
┌──────────────────────────────────┐
│ 🤖 > generating a hint...       │
│                                  │
│ > Have you considered what...   │ (truncated)
└──────────────────────────────────┘
Padding: 12px horizontal, 12px vertical
Icon: 16px
Font: 12-13px
Max lines: 5
```

### Medium+ Layout (560px+)
```
┌────────────────────────────────────────┐
│ Hint                                   │
│                                        │
│ 🤖 > Have you considered what        │
│      direction you need to move to     │
│      reach the flag?                  │
└────────────────────────────────────────┘
Padding: 16px horizontal, 12px vertical
Icon: 16px
Font: 12-13px
Max lines: 5
Subheading visible: "Hint"
```

---

## Game Header Responsive Design

### Extra Small Header (< 360px)
```
┌─ [Dashboard]────────────────┐
│ [Icon] M1: Sequential Steps  │
│ [00:03]  [💡]  [Run]        │ (horizontally scrollable)
└──────────────────────────────┘
```

**Specifications**:
- Icon: 28x28px
- Buttons: 32x32px
- Font: 13px (title), 11px (timer)
- Spacing: 8px
- Layout: Vertical stack, scrollable actions

### Small Header (360-560px)
```
┌─ [Dashboard]────────────────┐
│ [Icon] Module 1: Sequential  │
│ [00:03]  [💡 Hint] [Run]    │
└──────────────────────────────┘
```

**Specifications**:
- Icon: 28x28px
- Buttons: 32x32px (icons with labels)
- Font: 13px (title), 11px (timer)
- Spacing: 8px
- Layout: Vertical stack
- Toolbar: Horizontally scrollable

### Medium Header (560-900px)
```
┌ [Dashboard] [Icon] Module 1: Sequential      [00:03] [💡 Hint] [Run] ┐
└───────────────────────────────────────────────────────────────────────┘
```

**Specifications**:
- Icon: 34x34px
- Buttons: 34x34px
- Font: 15px (title), 12px (timer)
- Spacing: 12px
- Layout: Two-row (top: nav/title, bottom: actions)
- All elements visible

### Large Header (≥ 900px)
```
┌─────────────────────────────────────────────────────────────────────┐
│ [Dashboard] [Icon] Module 1: Sequential Steps  [Timer] [Hint] [Run] │
└─────────────────────────────────────────────────────────────────────┘
```

**Specifications**:
- Icon: 34x34px
- Buttons: 34x34px
- Font: 15px (title), 12px (timer)
- Spacing: 16px
- Layout: Single horizontal row
- Maximum visual clarity

---

## Component Sizing

### Buttons

| Device | Size | Icon | Font |
|--------|------|------|------|
| Extra Small | 28x28px | 12px | 0px (icons only) |
| Small | 32x32px | 14px | 11px |
| Medium+ | 34x34px | 16px | 12px |

### Icons

| Type | Extra Small | Small | Medium+ |
|------|-------------|-------|---------|
| Module icon | 14px | 14px | 17px |
| Button icon | 12px | 14px | 16px |
| Timer icon | 11px | 13px | 13px |

### Typography

| Element | Extra Small | Small | Medium+ |
|---------|-------------|-------|---------|
| Title | 13px | 13px | 15px |
| Label | 11px | 11px | 12px |
| Timer | 10px | 10px | 12px |
| Hint text | 11px | 12px | 13px |

### Spacing

| Context | Extra Small | Small | Medium | Large |
|---------|-------------|-------|--------|-------|
| Button spacing | 6-8px | 8px | 12px | 16px |
| Component padding | 8px | 12px | 16px | 16px |
| Line height | 1.3 | 1.3 | 1.4 | 1.4 |

---

## Animation Timing

| Animation | Duration | Curve | Trigger |
|-----------|----------|-------|---------|
| Hint slide-in | 600ms | easeOut | Hint arrival |
| Hint fade-in | 600ms | easeOut | Hint arrival |
| Loading spinner | 2000ms | linear | Generating state |
| Button hover | 200ms | easeInOut | Mouse over (desktop) |

---

## Responsive Decisions

### When Width < 360px (Extra Small)
```dart
if (isExtraSmall) {
  // Use icon-only buttons
  button.label = '';
  
  // Single-line hint
  hintBanner.maxLines = 2;
  
  // Reduced padding
  padding = EdgeInsets.all(8);
  
  // Smaller fonts
  fontSize = fontSize - 2;
  
  // Horizontal scrollable toolbar
  toolbar = SingleChildScrollView(
    scrollDirection: Axis.horizontal,
  );
}
```

### When 360px ≤ Width < 560px (Small)
```dart
if (isSmall) {
  // Stacked layout (top: nav, bottom: actions)
  layout = Column(
    children: [navRow, actionsRow],
  );
  
  // Scrollable action toolbar
  actions = SingleChildScrollView(
    scrollDirection: Axis.horizontal,
  );
  
  // Hint with labels
  hintBanner.layout = TwoColumn();
}
```

### When 560px ≤ Width < 900px (Medium)
```dart
if (isMedium) {
  // Can fit most content
  layout = TwoRow(); // Or WrappedRow
  
  // Show labels on buttons
  button.label = getFullLabel();
  
  // Full hint layout with subheading
  hintBanner.layout = FullLayout();
}
```

### When Width ≥ 900px (Large)
```dart
if (isLarge) {
  // Horizontal layout, everything fits
  layout = Row(
    mainAxisSize: MainAxisSize.max,
  );
  
  // Full spacing
  spacing = 16;
  
  // Hover effects enabled
  enableHoverEffects = true;
  
  // No truncation needed
  maxLines = infinite;
}
```

---

## CSS Media Queries Equivalents

```css
/* Extra Small */
@media (max-width: 359px) {
  .header { flex-direction: column; }
  .button { width: 28px; }
  .font-title { font-size: 13px; }
}

/* Small */
@media (min-width: 360px) and (max-width: 559px) {
  .header { display: grid; grid-template-rows: auto auto; }
  .button { width: 32px; }
  .toolbar { overflow-x: auto; }
}

/* Medium */
@media (min-width: 560px) and (max-width: 899px) {
  .header { display: grid; grid-template-rows: auto auto; }
  .hint-banner { display: flex; gap: 12px; }
}

/* Large */
@media (min-width: 900px) {
  .header { display: flex; gap: 16px; }
  .button:hover { transform: scale(1.05); }
  .hint-banner { max-width: 600px; }
}
```

---

## Testing Checklist

- [ ] Extra Small (360px): No horizontal scroll except toolbar
- [ ] Small (560px): All content visible, buttons readable
- [ ] Medium (900px): Full layout renders correctly
- [ ] Large (1920px): Maximum spacing utilized
- [ ] Rotation (portrait ↔ landscape): Layout adapts smoothly
- [ ] Touch targets: All ≥ 32px
- [ ] Text: Readable without zoom on all sizes
- [ ] Animations: Smooth on all devices
- [ ] Overflow: No hidden content without scroll

---

## Common Device Widths

```
iPhone SE:           375px (320 content)
iPhone 13:           390px (360 content)
iPhone 13 Pro:       390px (360 content)
iPhone 13 Pro Max:   430px (390 content)

iPad (10.9"):        810px (768 content)
iPad Pro (11"):      834px (792 content)
iPad Pro (12.9"):    1024px (980 content)

Laptop:              1920px (1880 content)
Desktop (2K):        2560px (2520 content)
```

---

## Debugging Responsiveness

```dart
// Print current breakpoint
final width = MediaQuery.of(context).size.width;
print('Width: ${width}px');
if (width < 360) print('Extra Small');
else if (width < 560) print('Small');
else if (width < 900) print('Medium');
else print('Large');

// Inspect layout bounds
LayoutBuilder(
  builder: (context, constraints) {
    print('Max width: ${constraints.maxWidth}');
    // Your layout here
  },
)
```

---

## Performance Notes

- **LayoutBuilder recalculates** only when constraints change (efficient)
- **Animations use Transform** (GPU accelerated, no repaints)
- **Font scaling** is automatic via TextStyle (no manual measurements)
- **SingleChildScrollView** used sparingly (scrollable toolbar only on extra-small)

---

**Last Updated**: 2026-07-18  
**Tested On**: iOS, Android, Chrome, Firefox, Safari, Edge
