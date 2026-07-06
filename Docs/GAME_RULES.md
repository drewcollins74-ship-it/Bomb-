# Bomb! Game Rules

This document is the authoritative gameplay specification for Bomb!. Future gameplay changes should be checked against these rules.

## 1. Game Setup

- Bomb! supports 2 to 5 total players.
- Version 1 has exactly one local human player.
- All other players are computer-controlled opponents.
- Bomb! uses two full decks.
- Each deck has 52 standard cards plus 2 Jokers.
- The full Bomb! deck has 108 cards.
- Each player receives:
  - 3 face-down setup cards.
  - 6 cards in hand.
- Each player chooses exactly 3 of those 6 hand cards to place face-up on top of the 3 face-down cards.
- The remaining 3 cards stay in that player's hand.
- Computer players currently choose their 3 face-up setup cards with a simple temporary strategy.
- Setup is complete only after every player has selected 3 face-up setup cards.

Card collections:

- Draw Pile: undealt cards remaining after setup.
- Play Pile: active cards currently in play.
- Discard Pile: cards permanently cleared from active play by a 10 or Bomb.

### Starting the Game

- At the start of each game, choose one dealer randomly.
- After the normal deal and face-up setup selection are complete, reveal one card from the Draw Pile and place it face-up as the first card of the active Play Pile.
- The revealed opening card is a seed card used to initialize the Play Pile. It is not treated as a card played by a player.
- The player immediately to the left of the dealer takes the first turn.
- Play begins in the normal starting direction.

Opening seed-card behavior:

- Normal rank: establishes the initial playable-rank restriction. The first player must play an equal-or-higher normal rank or an always-playable special card.
- 2: does not trigger a player action, but the opening restriction is reset. The first player may play any rank.
- 10: does not clear the Play Pile and does not grant an extra turn because no player played it. The first player may play any rank.
- Joker: does not reverse direction because no player played it. With no prior playable-rank restriction to preserve, the first player may play any rank.

Once the first player makes an actual play, all normal special-card rules apply immediately. For example:

- Playing a 2 resets the playable-rank restriction.
- Playing a 10 clears the Play Pile and gives that player another turn.
- Playing a Joker reverses direction only.
- Completing four consecutive cards of the same rank creates a Bomb.

## 2. Rank Order

Normal rank order:

`3 < 4 < 5 < 6 < 7 < 8 < 9 < 10 < J < Q < K < A`

- 2 is special.
- Joker is special.
- 2 and Joker are not ordinary positions in the normal rank order.

## 3. Legal Plays

- A normal play must be equal to or higher than the current effective playable rank.
- Example: if the effective playable rank is 6, normal playable ranks are 6, 7, 8, 9, 10, J, Q, K, and A.
- A player may play one or more hand cards together only when all selected cards share the same rank.
- Mixed ranks cannot be played together.
- 2, 10, and Joker are always playable.
- The effective playable rank can differ from the physical top card because Joker does not reset the restriction.
- Example: if a 7 is played, then a Joker is played, the Joker is physically on top but the effective playable rank remains 7.

## 4. Multiple-Card Plays

- Multiple cards played together must share the same rank.
- Hand cards may be played as same-rank groups.
- Current face-up setup-card rule: only one face-up setup card may be played per play.
- The one-face-up-card limit is a current rule and may be revisited later.

## 5. Special Cards

### 2

- Always playable.
- Remains on the Play Pile.
- Does not clear the pile.
- Resets the playable-rank restriction.
- The next player may play any rank.

### 10

- Always playable.
- Immediately clears the entire Play Pile to the Discard Pile.
- The same player goes again.

### Joker

- Always playable.
- Remains on the Play Pile.
- Does not clear the pile.
- Reverses turn direction only.
- Does not reset the playable-rank restriction.
- The previous effective playable-rank restriction remains active after a Joker.
- Each Joker causes one reversal.
- An even number of Jokers played together produces no net reversal.
- An odd number of Jokers played together produces a net reversal.

Important distinction:

- 2 resets the playable-rank restriction.
- Joker does not reset the playable-rank restriction.

## 6. Bomb Rule

- A Bomb occurs when four consecutive cards of the same rank appear at the end of the active Play Pile.
- Suit does not matter.
- Bombs can accumulate across multiple turns.
- Bombs can accumulate across multiple players.
- Multiple same-rank cards played together can complete a Bomb.
- Any rank can form a Bomb, including 2 and Joker.
- Bomb detection uses consecutive trailing cards on the active Play Pile.
- A Bomb clears the entire Play Pile to the Discard Pile.
- The player who completes the Bomb goes again.

Example:

1. Player A plays one 6.
2. Player B plays one 6.
3. Player C plays two 6s.
4. The four trailing cards are all 6s, so Player C creates a Bomb, clears the Play Pile, and goes again.

## 7. Play Pile and Discard Pile

Play Pile:

- Contains active cards currently in play.
- Determines legal play conditions.
- Determines Bomb detection.

Discard Pile:

- Contains cards permanently cleared from active play.
- Receives cards only when the Play Pile is cleared by a 10 or Bomb.

Pickup moves Play Pile cards into a player's hand, not to the Discard Pile.

## 8. Draw and Refill Rule

- After a legal hand play, refill that player's hand toward 3 cards while the Draw Pile has cards.
- Draw only as many cards as needed to reach 3.
- If insufficient cards remain, draw only what is available.
- Once the Draw Pile is empty, no further refill occurs.
- The refill happens after the legal play and before turn transition is completed.

## 9. Voluntary Pickup

- During hand phase, a player may voluntarily pick up the Play Pile even when a legal play exists.
- During face-up setup phase, a player may voluntarily pick up the Play Pile even when a legal play exists.
- Voluntary pickup is not allowed during face-down phase.
- A player cannot pick up an empty Play Pile.

Pickup:

- Moves the entire Play Pile to the player's hand.
- Empties the Play Pile.
- Does not affect the Discard Pile.
- Ends the player's turn.
- Advances according to the current turn direction.
- Returns the player to hand phase.

## 10. Forced Pickup

- If a player has no legal hand play, the player picks up the Play Pile.
- If a player has no legal face-up setup card, the player picks up the Play Pile.
- An illegal face-down reveal follows the special forced-pickup sequence in Section 17.

## 11. Turn Order and Direction

- Turns advance through all actual players.
- Turn order supports any configured player count from 2 to 5.
- Direction can be forward or reversed.
- Joker reverses direction.
- 10 gives the same player another turn.
- Bomb gives the same player another turn.
- Computer turns must continue through the actual turn order.
- The game must not artificially return control to the human player after one computer acts.

## 12. Player Card Phases

Phase priority:

1. Hand.
2. Face-up setup cards.
3. Face-down cards.
4. Win.

The active source is determined from game state:

1. If the player has hand cards, active source is hand.
2. Else if the Draw Pile is not empty, setup cards are not available yet.
3. Else if face-up setup cards remain, active source is face-up setup cards.
4. Else if face-down cards remain, active source is face-down cards.
5. Else the player has won.

## 13. Hand Phase

- If a player has cards in hand, they must play from hand.
- Face-up setup cards are unavailable.
- Face-down cards are unavailable.
- Normal legality rules apply.
- Same-rank multi-card plays are allowed.
- Voluntary pickup is allowed when the Play Pile is not empty.

## 14. Face-Up Setup Phase

Face-up setup cards are available only when:

- The player's hand is empty.
- The Draw Pile is empty.

Rules:

- Normal legality rules apply.
- Only one face-up setup card may be played per play under the current rule.
- Voluntary pickup is allowed when the Play Pile is not empty.
- If no legal face-up setup card exists, pickup is forced.

After pickup:

- Remaining face-up setup cards stay in place.
- Remaining face-down cards stay in place.
- The player returns to hand phase.

## 15. Face-Down Phase

Face-down phase begins only when:

- The player's hand is empty.
- The Draw Pile is empty.
- No face-up setup cards remain.

Rules:

- Face-down cards are chosen blindly.
- Face-down cards are played one at a time.
- There is no fixed order.
- The human player may choose any remaining hidden position.
- A computer player chooses randomly without inspecting hidden card values.
- Voluntary pickup is not allowed.

## 16. Legal Face-Down Reveal

- Reveal the selected face-down card.
- If it is legal, play it normally onto the Play Pile.
- Remove it permanently from the player's face-down cards.
- All special effects still apply:
  - 2 resets the playable-rank restriction.
  - 10 clears the Play Pile and grants an extra turn.
  - Joker reverses direction only.
  - Bomb clears the Play Pile and grants an extra turn.

## 17. Illegal Face-Down Reveal

Exact sequence:

1. Reveal the selected face-down card.
2. Add it to the active Play Pile.
3. The player picks up the entire Play Pile, including that revealed card.
4. Those cards become the player's hand.
5. All other unrevealed face-down cards stay in place.
6. The player returns to hand phase.
7. The player's turn ends.
8. Advance according to the current direction.

## 18. Phase Transitions and Extra Turns

- Final face-up card played normally: the next player acts.
- Final face-up card played as a 10 or Bomb: the same player immediately enters face-down phase.
- Legal face-down 10 or Bomb: the same player chooses another remaining face-down card.
- Pickup always returns the player to hand phase while preserving remaining setup cards.
- Extra turns do not skip phase eligibility rules.

## 19. Winning

- A player wins after legally playing their final face-down card.
- Resolve any resulting special effect first:
  - 2 reset.
  - 10 clear.
  - Joker direction reversal.
  - Bomb clear.
- An illegal face-down reveal cannot produce a win.
- A winning player has:
  - no hand cards.
  - no face-up setup cards.
  - no face-down cards.

## 20. Computer Player Rules

- Computer players use the same legality engine as the human player.
- Computer players follow the same phase rules as the human player.
- In hand phase, computer players use the existing simple deterministic strategy to choose which legal rank to play.
- After a computer chooses a rank in hand phase, it plays all cards of that rank from its hand together as one play.
- The grouped computer play must obey the same multi-card legality rules as a human play: all cards in the group share the same rank and the chosen rank is legal.
- A grouped computer play may complete a Bomb and must resolve through the normal Bomb logic.
- The all-matching-cards rule applies only to hand phase. In face-up setup phase, the current rule remains one face-up setup card per play.
- In face-up setup phase, computer players use the existing simple deterministic play strategy among legal face-up setup cards.
- In face-down phase, computer players choose randomly without inspecting hidden values.
- Do not invent undocumented computer strategy.
- Voluntary pickup strategy for computers remains unspecified unless explicitly defined later.

## 21. Current Open Decisions

- Current rule: only one face-up setup card may be played per play, even when multiple face-up setup cards share a rank.
- Note: this rule may be revisited later.

## 22. Implementation Discrepancies

The rules above are authoritative. The current implementation should be checked against them.

- Rule: Winning is specifically after legally playing the final face-down card.
  - Relevant file: `Bomb/Game.swift`
  - Mismatch: `playerHasWon(_:)` checks only whether all three card collections are empty after any resolved play. This is equivalent during normal phase progression, but it does not explicitly encode "final face-down card" as the winning trigger.

- Rule: If no legal hand play or face-up setup play exists, pickup is forced.
  - Relevant file: `Bomb/Game.swift`
  - Mismatch: forced pickup currently depends on `pickUpPlayPileForCurrentPlayer()`, which refuses empty Play Piles. The rules also state a player cannot pick up an empty Play Pile, so the empty-pile/no-legal-play edge case needs explicit handling if it can occur.

- Rule: In hand phase, after a computer chooses a legal rank, it plays all cards of that rank together as one play.
  - Relevant file: `Bomb/Game.swift`
  - Mismatch: current computer planning and execution select a single `lowestLegalCard(in:)`, so computer players currently play only one card even when they hold additional cards of the same chosen rank.

## 23. Rule Change Log

- 2026-07-06: Initial authoritative gameplay specification created.
- 2026-07-06: Added random dealer selection, left-of-dealer first turn, opening Play Pile seed card, and explicit special opening seed-card behavior.
- 2026-07-06: Added required computer hand behavior to play all cards of the chosen rank together as one play.
