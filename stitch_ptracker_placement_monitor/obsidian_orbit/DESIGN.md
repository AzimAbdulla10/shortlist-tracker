---
name: Obsidian Orbit
colors:
  surface: '#111318'
  surface-dim: '#111318'
  surface-bright: '#37393e'
  surface-container-lowest: '#0c0e12'
  surface-container-low: '#1a1c20'
  surface-container: '#1e2024'
  surface-container-high: '#282a2e'
  surface-container-highest: '#333539'
  on-surface: '#e2e2e8'
  on-surface-variant: '#b9cac5'
  inverse-surface: '#e2e2e8'
  inverse-on-surface: '#2f3035'
  outline: '#84948f'
  outline-variant: '#3b4a46'
  surface-tint: '#00dfc4'
  primary: '#70ffe5'
  on-primary: '#00372f'
  primary-container: '#00e5c9'
  on-primary-container: '#006155'
  inverse-primary: '#006b5d'
  secondary: '#ffcb8d'
  on-secondary: '#462a00'
  secondary-container: '#ffa504'
  on-secondary-container: '#684100'
  tertiary: '#e8e8ea'
  on-tertiary: '#2f3132'
  tertiary-container: '#cbccce'
  on-tertiary-container: '#555658'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#41fcdf'
  primary-fixed-dim: '#00dfc4'
  on-primary-fixed: '#00201b'
  on-primary-fixed-variant: '#005046'
  secondary-fixed: '#ffddb7'
  secondary-fixed-dim: '#ffb95c'
  on-secondary-fixed: '#2a1700'
  on-secondary-fixed-variant: '#653e00'
  tertiary-fixed: '#e2e2e4'
  tertiary-fixed-dim: '#c6c6c8'
  on-tertiary-fixed: '#1a1c1d'
  on-tertiary-fixed-variant: '#454749'
  background: '#111318'
  on-background: '#e2e2e8'
  surface-variant: '#333539'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 40px
    fontWeight: '800'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 26px
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  container-padding: 24px
  card-gap: 16px
  section-margin: 40px
  gutter: 16px
---

## Brand & Style

This design system is engineered for the high-stakes environment of university placements, where clarity, speed, and status are paramount. The aesthetic merges **Modern Corporate** reliability with **Glassmorphism** depth, creating a "command center" feel for students.

The personality is authoritative yet encouraging—designed to feel like a premium fintech tool rather than a standard educational portal. It utilizes deep obsidian voids contrasted against vibrant neon status indicators to evoke a sense of professional urgency and technological sophistication. The interface relies on heavy atmospheric depth, using subtle gradients to guide the eye toward critical action items.

## Colors

The palette is anchored in a multi-layered dark mode. The base is a deep obsidian black, supplemented by soft, radial blue-grey gradients (approx. 10-15% opacity) in the top corners to prevent visual stagnation.

- **Primary (Neon Cyan):** Reserved strictly for success states, active application tracking, and "Offered" statuses. It represents progress and achievement.
- **Secondary (Amber Gold):** Used for "Test Alerts," "Pending Deadlines," or "Action Required." It provides high-contrast visibility without the negativity of red.
- **Tertiary (Off-White):** Used for primary action triggers to ensure maximum contrast against the dark background.
- **Surface Strategy:** Use `#1B202D` for all floating containers. Borders should be extremely thin (1px) using `#222634` to define edges without adding visual weight.

## Typography

The typography system uses a tiered approach to balance character and legibility. **Plus Jakarta Sans** provides a modern, geometric feel for headlines, making the "Ptracker" brand feel fresh and accessible. **Hanken Grotesk** is used for body copy for its exceptional readability in dense data environments. **JetBrains Mono** is introduced for labels and status tags to reinforce the "tech-focused" narrative.

For mobile, headlines scale down slightly to ensure high-impact text doesn't break into awkward line fragments. Always use white (`#FFFFFF`) for headlines and slate-grey (`#94A3B8`) for secondary body text to maintain a clear visual hierarchy.

## Layout & Spacing

The layout follows a **Fluid Grid** model with a focus on generous internal container padding. 

- **Desktop:** 12-column grid with 24px gutters. Content is centered with a max-width of 1280px.
- **Mobile:** 4-column grid with 16px margins. 
- **Rhythm:** All spacing must be a multiple of 4px. Use 24px for standard container internal padding to allow the 20px rounded corners enough "breathing room" so content doesn't feel pinched in the curves. 

Information density should be kept moderate; use white space (or "obsidian space") to separate different application stages or companies.

## Elevation & Depth

Depth is created through color stepping and subtle blurs rather than traditional shadows. 

1.  **Level 0 (Floor):** Deep Space Obsidian (#090B0F).
2.  **Level 1 (Cards):** Slate Grey (#1B202D) with a 1px border (#222634). No shadow.
3.  **Level 2 (Modals/Popovers):** Slate Grey (#1B202D) with a 20% opacity white inner-glow (stroke) and a 40px backdrop blur on the layer beneath.

The visual effect should mimic a series of glass panels stacked over a dark void. Avoid heavy black shadows; if a shadow is necessary for a floating button, use a saturated primary color tint (e.g., a cyan outer glow) at low opacity.

## Shapes

The design system utilizes a "Soft-Tech" shape language. 
- **Containers & Cards:** Fixed at 20px radius. This creates a friendly, modern look that softens the "hard" tech colors.
- **Interactive Elements (Buttons/Inputs):** Use a pill-shaped 30px radius. This makes touch targets obvious and distinguishes clickable elements from informational containers.
- **Selection States:** Active tabs or selected chips should use the same 30px radius to maintain consistency with the button language.

## Components

### Buttons
- **Primary:** Solid off-white (#F5F5F7) background with black (#090B0F) bold text. 30px pill shape. High-contrast and immediate.
- **Secondary:** Outlined with a 1px border (#222634). Text in white. On hover, the border brightens to primary cyan.
- **Status Chips:** Small containers with JetBrains Mono text. Use primary cyan for "Placed" and amber for "Upcoming Test."

### Input Fields
- Background matches the surface card (#1B202D). 
- 1px border (#222634). On focus, the border transitions to Primary Cyan with a subtle 2px outer glow.

### Cards
- Use 20px rounded corners. 
- Header within the card should use `title-md`. 
- Incorporate a subtle vertical separator between the company logo and the placement details to maintain clean data scanning.

### Icons
- Use 24px bounding boxes.
- Stroke weight: 1.5px or 2px.
- Style: Linear, minimalist. Never use filled icons unless they are in an "active" state in the bottom navigation bar.