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
    var playPile: [PlayingCard]
    var discardPile: [PlayingCard]

    var currentPlayerIndex: Int
    var direction: PlayDirection
    var localPlayerIndex: Int
    var isSetupComplete: Bool
    var lastActionMessage: String?

    var localPlayer: Player {
        players[localPlayerIndex]
    }

    var opponents: [Player] {
        players.filter { $0.kind != .localHuman }
    }

    var localPlayerHasLegalHandPlay: Bool {
        players[localPlayerIndex].hand.contains { card in
            isLegalPlay(cards: [card])
        }
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
        self.playPile = []
        self.discardPile = []

        self.currentPlayerIndex = 0
        self.direction = .clockwise
        self.localPlayerIndex = 0
        self.isSetupComplete = false
        self.lastActionMessage = nil

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

    mutating func playLocalCards(cardIDs: Set<PlayingCard.ID>) -> Bool {
        guard isSetupComplete,
              currentPlayerIndex == localPlayerIndex,
              applyPlay(
                cardIDs: cardIDs,
                forPlayerAt: localPlayerIndex
              ) else {
            return false
        }

        return true
    }

    mutating func pickUpPlayPileForLocalPlayer() -> Bool {
        guard isSetupComplete,
              currentPlayerIndex == localPlayerIndex,
              playPile.isEmpty == false else {
            return false
        }

        return pickUpPlayPileForCurrentPlayer()
    }

    mutating func playCurrentComputerTurn() -> Bool {
        guard isSetupComplete,
              players[currentPlayerIndex].kind == .computer else {
            return false
        }

        let playerIndex = currentPlayerIndex

        if let card = lowestLegalCard(in: players[playerIndex].hand) {
            _ = applyPlay(
                cardIDs: [card.id],
                forPlayerAt: playerIndex
            )
        } else {
            _ = pickUpPlayPileForCurrentPlayer()
        }

        return true
    }

    private mutating func pickUpPlayPileForCurrentPlayer() -> Bool {
        guard playPile.isEmpty == false else {
            return false
        }

        let playerIndex = currentPlayerIndex
        pickUpPlayPile(forPlayerAt: playerIndex)
        lastActionMessage = "\(players[playerIndex].name) picked up the Play Pile"
        advanceTurn()
        return true
    }

    private func lowestLegalCard(in hand: [PlayingCard]) -> PlayingCard? {
        hand
            .filter { isLegalPlay(cards: [$0]) }
            .sorted { cardSortScore($0) < cardSortScore($1) }
            .first
    }

    private mutating func applyPlay(
        cardIDs: Set<PlayingCard.ID>,
        forPlayerAt playerIndex: Int
    ) -> Bool {
        let selectedCards = players[playerIndex].hand.filter { cardIDs.contains($0.id) }

        guard selectedCards.count == cardIDs.count,
              isLegalPlay(cards: selectedCards) else {
            return false
        }

        players[playerIndex].hand.removeAll { cardIDs.contains($0.id) }
        playPile.append(contentsOf: selectedCards)

        if jokerCount(in: selectedCards).isMultiple(of: 2) == false {
            reverseDirection()
        }

        let clearsPile = containsTen(selectedCards) || hasTrailingBomb()
        let completedBomb = hasTrailingBomb()

        if clearsPile {
            clearPlayPile()
        }

        lastActionMessage = actionMessage(
            playerName: players[playerIndex].name,
            playedCards: selectedCards,
            clearedWithTen: containsTen(selectedCards),
            completedBomb: completedBomb
        )

        refillHand(forPlayerAt: playerIndex)

        if clearsPile {
            currentPlayerIndex = playerIndex
        } else {
            advanceTurn()
        }

        return true
    }

    private func isLegalPlay(cards: [PlayingCard]) -> Bool {
        guard let proposedValue = playValue(for: cards),
              cards.allSatisfy({ playValue(for: $0) == proposedValue }) else {
            return false
        }

        switch proposedValue {
        case .two, .ten, .joker:
            return true
        case .normal(let rank):
            guard let currentRankRestriction else {
                return true
            }

            return rank >= currentRankRestriction
        }
    }

    private var currentRankRestriction: Rank? {
        guard let topCard = playPile.last else {
            return nil
        }

        switch playValue(for: topCard) {
        case .two, .joker:
            return nil
        case .ten:
            return nil
        case .normal(let rank):
            return rank
        }
    }

    private func playValue(for cards: [PlayingCard]) -> PlayValue? {
        guard let firstCard = cards.first else {
            return nil
        }

        return playValue(for: firstCard)
    }

    private func playValue(for card: PlayingCard) -> PlayValue {
        switch card.kind {
        case .joker:
            return .joker
        case .standard(_, let rank):
            switch rank {
            case .two:
                return .two
            case .ten:
                return .ten
            default:
                return .normal(rank)
            }
        }
    }

    private func hasTrailingBomb() -> Bool {
        guard playPile.count >= 4,
              let trailingValue = playPile.last.map(playValue(for:)) else {
            return false
        }

        let trailingMatchCount = playPile.reversed().prefix { card in
            playValue(for: card) == trailingValue
        }.count

        return trailingMatchCount >= 4
    }

    private mutating func clearPlayPile() {
        discardPile.append(contentsOf: playPile)
        playPile.removeAll()
    }

    private mutating func pickUpPlayPile(forPlayerAt playerIndex: Int) {
        players[playerIndex].hand.append(contentsOf: playPile)
        playPile.removeAll()
    }

    private mutating func refillHand(forPlayerAt playerIndex: Int) {
        while players[playerIndex].hand.count < 3,
              let card = drawPile.popLast() {
            players[playerIndex].hand.append(card)
        }
    }

    private mutating func advanceTurn() {
        switch direction {
        case .clockwise:
            currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        case .counterclockwise:
            currentPlayerIndex = (currentPlayerIndex - 1 + players.count) % players.count
        }
    }

    private mutating func reverseDirection() {
        switch direction {
        case .clockwise:
            direction = .counterclockwise
        case .counterclockwise:
            direction = .clockwise
        }
    }

    private func containsTen(_ cards: [PlayingCard]) -> Bool {
        cards.contains { playValue(for: $0) == .ten }
    }

    private func jokerCount(in cards: [PlayingCard]) -> Int {
        cards.filter { playValue(for: $0) == .joker }.count
    }

    private func actionMessage(
        playerName: String,
        playedCards: [PlayingCard],
        clearedWithTen: Bool,
        completedBomb: Bool
    ) -> String {
        let message = "\(playerName) played \(playDescription(for: playedCards))"

        if completedBomb {
            return "\(message) and made a Bomb"
        }

        if clearedWithTen {
            return "\(message) and cleared the Play Pile"
        }

        return message
    }

    private func playDescription(for cards: [PlayingCard]) -> String {
        guard let firstCard = cards.first else {
            return ""
        }

        let rankText = rankDescription(for: firstCard)

        if cards.count == 1 {
            return rankText
        }

        return "\(cards.count) x \(rankText)"
    }

    private func rankDescription(for card: PlayingCard) -> String {
        switch card.kind {
        case .joker:
            return "Joker"
        case .standard(_, let rank):
            switch rank {
            case .two: return "2"
            case .three: return "3"
            case .four: return "4"
            case .five: return "5"
            case .six: return "6"
            case .seven: return "7"
            case .eight: return "8"
            case .nine: return "9"
            case .ten: return "10"
            case .jack: return "J"
            case .queen: return "Q"
            case .king: return "K"
            case .ace: return "A"
            }
        }
    }

    private func cardSortScore(_ card: PlayingCard) -> Int {
        switch playValue(for: card) {
        case .two:
            return 2
        case .normal(let rank):
            return rank.rawValue
        case .ten:
            return 10
        case .joker:
            return 15
        }
    }
}

private enum PlayValue: Equatable {
    case normal(Rank)
    case two
    case ten
    case joker
}
