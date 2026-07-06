//
//  Game.swift
//  Bomb!
//
//  Created by DREW COLLINS on 7/4/26.
//

import Foundation

struct Game {
    var players: [Player]
    var drawPile: [PlayingCard]
    var discardPile: [PlayingCard]

    var currentPlayerIndex: Int
    var direction: PlayDirection
    var localPlayerIndex: Int
    var isSetupComplete: Bool

    var localPlayer: Player {
        players[localPlayerIndex]
    }

    var opponents: [Player] {
        players.filter { $0.kind != .localHuman }
    }

    init(
        localPlayerName: String,
        computerPlayerNames: [String]
    ) {
        let playerCount = 1 + computerPlayerNames.count

        precondition(
            (2...5).contains(playerCount),
            "Bomb! requires 2 to 5 players."
        )

        self.players = [
            Player(
                name: localPlayerName,
                kind: .localHuman
            )
        ] + computerPlayerNames.map {
            Player(
                name: $0,
                kind: .computer
            )
        }

        self.drawPile = Deck.makeBombDeck()
        self.discardPile = []

        self.currentPlayerIndex = 0
        self.direction = .clockwise
        self.localPlayerIndex = 0
        self.isSetupComplete = false

        dealInitialCards()
        chooseComputerFaceUpCards()
    }

    private mutating func dealInitialCards() {

        // Deal 3 face-down cards to each player
        for _ in 0..<3 {
            for index in players.indices {
                if let card = drawPile.popLast() {
                    players[index].faceDownCards.append(card)
                }
            }
        }

        // Deal 6 cards into each player's hand. Each player later chooses
        // 3 of these to place face-up on top of their face-down cards.
        for _ in 0..<6 {
            for index in players.indices {
                if let card = drawPile.popLast() {
                    players[index].hand.append(card)
                }
            }
        }
    }

    mutating func chooseLocalFaceUpCards(cardIDs: [PlayingCard.ID]) {
        guard !isSetupComplete, cardIDs.count == 3 else {
            return
        }

        let didChooseCards = moveCardsToFaceUp(
            forPlayerAt: localPlayerIndex,
            cardIDs: Set(cardIDs)
        )

        if didChooseCards {
            isSetupComplete = true
        }
    }

    private mutating func chooseComputerFaceUpCards() {
        for index in players.indices where players[index].kind == .computer {
            let selectedCardIDs = players[index].hand
                .sorted { cardScore($0) > cardScore($1) }
                .prefix(3)
                .map(\.id)

            _ = moveCardsToFaceUp(
                forPlayerAt: index,
                cardIDs: Set(selectedCardIDs)
            )
        }
    }

    private mutating func moveCardsToFaceUp(
        forPlayerAt playerIndex: Int,
        cardIDs: Set<PlayingCard.ID>
    ) -> Bool {
        let selectedCards = players[playerIndex].hand.filter { cardIDs.contains($0.id) }

        guard selectedCards.count == 3 else {
            return false
        }

        players[playerIndex].hand.removeAll { cardIDs.contains($0.id) }
        players[playerIndex].faceUpCards.append(contentsOf: selectedCards)
        return true
    }

    private func cardScore(_ card: PlayingCard) -> Int {
        switch card.kind {
        case .joker:
            return 15
        case .standard(_, let rank):
            return rank.rawValue
        }
    }
}
