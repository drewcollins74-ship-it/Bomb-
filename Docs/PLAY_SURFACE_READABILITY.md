# Bomb! Play Surface Readability Refresh

This document is the current scoped implementation directive for reclaiming vertical space on the active game screen and using that space to improve card readability.

Read this together with:

- `Docs/UI_DESIGN.md`
- `Docs/VISUAL_REFRESH.md`
- `Docs/GAME_RULES.md`

Where this document is more specific about the active-game footer, top-header spacing, play-surface allocation, safe-area handling, or card sizing, this document controls the current refresh.

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
- Use actual safe-area information and normal SwiftUI layout flow.

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
- The Play Pile must be materially larger than its current implementation.
- Increase `playPileCardWidth` as much as practical without breaking the three-pile center layout.
- The Play Pile is a primary gameplay focus and should receive higher sizing priority than decorative spacing.
- The Play Pile should be as close as practical to local hand-card size.
- Continue showing up to the 3 most recent Play Pile cards.
- Preserve light horizontal overlap.
- Keep the newest/top card visually dominant.
- Preserve readable rank/suit information on underlying visible cards.
- Reposition or resize the Play Pile count badge if it obscures card information.
- Draw Pile count and Play Pile count must remain readable and must not obscure critical card information.
- Enlarged Play Pile cards must not overlap:
  - Draw Pile
  - Discard Pile
  - `Pick Up`
  - local Player / Playing row

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
- 10 clear logic
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
- Play Pile cards are materially larger than the previous implementation.
- The Play Pile is visually more prominent than the Draw and Discard piles.
- Empty space above the playable content is materially reduced from the previous implementation.
- In 4- and 5-player layouts, local human setup cards remain comfortably readable.
- In 4- and 5-player layouts, local human hand cards remain comfortably readable.
- Local human card readability is prioritized over opponent-card size when space is constrained.
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

- The Play Pile must be materially larger than its current implementation.
- Increase `playPileCardWidth` as much as practical without breaking the three-pile center layout.
- The Play Pile should be as close as practical to local hand-card size.
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

- The Play Pile is a primary gameplay focus and should receive higher sizing priority than decorative spacing.

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
- Play Pile cards are materially larger than the previous implementation
- the Play Pile is visually more prominent than the Draw and Discard piles
- up to 3 recent Play Pile cards remain understandable
- no opponent overlap
- no opponent-to-center overlap
- no Play Pile overlap with Draw or Discard piles
- no Play Pile overlap with `Pick Up`
- no Play Pile overlap with local Player / Playing controls
- no card distortion
- `Bomb/Game.swift` remains unchanged

### 13.6 Further Top-Space Reduction Is Still Required

A subsequent visual review shows that the active game screen still leaves too much unused vertical space above the playable content.

Required:

- Reduce remaining empty vertical space between the safe-area boundary and the header row further.
- Move the playable content upward again while still respecting the actual safe area.
- Tighten spacing between:
  - header controls
  - Bomb! title
  - `Opponents` label
  - opponent rows
  - status/action row
  - center piles
- Review both major section heights and internal section spacing; do not assume the remaining gap is caused only by `topPadding`.
- Trace every layout term that contributes to the top gap, including fixed frames, vertical padding, section spacing, and safe-area handling.
- Do not use hard-coded one-device offsets as the primary fix.
- Do not overlap the status bar, Dynamic Island, or system indicators.

Acceptance requirement:

- On the primary iPhone portrait layout, the top section must be visibly higher than the current implementation and must leave materially less empty space above the game content.

### 13.7 In 4- and 5-Player Layouts, Human Cards Must Not Become Too Small

A subsequent visual review shows that in 4- and 5-player layouts, the local human player's cards become too small to read comfortably.

Required:

- Preserve comfortable readability for the local human player's setup cards and hand cards in 4- and 5-player layouts.
- Do not allow the human player's cards to shrink below a reasonable readable minimum merely to fit more opponent content above.
- The local human player's cards have higher readability priority than opponent cards.
- If space is constrained in 4- or 5-player layouts, prefer:
  1. reducing excess top whitespace,
  2. tightening vertical spacing,
  3. making opponent sections more compact,
  4. scaling opponent cards by opponent count,
  5. using horizontal scrolling for the local hand,
  before shrinking the human player's cards further.
- `handCardWidth` and `playerSetupCardWidth` should maintain a readable minimum in 4- and 5-player layouts.
- Do not force the local human player's cards to match the smallest opponent-card sizing.
- Preserve one shared playing-card aspect ratio.
- Trace every formula that reduces `handCardWidth` or `playerSetupCardWidth` as player count increases.
- Fix the structural cause rather than applying a screenshot-specific minimum after the fact.
- If the current layout derives local card size from leftover `playerHeight`, ensure opponent growth does not consume so much height that local cards become unreadable.

Acceptance requirements:

- In 4-player layouts, local human setup cards remain comfortably readable at normal device scale.
- In 5-player layouts, local human setup cards remain comfortably readable at normal device scale.
- In 4-player layouts, local human hand cards remain comfortably readable at normal device scale.
- In 5-player layouts, local human hand cards remain comfortably readable at normal device scale.
- Local human card readability takes precedence over preserving maximum opponent-card size when the layout is constrained.

### 13.8 Safe-Area Audit and Dynamic-Island Gap Reduction

A subsequent visual review shows that the remaining top gap may be caused by duplicated or unnecessary safe-area accounting rather than only by a large `topPadding` constant.

This is a required diagnostic and implementation pass.

Required audit:

- Inspect the complete active-game view hierarchy before changing constants.
- Determine whether a parent container already positions content below the top safe area.
- Search for every source of top inset or top spacing, including:
  - `geometry.safeAreaInsets.top`
  - `.safeAreaPadding(.top)`
  - `.safeAreaInset(edge: .top)`
  - `.padding(.top, ...)`
  - custom `topPadding`
  - fixed `headerHeight`
  - internal vertical padding inside `header(metrics:)`
  - top-level `VStack` spacing
  - parent containers that already respect safe areas
  - `ignoresSafeArea` usage that changes which geometry includes system regions
- Trace the Y-position of the first header content from the root active-game view downward.
- Identify every term contributing vertical space above the header.

Safe-area rule:

- The effective top safe-area inset must be counted exactly once.
- Do not add `geometry.safeAreaInsets.top` again if the parent layout has already placed the content below the safe-area boundary.
- Do not combine multiple safe-area mechanisms unless each contribution is intentional and non-duplicative.
- The intended relationship is:
  1. system status / Dynamic Island region
  2. actual safe-area boundary
  3. small intentional visual gap
  4. header controls
- Do not leave a second safe-area-sized blank band below the actual safe-area boundary.

Structural fix requirements:

- Fix duplicate inset accounting before tuning cosmetic constants.
- Remove unnecessary top inset or padding structurally.
- Reduce excessive fixed `headerHeight` if it reserves blank space.
- Reduce unnecessary internal header vertical padding.
- Tighten section spacing below the header after the safe-area path is correct.
- Do not use an arbitrary negative Y offset as the primary solution.
- Do not use device-specific magic numbers as the primary solution.
- Do not move controls under system UI.

Reclaimed-space priority:

1. protect local human hand-card readability
2. protect local human setup-card readability
3. enlarge the Play Pile
4. enlarge opponent cards where responsive space permits
5. preserve safe separation between controls and cards

Acceptance requirements:

- The safe-area handling path is explicitly audited.
- Any duplicated top inset is removed.
- The effective top safe-area inset is counted exactly once.
- The header sits materially closer to the actual safe-area boundary than before.
- Only a small intentional gap remains below the safe-area boundary.
- No status-bar, Dynamic Island, signal, Wi-Fi, or battery overlap occurs.
- Reclaimed height benefits gameplay layout rather than becoming new decorative whitespace.
- 2-through-5-player layouts remain supported.
- `Bomb/Game.swift` remains unchanged.

Required implementation report:

1. whether the top safe-area inset was being double-counted
2. every source of vertical space found above the header
3. which source or sources were removed or reduced
4. previous and new `topPadding` behavior
5. previous and new `headerHeight` behavior
6. devices or simulators tested
7. player counts tested
8. any remaining top-layout constraints
9. confirmation that `Bomb/Game.swift` was not modified
