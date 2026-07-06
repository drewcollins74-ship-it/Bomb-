# Bomb! UI Design Specification

This document is the authoritative visual, layout, interaction-presentation, and animation specification for Bomb!. Gameplay rules remain authoritative in Docs/GAME_RULES.md.

## 1. Design Goals

- Current design requirement: Bomb! uses a mobile-first iPhone layout.
- Current design requirement: the active game screen should feel like a card table.
- Current design requirement: readability is more important than decorative complexity.
- Current design requirement: the human player area receives the strongest emphasis.
- Current design requirement: opponents remain compact but readable.
- Current design requirement: the current turn must always be obvious.
- Current design requirement: recent Play Pile activity must be understandable.
- Current design requirement: all cards preserve a consistent playing-card aspect ratio.
- Current design requirement: the layout scales cleanly for 2 through 5 total players.
- Current design requirement: avoid unnecessary boxes, heavy borders, and dark section container backgrounds.
- Current design requirement: preserve the existing visual identity unless explicitly changed.

## 2. Screen Structure

Current design requirement:

- Header / game status area.
- Opponent player areas.
- Central table area.
- Draw Pile.
- Play Pile.
- Discard Pile when visibly represented.
- Local player setup cards.
- Local player remaining hand.
- Primary gameplay controls.

The active game screen should preserve this hierarchy:

1. Current turn state.
2. Active Play Pile.
3. Player cards.
4. Secondary pile counts and controls.

The New Game setup screen remains a separate setup flow. It allows the local player to enter a name, choose 2 through 5 total players, and start a fresh game.

## 3. Responsive Player Layout

- Current design requirement: support 2 to 5 total players.
- Current design requirement: opponent areas reposition and scale based on opponent count.
- Current design requirement: five-player layout is explicitly supported.
- Current design requirement: avoid hard-coded positioning that only works for one player count.
- Current design requirement: use available geometry and player count to determine spacing.
- Current design requirement: preserve usable separation at narrow iPhone widths.

Player panels and content must never overlap:

- Other player areas.
- Draw Pile.
- Play Pile.
- Discard Pile.
- Local player area.

Opponent areas should not use unnecessary:

- Large bordered containers.
- Thin gold/orange outline boxes.
- Darker rectangular background panels.

Player information should appear integrated into the table rather than inside visually heavy boxes.

## 4. Card Geometry

- Current design requirement: all playing cards use one consistent aspect ratio.
- Current design requirement: the shared card aspect ratio is defined by `PlayingCardLayout.aspectRatio`.
- Current design requirement: card width and height may scale, but the ratio must not distort.
- Current design requirement: a card must not become short-and-wide because of available space.
- Current design requirement: human hand cards, setup cards, opponent cards, and Play Pile cards share the same visual proportions.
- Current design requirement: size differences are allowed only through proportional scaling.

## 5. Opponent Presentation

- Current design requirement: each opponent displays the player name.
- Current design requirement: each opponent displays current hand count, for example `Hand: 3`.
- Current design requirement: hand count is read from the actual player model.
- Current design requirement: hand count includes only cards currently in that opponent's hand.

Hand count does not include:

- Face-up setup cards.
- Face-down cards.
- Play Pile cards.
- Draw Pile cards.
- Discard Pile cards.

Opponent setup presentation:

- Current design requirement: 3 face-down setup cards remain visually identifiable while present.
- Current design requirement: face-up setup cards appear on top of corresponding face-down cards.
- Current design requirement: overlap should be readable.
- Current design requirement: card identity should not be unnecessarily obscured.

## 6. Local Player Setup Cards

- Current design requirement: show 3 face-down setup positions while present.
- Current design requirement: show up to 3 face-up setup cards positioned on top of corresponding face-down setup cards.
- Current design requirement: face-up cards must visually correspond to their setup positions.
- Current design requirement: setup-card labels must not overlap cards.
- Current design requirement: informational text such as `Face-Down Cards: 3` must have sufficient spacing below or away from the card row.

During gameplay:

- Hand cards are tappable only in hand phase.
- Face-up setup cards are tappable only when allowed by the phase rules in Docs/GAME_RULES.md.
- Face-down cards are tappable only when allowed by the phase rules in Docs/GAME_RULES.md.

## 7. Local Player Hand

- Current design requirement: the remaining hand appears in one readable row.
- Current design requirement: cards preserve aspect ratio.
- Current design requirement: large hands after pickup must not compress into unreadable cards.
- Current design requirement: use horizontal scrolling when required.
- Current design requirement: keep the surrounding game layout fixed.
- Current design requirement: do not allow a large hand to push or resize the entire table unpredictably.

Required hand sort order:

`Joker → 10 → 2 → A → K → Q → J → 9 → 8 → 7 → 6 → 5 → 4 → 3`

- Current design requirement: same ranks remain grouped.
- Current design requirement: suit order is not strategically important and may remain stable.

## 8. Central Piles

### Draw Pile

- Current design requirement: the Draw Pile is clearly identifiable.
- Current design requirement: the Draw Pile count remains readable.
- Current design requirement: the Draw Pile must not overlap player areas.

### Play Pile

- Current design requirement: the Play Pile is visually central and prominent.
- Current design requirement: display the Play Pile card count.
- Current design requirement: the count updates from actual game state.
- Current design requirement: show the 3 most recent Play Pile cards when available.
- Current design requirement: oldest of the visible 3 appears on the left.
- Current design requirement: newest/top card appears on the right.
- Current design requirement: cards should be side-by-side or use light horizontal overlap.
- Current design requirement: rank and suit of underlying visible cards remain readable.
- Current design requirement: Play Pile cards should be as close as practical to local hand-card size without breaking layout.
- Current design requirement: do not revert to tiny unreadable stack cards.

### Discard Pile

- Current design requirement: Discard Pile presentation is secondary to Draw Pile and Play Pile.
- Current design requirement: UI should not confuse Discard Pile with the active Play Pile.
- Gameplay reference: Discard Pile contents and clear behavior are defined in Docs/GAME_RULES.md.

## 9. Current Player Indicator

- Current design requirement: exactly one current player is visually identified.
- Current design requirement: the active player is derived from `game.currentPlayerIndex`.
- Current design requirement: use subtle outline/glow emphasis around the player's existing area.
- Current design requirement: use a small `Playing` badge or equivalent text indicator.
- Current design requirement: do not create a large new container solely for the current-player indicator.
- Current design requirement: on a 10 or Bomb extra turn, the same player remains highlighted.
- Current design requirement: on turn advancement, the indicator updates immediately.

## 10. Direction Indicator

Current design requirement: display current direction near game status:

- `↻ Clockwise`
- `↺ Counterclockwise`

Requirements:

- Current design requirement: derive direction from actual game direction state.
- Current design requirement: update immediately after Joker resolution.
- Current design requirement: presentation must not duplicate Joker logic.
- Current design requirement: `Game` remains the source of truth.

## 11. Status and Action Messaging

The UI must distinguish:

- Current player state.
- Most recent completed action.

Examples:

- `Your Turn`
- `Computer 1 played 3 × 6`
- `Computer 2 picked up the Play Pile`
- Bomb or clear messages.

- Current design requirement: do not replace persistent current-player indication with only a last-action message.
- Current design requirement: the UI should make both facts understandable:
  - What just happened.
  - Whose turn it is now.

## 12. Controls

### Play Control

- Current design requirement: the Play control acts on the currently selected legal cards.
- Current design requirement: selection and legality come from current game state.
- Current design requirement: disabled state must reflect turn, phase, selected cards, and active presentation animations.

### Voluntary Pick Up

- Current design requirement: voluntary Pick Up remains available only where Docs/GAME_RULES.md permits.
- Current design requirement: voluntary Pick Up must not be confused with the forced pickup notification flow.
- Current design requirement: voluntary Pick Up is disabled when the Play Pile is empty.

### New Game

- Current design requirement: New Game is a compact persistent control in the active game header.
- Current design requirement: it should fit the existing header styling.
- Current design requirement: it must not significantly alter layout.

New Game confirmation:

- Title: `Start New Game?`
- Message: `Your current game progress will be lost.`
- Actions:
  - `Cancel`
  - `Start New Game`

On confirmation:

- Current design requirement: return to the existing new-game setup flow.
- Current design requirement: clear transient presentation state.
- Current design requirement: do not create duplicate game-initialization logic.

## 13. Forced Pickup Notification

Current design requirement: when the local human player has no legal play and pickup is mandatory, show a modal notification similar to the New Game alert.

Suggested content:

- Title: `No Legal Play`
- Message: `You must pick up the Play Pile.`
- Action: `Pick Up`

Requirements:

- Current design requirement: no Cancel action.
- Current design requirement: cards do not move until the player confirms.
- Current design requirement: tapping Pick Up automatically performs the forced pickup.
- Current design requirement: applies to forced pickup from hand phase.
- Current design requirement: applies to forced pickup from face-up setup phase.
- Current design requirement: does not apply to voluntary pickup.
- Current design requirement: does not apply to computer players.
- Current design requirement: does not apply to the illegal face-down reveal sequence.
- Current design requirement: computer forced pickup remains automatic.
- Current design requirement: prevent duplicate alerts.
- Current design requirement: prevent duplicate pickup.
- Current design requirement: prevent duplicate turn advancement.

Gameplay reference: actual pickup behavior is defined in Docs/GAME_RULES.md.

## 14. Win Notification

Current design requirement: show a modal win notification whenever `game.winnerIndex` identifies a winner.

Source of truth:

- Current design requirement: the UI must not independently determine whether a player has won.
- Current design requirement: `Game` remains the source of truth for winner state.
- Gameplay reference: winning conditions and final-card resolution are defined in Docs/GAME_RULES.md.

Required timing sequence:

1. The final card completes its normal play animation.
2. Resolve all gameplay effects from that final legal play.
3. If the final play causes a 10 clear or Bomb, complete the Play Pile explosion animation first.
4. If the final play uses a Joker, allow direction state to resolve normally.
5. Confirm the winner from actual game state.
6. Show the win notification.

The win popup must not appear before the final play is visually complete.

### Local Human Winner

- Title: `You Win!`
- Message: `Congratulations! You won the game.`
- Action: `New Game`

### Computer Winner

- Title: `[Player Name] Wins!`
- Example: `Computer 1 Wins!`
- Message: `Game over.`
- Action: `New Game`
- Current design requirement: use the actual winning player name from game state.

### New Game Action

When the player taps `New Game`:

- Current design requirement: return to the existing New Game setup flow.
- Current design requirement: discard the completed game.
- Current design requirement: clear selected card IDs.
- Current design requirement: clear active card-play animation state.
- Current design requirement: clear Play Pile explosion state.
- Current design requirement: clear forced-pickup alert state.
- Current design requirement: clear computer auto-play scheduling state.
- Current design requirement: clear win-notification presentation state.
- Current design requirement: do not create duplicate game-initialization logic.
- Current design requirement: reuse the same reset/new-game flow already defined elsewhere in this specification.

### Modal Behavior

While the win notification is visible:

- Current design requirement: no card interaction is allowed behind the modal.
- Current design requirement: no further computer turn may begin.
- Current design requirement: no additional gameplay mutation may occur.
- Current design requirement: no forced-pickup notification may appear.
- Current design requirement: no duplicate win popup may appear.
- Current design requirement: no additional animation may start.
- Current design requirement: the completed game remains frozen.

### Presentation Consistency

- Current design requirement: use the same general native SwiftUI alert/modal style as the forced-pickup notification and Start New Game confirmation.
- Current design requirement: do not create a large custom winner screen.
- Current design requirement: do not redesign the active game board.
- Current design requirement: keep the presentation clear and immediate.
- Current design requirement: the popup should visually communicate that the game is over.

### Duplicate Prevention

- Current design requirement: show the win popup exactly once per completed game.
- Current design requirement: re-rendering the SwiftUI view must not present duplicate win notifications.
- Current design requirement: computer auto-play scheduling stops as soon as a winner exists.
- Current design requirement: starting a new game clears any stale win-notification state.

## 15. Card Play Animation

- Current design requirement: a played card visibly moves from the acting player area to the Play Pile.
- Current design requirement: duration is approximately 0.4 to 0.6 seconds.
- Current design requirement: human origin is the selected hand/setup card area when practical.
- Current design requirement: opponent origin is the acting opponent area.
- Current design requirement: do not reveal hidden opponent hand cards before they are played.
- Current design requirement: grouped same-rank plays animate as a grouped or lightly staggered movement.
- Current design requirement: actual destination is the Play Pile.

Sequence:

1. Begin animation.
2. Card travels to Play Pile.
3. Card arrives.
4. Gameplay resolution becomes visually apparent.
5. Next automatic computer action waits until presentation is complete.

Architecture:

- Current design requirement: use temporary presentation overlay state.
- Current design requirement: do not make SwiftUI animation state the source of gameplay truth.

## 16. Computer Turn Pacing

- Current design requirement: computer actions must be visible to the human player.
- Current design requirement: use a brief pause between computer turns.
- Current design requirement: approximately 1 second is acceptable for normal pacing.
- Current design requirement: next computer action must not begin while card-play animation is active.
- Current design requirement: next computer action must not begin while Play Pile explosion is active.
- Current design requirement: next computer action must not begin while a modal interaction blocks progression.
- Current design requirement: no computer action may begin after a winner exists.
- Current design requirement: no computer action may begin while the win notification is active.
- Current design requirement: do not rapidly skip through multiple computer actions invisibly.

## 17. Play Pile Explosion

Current design requirement: trigger a Play Pile explosion whenever the Play Pile is cleared by:

1. A played 10.
2. A Bomb formed by four consecutive cards of the same rank.

The same general explosion treatment should be used for both.

Required sequence:

1. Played card or cards complete normal movement into the Play Pile.
2. Completed pile is briefly visible.
3. Visible Play Pile explodes outward.
4. Cards rotate and scatter in different directions.
5. Cards fade out.
6. Play Pile becomes visually empty.
7. Gameplay continues.

Suggested timing:

- Pause after landing: approximately 0.15 to 0.25 seconds.
- Explosion: approximately 0.5 to 0.8 seconds.

Visual treatment:

- Current design requirement: cards burst from Play Pile center.
- Current design requirement: varied directions.
- Current design requirement: varied rotation.
- Current design requirement: slight scale variation.
- Current design requirement: fade out.
- Current design requirement: optional subtle shockwave ring.
- Planned presentation requirement: optional lightweight particle burst.
- Current design requirement: native SwiftUI only.
- Current design requirement: no third-party animation library.

Important:

- Current design requirement: explosion includes the visible pile contents, not only the newly played card.
- Current design requirement: preserve a temporary visual snapshot if game state clears immediately.
- Current design requirement: `Game` remains source of truth.
- Current design requirement: next computer action waits until explosion ends.
- Current design requirement: prevent overlapping explosions.
- Current design requirement: starting a new game clears stale explosion state.

## 18. Animation Architecture

- Current design requirement: gameplay state and presentation state remain separate.
- Current design requirement: `Game.swift` is the source of truth for cards, turn, direction, legality, clears, Bomb detection, and winner state.
- Current design requirement: `ContentView.swift` and SwiftUI presentation state may manage temporary card movement.
- Current design requirement: SwiftUI presentation state may manage explosion snapshots.
- Current design requirement: SwiftUI presentation state may manage alert visibility.
- Current design requirement: SwiftUI presentation state may manage win-notification visibility.
- Current design requirement: SwiftUI presentation state may manage pacing.
- Current design requirement: `game.winnerIndex` remains the source of truth for the winner.
- Current design requirement: SwiftUI must not recalculate winning conditions.
- Current design requirement: do not duplicate gameplay rules in view code.
- Current design requirement: do not independently recalculate Bomb logic in the UI.

## 19. Modal Interaction Rules

While a modal alert is active:

- Current design requirement: prevent unintended card interaction behind the alert.
- Current design requirement: prevent duplicate state mutation.
- Current design requirement: prevent computer auto-play from advancing through a human-required confirmation or completed-game modal.

Applicable alerts:

- `Start New Game?`
- `No Legal Play`
- Win notification.

## 20. Visual Consistency

- Current design requirement: preserve current overall Bomb! identity.
- Current design requirement: avoid unnecessary visual clutter.
- Current design requirement: avoid heavy containers.
- Current design requirement: keep typography readable on iPhone.
- Current design requirement: maintain consistent spacing.
- Current design requirement: keep card corners, proportions, and scaling consistent.
- Current design requirement: preserve clear separation of interactive and informational elements.
- Current design requirement: use subtle emphasis rather than oversized decoration.

## 21. Accessibility and Usability

- Current design requirement: interactive controls must have reasonable tap targets.
- Current design requirement: important game state must not rely only on color.
- Current design requirement: current-player indicator should combine visual emphasis with text such as `Playing`.
- Current design requirement: card rank and suit must remain readable.
- Current design requirement: alerts must clearly state required action.
- Current design requirement: horizontally scrollable hands must remain discoverable and usable.

## 22. Open Design Decisions

- Open design decision: exact final icon/text treatment for New Game.
- Open design decision: exact final explosion particle intensity.
- Open design decision: exact final shockwave appearance.
- Open design decision: whether Discard Pile receives a larger visual treatment later.
- Open design decision: whether the one-card face-up setup presentation rule changes if Docs/GAME_RULES.md changes.
- Open design decision: whether additional animations are later added for:
  - Drawing.
  - Pickup.
  - Initial deal.
  - Pile clear beyond explosion.

Do not resolve these without explicit instruction.

## 23. Implementation Notes

- Current design requirement: avoid hard-coded layout that only works for 3 players.
- Current design requirement: preserve mobile aspect ratios.
- Current design requirement: central pile sizing must not break opponent layout.
- Current design requirement: hand scrolling should not resize the entire board.
- Current design requirement: presentation delays must not mutate turn logic independently.
- Current design requirement: current player and direction indicators must read actual game state.
- Current design requirement: planned and executed computer card plays must remain visually consistent.
- Current design requirement: use available screen geometry and safe area when calculating major layout sections.
- Current design requirement: keep gameplay logic out of SwiftUI view bodies.

## 24. UI Change Log

- 2026-07-06: Authoritative UI specification created.
- 2026-07-06: Added required modal win notification behavior for local human and computer winners, including animation sequencing, game freeze, duplicate prevention, and New Game flow.
