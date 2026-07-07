# Bomb! Card and Local Player Visual Refresh

This document is the current scoped implementation directive for cleaning up the active game screen. Read it together with `Docs/UI_DESIGN.md`. Where this document is more specific about card appearance or the local human active-player treatment, this document controls the current refresh.

Gameplay behavior remains authoritative in `Docs/GAME_RULES.md`.

## 1. Scope

Implement a visual refresh only. The goals are:

1. Make face-up cards look more like polished classic mobile playing cards.
2. Make face-down cards look like real patterned playing-card backs rather than flat red placeholders.
3. Replace the oversized yellow outline around the local human player area with a compact, non-overlapping current-turn treatment.
4. Preserve the existing responsive iPhone layout and all gameplay behavior.

Do not redesign the entire screen.

## 2. Files to Change

Primary implementation files:

- `Bomb/CardView.swift`
  - face-up card appearance
  - shared playing-card geometry
  - rank/suit layout
  - pip layout
  - face-card and Joker presentation

- `Bomb/ContentView.swift`
  - `CardBackView`
  - card-back stack presentation
  - local human player header/current-turn treatment
  - `ActivePlayerIndicatorModifier` only where needed
  - `GameScreenMetrics` only where needed to guarantee safe spacing

Optional assets:

- `Bomb/Assets.xcassets/`
  - original face-card artwork
  - original Joker artwork
  - original patterned card-back artwork

Do not change `Bomb/Game.swift` for this refresh.

## 3. Face-Up Card Visual Standard

The current centered rank-over-suit prototype look should be replaced with a more conventional playing-card layout.

Required:

- Keep the existing shared aspect ratio from `PlayingCardLayout.aspectRatio` unless a separate explicit change is requested later.
- Use a white or subtly warm-white card face.
- Use a thin dark neutral border.
- Use a restrained shadow that reads as a physical card on the table.
- Keep corner radius consistent at all sizes.
- Place rank and suit together in the upper-left corner.
- Scale rank and suit proportionally with card width.
- Red suits use red.
- Black suits use black or near-black.
- The upper-left index must remain readable on opponent cards and smaller pile cards.

### 3.1 Number Cards

For ranks 2 through 10:

- Use a conventional centered pip arrangement rather than one centered suit symbol.
- Pip layout should be visually balanced.
- Pips must scale with card width.
- Do not use hard-coded absolute pixel positions that work only at one card size.
- Small cards may simplify pip detail if necessary, but rank and suit identity must remain readable.

### 3.2 Aces

- Show a large central suit symbol.
- Keep the upper-left rank/suit index.

### 3.3 Face Cards

For Jack, Queen, and King:

- Keep the upper-left rank/suit index.
- Use a central royal/portrait-style treatment so the card reads immediately as a face card.
- Prefer original artwork or simple original vector styling.
- Do not copy a commercial card deck design exactly.
- If no artwork asset exists yet, use a polished original fallback treatment rather than reverting to the old centered rank/suit prototype.

### 3.4 Joker

- Keep Joker visually distinct from standard suits.
- Use a polished Joker treatment with strong readability at small sizes.
- Preserve current gameplay identity and logic.

## 4. Face-Down Card Visual Standard

The current flat red rounded rectangle with two simple white outlines should be replaced.

Required:

- Use a classic red patterned card-back appearance.
- Include a white outer border.
- Include a red inset field.
- Include an original repeating ornamental or geometric pattern inside the red field.
- Pattern detail must scale cleanly on small opponent cards.
- Preserve the same card aspect ratio and corner geometry as face-up cards.
- Use the same restrained shadow language as face-up cards.
- Do not copy Bicycle or another commercial deck back exactly.

Preferred implementation order:

1. Reusable SwiftUI vector pattern that scales with card width, or
2. Original vector/raster asset in `Assets.xcassets`.

Do not create separate inconsistent card-back implementations for draw pile, opponent setup cards, and local setup cards. Continue to reuse `CardBackView`.

## 5. Local Human Player Area

The current large yellow rounded outline around the entire local player section should be removed.

Required:

- Do not draw a yellow border around the entire local-player panel.
- Do not add padding around the entire local-player section solely to make room for an active-player border.
- Do not place the `Playing` badge so that it floats outside the section and overlaps adjacent cards, buttons, or the center table area.
- Keep the local player visually emphasized without enclosing all local content in a large yellow box.

Preferred current-turn treatment:

- Keep the existing local `PlayerBadge` for the player name.
- When it is the local player's turn, show a compact yellow `Playing` capsule beside the player badge or immediately adjacent to it in normal layout flow.
- Optionally add a subtle yellow glow or thin outline to the small player badge itself.
- Current-turn emphasis must remain obvious without becoming a large container.

The current player must still be derived from `game.currentPlayerIndex`.

## 6. Opponent Current-Turn Treatment

Opponent active-player indication may remain compact and should continue to derive from actual game state.

Required:

- No large new panel background.
- No oversized border that changes the player tile's layout footprint unpredictably.
- No overlap with neighboring opponents at 4 or 5 total players.
- Keep the `Playing` text indicator or equivalent text so current turn does not rely on color alone.

If the shared `ActivePlayerIndicatorModifier` cannot satisfy both the local human and compact opponent layouts cleanly, use separate local and opponent treatments rather than forcing one oversized modifier onto both.

## 7. Layout and Overlap Rules

This refresh must not introduce overlaps.

The local player area must not overlap:

- Draw Pile
- Play Pile
- Discard Pile
- `Pick Up` control
- `Play` control
- setup-card labels
- setup cards
- remaining-hand label
- remaining-hand cards
- footer

Additional requirements:

- Keep the Play button in the same general area.
- Keep horizontal scrolling for large local hands.
- Do not let a large hand resize the entire game board unpredictably.
- Use normal SwiftUI layout flow before using offsets.
- Avoid negative padding for primary layout.
- Decorative overlays must not claim visual space outside their intended area without reserved layout room.
- Test narrow iPhone portrait widths.

## 8. Responsive Requirements

Verify 2 through 5 total players.

At minimum, test:

- 2 players total
- 3 players total
- 4 players total
- 5 players total

For each configuration verify:

- no opponent overlap
- no opponent-to-pile overlap
- no local-player-to-pile overlap
- no `Playing` badge overlap
- no Play button overlap
- no card distortion
- all cards preserve the same aspect ratio

Also test:

- local hand of 3 cards
- local hand greater than 6 cards
- local hand greater than 10 cards after pickup

## 9. Functional Boundaries

Do not change:

- card legality
- turn order
- direction logic
- Bomb logic
- 10 clear logic
- Joker logic
- forced pickup logic
- voluntary pickup logic
- computer strategy
- winner detection
- animation sequencing except for layout adjustments needed to preserve visual alignment

`Game.swift` remains the gameplay source of truth.

## 10. Implementation Guidance

### `Bomb/CardView.swift`

Refactor card-face presentation into small reusable views/helpers where useful, for example:

- corner index
- number-card pip layout
- Ace center
- face-card center
- Joker center

Keep geometry proportional to `width`.

### `Bomb/ContentView.swift`

Review these existing areas specifically:

- `localPlayerSection(metrics:)`
- `ActivePlayerIndicatorModifier`
- `activePlayerIndicator(isActive:compact:)`
- `CardBackView`
- `CardBackStackView`
- `TableCardPileView`
- `TableCardPilesView`
- `GameScreenMetrics.playerHeight`
- `GameScreenMetrics.playerSetupCardWidth`
- `GameScreenMetrics.handCardWidth`

Do not solve the local yellow-box problem by merely shrinking its frame or applying arbitrary offsets. Remove the structural cause: the active-player treatment is currently attached to too large an area.

## 11. Acceptance Criteria

This refresh is complete only when all of the following are true:

- Face-up cards no longer use the old centered rank-over-suit prototype layout.
- Rank and suit are readable in the upper-left corner.
- Number cards use balanced pip layouts.
- Aces have a large central suit.
- J/Q/K have a distinct face-card center treatment.
- Joker is visually distinct and polished.
- Face-down cards use an original red patterned back.
- All card fronts and backs preserve one shared aspect ratio.
- The local human player no longer has a large yellow outline around the entire section.
- The local `Playing` indicator is compact and in normal layout flow.
- The local current-turn treatment does not overlap cards or buttons.
- No overlap occurs for 2 through 5 total players.
- Large hands still scroll horizontally.
- Existing gameplay tests/build behavior remain unchanged.
- `Game.swift` is not modified for visual-only work.

## 12. Build and Review

Before considering the task complete:

1. Build the app successfully in Xcode.
2. Run in an iPhone portrait simulator.
3. Verify 2, 3, 4, and 5 total-player configurations.
4. Verify local-turn and opponent-turn states.
5. Verify face-up and face-down cards at local, opponent, draw-pile, Play-Pile, and discard-pile sizes.
6. Verify no overlap with Play and Pick Up controls.
7. Review the diff for accidental gameplay changes.
