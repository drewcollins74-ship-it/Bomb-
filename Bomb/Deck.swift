//
//  Deck.swift
//  Bomb!
//
//  Created by DREW COLLINS on 7/4/26.
//

import Foundation

struct Deck {

    static func makeBombDeck() -> [PlayingCard] {
        var cards: [PlayingCard] = []

        // Bomb! always uses two complete decks.
        for _ in 0..<2 {

            // Standard 52 cards
            for suit in Suit.allCases {
                for rank in Rank.allCases {
                    cards.append(
                        PlayingCard(
                            kind: .standard(
                                suit: suit,
                                rank: rank
                            )
                        )
                    )
                }
            }

            // Two Jokers per deck
            cards.append(
                PlayingCard(kind: .joker)
            )

            cards.append(
                PlayingCard(kind: .joker)
            )
        }

        return cards.shuffled()
    }
}
