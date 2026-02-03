# PowerCoffee Theming Guide (Accessibility-First)

## Baseline color
- Primary: #ff6f00

## Accessibility targets
- Minimum contrast for text: 4.5:1
- Large text (18pt+ or 14pt bold): 3:1
- Icons and non-text UI elements: 3:1

## Core palette
- Primary: #ff6f00
- Primary dark (for text/icons on light): #b84f00
- Primary light (for backgrounds): #ffd3b3
- Background: #f7f7f7
- Surface: #ffffff
- Text primary: #1b1b1b
- Text secondary: #4d4d4d
- Border: #d0d0d0
- Focus: #1b1b1b

## Usage rules
- Use #ff6f00 for primary actions, key highlights, and active states.
- Use #b84f00 for primary text or icons on light backgrounds when contrast is needed.
- Use #ffd3b3 sparingly for subtle backgrounds and chips.
- Ensure text on #ff6f00 is white (#ffffff) only if contrast is sufficient; otherwise use #1b1b1b.

## Component guidance
- Buttons: primary fill #ff6f00, text #ffffff, focus outline #1b1b1b.
- Links: #b84f00 with underline on hover/focus.
- Inputs: border #d0d0d0, focus border #b84f00, helper text #4d4d4d.
- Cards: background #ffffff, title #1b1b1b, accent line #ff6f00.

## Interaction states
- Hover: darken primary by 10–15%.
- Pressed: darken primary by 20–25%.
- Disabled: background #f0f0f0, text #9e9e9e, border #e0e0e0.

## Do / Don’t
- Do keep a single primary action per screen.
- Do maintain consistent focus outlines.
- Don’t use orange text on orange backgrounds.
- Don’t rely on color alone to convey status.

## Notes
- Validate contrast using a checker before release.
- Keep typography readable and consistent across screens.
