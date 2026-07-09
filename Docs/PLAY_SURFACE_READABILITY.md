# Bomb! Play Surface Readability Refresh

This document is the current scoped implementation directive for reclaiming vertical space on the active game screen and using that space to improve card readability.

Read this together with:

- `Docs/UI_DESIGN.md`
- `Docs/VISUAL_REFRESH.md`
- `Docs/GAME_RULES.md`

Where this document is more specific about the active-game footer, top-header spacing, play-surface allocation, or card sizing, this document controls the current refresh.

Gameplay behavior remains authoritative in `Docs/GAME_RULES.md`.

## 1. Goals

Implement a layout/readability refresh only.

Primary goals:

1. Remove the bottom Goal / Rules footer from the active game screen.
2. Move the top controls and Bomb! title upward within the safe area.
3. Reclaim vertical space for the playing surface.
4. Increase card sizes so ranks, suits, pips, face-card artwork, and Joker treatment are easier to read on a physical iPhone.
5. Preserve responsive support for 2 through 5 total players.
6. Preserve all gameplay behavior.

Card readability has priority over decorative whitespace.

## 2. Active-Game Footer Removal

The active game screen must no longer display the bottom footer containing:

- the information icon
- `Goal:`
- `Be the first to get rid of all cards.`
- the `Rules` button

Required:

- Remove the footer structurally from the active-game layout.
- Do not merely hide it with `.opacity(0)`, `.hidden()`, or an off-screen offset.
- Do not continue reserving `footerHeight` or equivalent vertical space for it.
- Remove or stop calling the active-game `footer(metrics:)` view.
- Reclaim the former footer height for gameplay content.
- If rules access is added again later, it must be handled by a separate explicit design decision; do not relocate the Rules button as part of this task.

The New Game setup flow is not affected.

## 3. Top Header Position

The top active-game controls currently leave excessive unused vertical space below the iPhone status area. Reclaim that space.

Affected controls include:

- menu button
- New Game / restart button
- Bomb! title
- settings button

Required:

- Move the header row upward as far as practical while respecting the actual safe area.
- Do not overlap the status bar, Dynamic Island, sensor housing, or system indicators.
- Reduce unnecessary top padding between the safe-area boundary and the header row.
- Reduce excessive header height if the current calculation reserves more height than the controls need.
- Keep all header controls comfortably tappable.
- Keep horizontal alignment visually balanced.
- Do not use a hard-coded negative Y offset that only works on one iPhone.
- Use `geometry.safeAreaInsets` and normal SwiftUI layout flow.

The intended result is less dead space above the game and more usable play-surface height below.

## 4. Reallocation of Reclaimed Space

Space reclaimed from:

- the removed footer
- reduced top padding
- reduced unnecessary header height

must be used primarily to improve gameplay readability.

Priority order:

1. Increase local hand-card size.
2. Increase local setup-card size.
3. Increase opponent setup-card size.
4. Increase Draw Pile and Discard Pile card size.
5. Increase Play Pile card size while preserving visibility of up to the 3 most recent cards.
6. Preserve safe separation between sections and controls.

Do not spend the reclaimed space mainly on decorative gaps, larger labels, or larger empty margins.

## 5. Card Readability Requirement

The current card presentation is visually improved but still too difficult to read at physical iPhone size.

Required:

- Increase card widths where reclaimed space allows.
- Preserve `PlayingCardLayout.aspectRatio` for all fronts and backs.
- Never stretch cards independently by width and height.
- Increase the upper-left rank/suit index proportionally with card size.
- Ensure the rank/suit index remains readable on opponent cards and central-pile cards.
- Ensure number-card pips remain distinguishable.
- Ensure J/Q/K center treatments remain distinguishable.
- Ensure Joker remains identifiable without relying on tiny detail.
- Preserve consistent corner radius, border, and shadow treatment across sizes.

### 5.1 Local Hand

- Increase `handCardWidth` compared with the current layout when space allows.
- A local hand larger than the visible width must continue to scroll horizontally.
- Do not shrink a 12-card or larger hand until all cards fit; preserve readable size and rely on horizontal scrolling.
- The first and last card must remain reachable in the scroll view.
- The hand row must not overlap the footer because the footer no longer exists.
- The hand row must remain within the safe bottom area.

### 5.2 Local Setup Cards

- Increase `playerSetupCardWidth` when reclaimed height allows.
- Keep all three setup positions visible.
- Keep the `Your 3 setup cards` label separate from the cards.
- Keep the local Player / Playing row separate from the setup-card label and cards.
- Do not allow the compact Playing badge to overlap enlarged cards.

### 5.3 Opponent Cards

- Increase `opponentCardWidth` when layout allows.
- Preserve name and `Hand: N` readability.
- Preserve visible correspondence between face-up and face-down setup cards.
- For 4 or 5 total players, card enlargement must not create overlap between opponent tiles.
- If the 5-player configuration is the limiting case, use responsive sizing by opponent count rather than forcing one universal width.

### 5.4 Draw, Play, and Discard Piles

- Increase `pileCardWidth` when reclaimed height allows.
- Increase `playPileCardWidth` when reclaimed width/height allows.
- The Play Pile remains visually central.
- Continue showing up to the 3 most recent Play Pile cards.
- Preserve readable rank/suit information on underlying visible Play Pile cards.
- Draw Pile count and Play Pile count must remain readable and must not obscure critical card information.
- Enlarged pile cards must not overlap the local Player / Playing row.

## 6. `GameScreenMetrics` Requirements

Review the current metric calculations as a system rather than changing one card-width constant in isolation.

Inspect and rebalance at minimum:

- `topPadding`
- `bottomPadding`
- `sectionSpacing`
- `availableHeight`
- `headerHeight`
- `footerHeight`
- `playerHeight`
- `centerHeight`
- `opponentsHeight`
- `playerSetupCardWidth`
- `handCardWidth`
- `opponentCardWidth`
- `pileCardWidth`
- `playPileCardWidth`

Required structural changes:

- Remove footer allocation from `availableHeight` calculations.
- Remove `footerHeight` from `playerHeight` and other section calculations.
- Delete `footerHeight` if it is no longer used; do not leave dead layout allocation behind.
- Recalculate the remaining major sections from actual available safe height.
- Prefer card-size growth before adding decorative vertical spacing.
- Keep clamp logic responsive; do not replace it with one-device constants.

## 7. Layout Strategy

Required:

- Use normal SwiftUI layout flow.
- Use available geometry and safe-area insets.
- Avoid absolute screen coordinates.
- Avoid arbitrary negative offsets for primary positioning.
- Avoid negative padding as the main solution.
- Avoid hiding overflow caused by bad sizing.
- Do not solve enlarged-card collisions by clipping interactive content.
- Do not allow overlays such as count badges or Playing badges to claim unreserved space that collides with neighboring controls.

The goal is a structurally sound layout, not a screenshot-specific patch.

## 8. Responsive Validation

Test all supported total-player counts:

- 2 players
- 3 players
- 4 players
- 5 players

For each configuration verify:

- header respects safe area
- no excessive dead space above header
- no footer remains
- local cards are larger than before when space permits
- opponent cards are larger than before when space permits
- pile cards are larger than before when space permits
- no opponent overlap
- no opponent-to-pile overlap
- no pile-to-local-player overlap
- no local setup-card overlap
- no local hand overlap
- no Play button overlap
- no Pick Up overlap
- no Playing badge overlap
- no card distortion

Also test:

- local hand of 3 cards
- local hand of 6 cards
- local hand of 12 cards
- local hand greater than 12 cards after pickup
- local player's turn
- opponent's turn
- clockwise direction
- counterclockwise direction
- non-empty Draw Pile
- nearly empty Draw Pile
- Play Pile with 1 card
- Play Pile with 2 cards
- Play Pile with 3 or more cards

## 9. Functional Boundaries

Do not change:

- card legality
- turn order
- direction logic
- Bomb logic
- 10-clear logic
- Joker logic
- forced pickup logic
- voluntary pickup logic
- computer strategy
- winner detection
- hand sorting rules
- animation sequencing except for layout alignment required by resized card destinations

Do not modify `Bomb/Game.swift` for this visual/layout task.

`Game.swift` remains the gameplay source of truth.

## 10. Implementation Targets

Primary file:

- `Bomb/ContentView.swift`

Review specifically:

- `GameScreen.body`
- top-level `VStack` section structure
- `header(metrics:)`
- `footer(metrics:)`
- `localPlayerSection(metrics:)`
- `opponentsSection(metrics:)`
- `tableCenter(metrics:)`
- `GameScreenMetrics`
- card animation anchors after card resizing

Secondary file only if readability scaling inside the cards needs adjustment:

- `Bomb/CardView.swift`

Use `CardView.swift` only for proportional internal readability changes such as rank/suit index sizing, pip sizing, or face-card/Joker simplification at small sizes. Do not alter gameplay.

## 11. Acceptance Criteria

This refresh is complete only when:

- The Goal / Rules footer is absent from the active game screen.
- No vertical space is reserved for that footer.
- The top header sits closer to the safe-area boundary than before.
- The header does not overlap system UI.
- Reclaimed space is used primarily for larger cards.
- Local hand cards are visibly easier to read.
- Local setup cards are visibly easier to read.
- Opponent cards are visibly easier to read where responsive space permits.
- Central pile cards are visibly easier to read where responsive space permits.
- Rank/suit indexes remain readable.
- All cards preserve one shared aspect ratio.
- Horizontal hand scrolling still works for large hands.
- No overlap occurs for 2 through 5 total players.
- Existing gameplay behavior is unchanged.
- `Bomb/Game.swift` is not modified.

## 12. Build and Review

Before considering the task complete:

1. Build successfully in Xcode.
2. Run on the iPhone Air simulator or the current primary iPhone portrait simulator.
3. Run on at least one narrower iPhone portrait simulator.
4. Verify 2, 3, 4, and 5 total-player configurations.
5. Verify local-turn and opponent-turn states.
6. Verify large-hand horizontal scrolling.
7. Compare physical readability at normal device scale, not only a zoomed simulator screenshot.
8. Review the diff for accidental gameplay changes.
9. Confirm `Bomb/Game.swift` is unchanged.

## 13. Additional Top-Space and High-Priority Card Enlargement Pass

A subsequent visual review shows that the active game screen still leaves recoverable vertical space near the top and that opponent cards and Play Pile cards remain smaller than necessary.

This section is the current priority for the next implementation pass.

### 13.1 Move the Top Content Higher

Required:

- Reduce remaining unused vertical space between the safe-area boundary and the header row.
- Move the menu, restart/New Game control, Bomb! title, and settings control higher while still respecting the actual safe area.
- Tighten vertical spacing between:
  - the header row
  - the `Opponents` label
  - opponent name/hand-count rows
  - opponent card rows
  - the status/action row below opponents
- Review `topPadding`, `headerHeight`, `sectionSpacing`, and opponent-section internal spacing together.
- Do not use a one-device negative Y offset.
- Do not overlap status-bar content, Dynamic Island content, signal indicators, battery indicators, or other system UI.

Acceptance requirement:

- On the primary iPhone portrait layout, the top content must be visibly higher than the previous implementation while remaining safely below system UI.

### 13.2 Opponent Card Enlargement Is Now a Higher Priority

The current opponent cards are still too small relative to the available space.

Required:

- Increase `opponentCardWidth` materially when responsive space allows.
- Prefer slightly tighter non-card spacing before giving up opponent card size.
- Preserve opponent name and `Hand: N` readability.
- Preserve face-up/face-down setup-card correspondence.
- For 4- and 5-player layouts, size cards responsively by opponent count if necessary.
- Do not force the smallest 5-player card width onto 2- or 3-player layouts.
- Do not create overlap between opponent tiles or between opponents and the center table area.

Priority rule:

- After safe top-spacing reduction, reclaimed space should be used for larger opponent cards before being spent on decorative whitespace.

### 13.3 Play Pile Enlargement Is Now a Higher Priority

The Play Pile remains the central gameplay focus and should be easier to read.

Required:

- Increase `playPileCardWidth` materially where layout allows.
- Continue displaying up to the 3 most recent cards.
- Preserve light horizontal overlap so underlying cards remain identifiable.
- Keep the newest/top card visually dominant.
- Preserve readable rank/suit information on underlying cards.
- Reposition or resize the Play Pile count badge if needed so it does not obscure critical card information.
- Ensure the enlarged Play Pile does not overlap:
  - Draw Pile
  - Discard Pile
  - `Pick Up`
  - the local Player / Playing row

Priority rule:

- The Play Pile should be as close as practical to local hand-card size without breaking the three-pile center layout.

### 13.4 Metric Rebalancing for This Pass

Review and adjust at minimum:

- `topPadding`
- `headerHeight`
- `sectionSpacing`
- `opponentsHeight`
- opponent-section internal spacing
- `centerHeight`
- `playerHeight`
- `opponentCardWidth`
- `pileCardWidth`
- `playPileCardWidth`

Required:

- Treat these values as an interdependent layout system.
- Do not solve the request by changing only one maximum-width constant.
- Use responsive clamps and available geometry.
- Preserve all card aspect ratios.
- Preserve 2-through-5-player support.

### 13.5 Validation for This Pass

Verify all of the following:

- top content is visibly higher than before
- no system-UI overlap
- opponent cards are visibly larger in 2- and 3-player layouts
- opponent cards enlarge where feasible in 4- and 5-player layouts
- Play Pile cards are visibly larger
- up to 3 recent Play Pile cards remain understandable
- no opponent overlap
- no opponent-to-center overlap
- no Play Pile overlap with Draw or Discard piles
- no Play Pile overlap with `Pick Up`
- no Play Pile overlap with local Player / Playing controls
- no card distortion
- `Bomb/Game.swift` remains unchanged
