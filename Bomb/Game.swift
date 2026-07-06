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
    var dealerIndex: Int
    var isSetupComplete: Bool
    var lastActionMessage: String?
    var currentRankRestriction: Rank?
    var winnerIndex: Int?

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

    var localPlayerActiveSource: ActiveCardSource {
        activeSource(forPlayerAt: localPlayerIndex)
    }

    var localPlayerRequiresForcedPickup: Bool {
        guard isSetupComplete,
              winnerIndex == nil,
              currentPlayerIndex == localPlayerIndex,
              playPile.isEmpty == false else {
            return false
        }

        switch activeSource(forPlayerAt: localPlayerIndex) {
        case .hand:
            return players[localPlayerIndex].hand.contains { card in
                isLegalPlay(cards: [card])
            } == false

        case .faceUpSetup:
            return players[localPlayerIndex].faceUpCards.contains { card in
                isLegalPlay(cards: [card])
            } == false

        case .waitingForDrawPileToEmpty, .faceDown, .won:
            return false
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
        self.dealerIndex = Int.random(in: 0..<playerCount)
        self.isSetupComplete = false
        self.lastActionMessage = nil
        self.currentRankRestriction = nil
        self.winnerIndex = nil

        dealInitialCards()
        sortAllHands()
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
            startGameplayAfterSetup()
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
        sortHand(forPlayerAt: playerIndex)
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

    private mutating func startGameplayAfterSetup() {
        direction = .clockwise
        currentPlayerIndex = playerIndexToLeftOfDealer()
        revealOpeningSeedCard()
        refillCurrentPlayerIfWaitingForDrawPile()
    }

    private func playerIndexToLeftOfDealer() -> Int {
        (dealerIndex + 1) % players.count
    }

    private mutating func revealOpeningSeedCard() {
        guard playPile.isEmpty,
              let openingCard = drawPile.popLast() else {
            return
        }

        playPile.append(openingCard)
        currentRankRestriction = openingRankRestriction(for: openingCard)
        lastActionMessage = "Opening card: \(rankDescription(for: openingCard))"
    }

    private func openingRankRestriction(for card: PlayingCard) -> Rank? {
        switch card.kind {
        case .joker:
            return nil
        case .standard(_, let rank):
            switch rank {
            case .two, .ten:
                return nil
            default:
                return rank
            }
        }
    }

    mutating func playLocalCards(cardIDs: Set<PlayingCard.ID>) -> Bool {
        guard isSetupComplete,
              winnerIndex == nil,
              currentPlayerIndex == localPlayerIndex,
              activeSource(forPlayerAt: localPlayerIndex) == .hand,
              applyHandPlay(
                cardIDs: cardIDs,
                forPlayerAt: localPlayerIndex
              ) else {
            return false
        }

        return true
    }

    mutating func playLocalFaceUpCard(cardID: PlayingCard.ID) -> Bool {
        guard isSetupComplete,
              winnerIndex == nil,
              currentPlayerIndex == localPlayerIndex,
              activeSource(forPlayerAt: localPlayerIndex) == .faceUpSetup,
              applyFaceUpPlay(
                cardID: cardID,
                forPlayerAt: localPlayerIndex
              ) else {
            return false
        }

        return true
    }

    mutating func playLocalFaceDownCard(at index: Int) -> Bool {
        guard isSetupComplete,
              winnerIndex == nil,
              currentPlayerIndex == localPlayerIndex,
              activeSource(forPlayerAt: localPlayerIndex) == .faceDown else {
            return false
        }

        return applyFaceDownPlay(
            cardIndex: index,
            forPlayerAt: localPlayerIndex
        )
    }

    mutating func pickUpPlayPileForLocalPlayer() -> Bool {
        guard isSetupComplete,
              winnerIndex == nil,
              currentPlayerIndex == localPlayerIndex,
              activeSource(forPlayerAt: localPlayerIndex).allowsVoluntaryPickup,
              playPile.isEmpty == false else {
            return false
        }

        return pickUpPlayPileForCurrentPlayer()
    }

    mutating func playCurrentComputerTurn() -> Bool {
        playCurrentComputerTurn(faceDownIndex: nil)
    }

    mutating func playCurrentComputerTurn(faceDownIndex: Int?) -> Bool {
        guard isSetupComplete,
              winnerIndex == nil,
              players[currentPlayerIndex].kind == .computer else {
            return false
        }

        let playerIndex = currentPlayerIndex
        let source = activeSource(forPlayerAt: playerIndex)

        switch source {
        case .hand:
            if let cards = bestComputerHandPlay(in: players[playerIndex].hand) {
                _ = applyHandPlay(
                    cardIDs: Set(cards.map(\.id)),
                    forPlayerAt: playerIndex
                )
            } else {
                _ = pickUpPlayPileForCurrentPlayer()
            }

        case .faceUpSetup:
            if let card = lowestLegalCard(in: players[playerIndex].faceUpCards) {
                _ = applyFaceUpPlay(
                    cardID: card.id,
                    forPlayerAt: playerIndex
                )
            } else {
                _ = pickUpPlayPileForCurrentPlayer()
            }

        case .faceDown:
            guard players[playerIndex].faceDownCards.isEmpty == false else {
                winnerIndex = playerIndex
                return true
            }

            let randomIndex: Int
            if let faceDownIndex,
               players[playerIndex].faceDownCards.indices.contains(faceDownIndex) {
                randomIndex = faceDownIndex
            } else {
                randomIndex = Int.random(in: players[playerIndex].faceDownCards.indices)
            }

            _ = applyFaceDownPlay(
                cardIndex: randomIndex,
                forPlayerAt: playerIndex
            )

        case .waitingForDrawPileToEmpty:
            refillHand(forPlayerAt: playerIndex)
            if players[playerIndex].hand.isEmpty {
                advanceTurn()
            }

        case .won:
            winnerIndex = playerIndex
            advanceTurn()
        }

        return true
    }

    func legalLocalHandCards(cardIDs: Set<PlayingCard.ID>) -> [PlayingCard]? {
        guard isSetupComplete,
              winnerIndex == nil,
              currentPlayerIndex == localPlayerIndex,
              activeSource(forPlayerAt: localPlayerIndex) == .hand else {
            return nil
        }

        let selectedCards = players[localPlayerIndex].hand.filter { cardIDs.contains($0.id) }

        guard selectedCards.count == cardIDs.count,
              isLegalPlay(cards: selectedCards) else {
            return nil
        }

        return selectedCards
    }

    func legalLocalFaceUpCard(cardID: PlayingCard.ID) -> PlayingCard? {
        guard isSetupComplete,
              winnerIndex == nil,
              currentPlayerIndex == localPlayerIndex,
              activeSource(forPlayerAt: localPlayerIndex) == .faceUpSetup,
              let card = players[localPlayerIndex].faceUpCards.first(where: { $0.id == cardID }),
              isLegalPlay(cards: [card]) else {
            return nil
        }

        return card
    }

    func localFaceDownCard(at index: Int) -> PlayingCard? {
        guard isSetupComplete,
              winnerIndex == nil,
              currentPlayerIndex == localPlayerIndex,
              activeSource(forPlayerAt: localPlayerIndex) == .faceDown,
              players[localPlayerIndex].faceDownCards.indices.contains(index) else {
            return nil
        }

        return players[localPlayerIndex].faceDownCards[index]
    }

    func plannedCurrentComputerPlay() -> PlannedComputerPlay? {
        guard isSetupComplete,
              winnerIndex == nil,
              players[currentPlayerIndex].kind == .computer else {
            return nil
        }

        let playerIndex = currentPlayerIndex

        switch activeSource(forPlayerAt: playerIndex) {
        case .hand:
            guard let cards = bestComputerHandPlay(in: players[playerIndex].hand) else {
                return nil
            }

            return PlannedComputerPlay(cards: cards, faceDownIndex: nil)

        case .faceUpSetup:
            guard let card = lowestLegalCard(in: players[playerIndex].faceUpCards) else {
                return nil
            }

            return PlannedComputerPlay(cards: [card], faceDownIndex: nil)

        case .faceDown:
            guard players[playerIndex].faceDownCards.isEmpty == false else {
                return nil
            }

            let randomIndex = Int.random(in: players[playerIndex].faceDownCards.indices)
            return PlannedComputerPlay(
                cards: [players[playerIndex].faceDownCards[randomIndex]],
                faceDownIndex: randomIndex
            )

        case .waitingForDrawPileToEmpty, .won:
            return nil
        }
    }

    private func activeSource(forPlayerAt playerIndex: Int) -> ActiveCardSource {
        if players[playerIndex].hand.isEmpty == false {
            return .hand
        }

        if drawPile.isEmpty == false {
            return .waitingForDrawPileToEmpty
        }

        if players[playerIndex].faceUpCards.isEmpty == false {
            return .faceUpSetup
        }

        if players[playerIndex].faceDownCards.isEmpty == false {
            return .faceDown
        }

        return .won
    }

    private mutating func pickUpPlayPileForCurrentPlayer() -> Bool {
        guard playPile.isEmpty == false,
              activeSource(forPlayerAt: currentPlayerIndex).allowsVoluntaryPickup else {
            return false
        }

        let playerIndex = currentPlayerIndex
        pickUpPlayPile(forPlayerAt: playerIndex)
        lastActionMessage = "\(players[playerIndex].name) picked up the Play Pile"
        advanceTurn()
        refillCurrentPlayerIfWaitingForDrawPile()
        return true
    }

    private mutating func applyHandPlay(
        cardIDs: Set<PlayingCard.ID>,
        forPlayerAt playerIndex: Int
    ) -> Bool {
        let selectedCards = players[playerIndex].hand.filter { cardIDs.contains($0.id) }

        guard selectedCards.count == cardIDs.count,
              isLegalPlay(cards: selectedCards) else {
            return false
        }

        players[playerIndex].hand.removeAll { cardIDs.contains($0.id) }
        sortHand(forPlayerAt: playerIndex)

        return resolvePlayedCards(
            selectedCards,
            forPlayerAt: playerIndex,
            refillsHand: true
        )
    }

    private mutating func applyFaceUpPlay(
        cardID: PlayingCard.ID,
        forPlayerAt playerIndex: Int
    ) -> Bool {
        guard let cardIndex = players[playerIndex].faceUpCards.firstIndex(where: { $0.id == cardID }) else {
            return false
        }

        let card = players[playerIndex].faceUpCards[cardIndex]

        guard isLegalPlay(cards: [card]) else {
            return false
        }

        players[playerIndex].faceUpCards.remove(at: cardIndex)

        return resolvePlayedCards(
            [card],
            forPlayerAt: playerIndex,
            refillsHand: false
        )
    }

    private mutating func applyFaceDownPlay(
        cardIndex: Int,
        forPlayerAt playerIndex: Int
    ) -> Bool {
        guard players[playerIndex].faceDownCards.indices.contains(cardIndex) else {
            return false
        }

        let card = players[playerIndex].faceDownCards.remove(at: cardIndex)

        if isLegalPlay(cards: [card]) {
            return resolvePlayedCards(
                [card],
                forPlayerAt: playerIndex,
                refillsHand: false
            )
        } else {
            playPile.append(card)
            pickUpPlayPile(forPlayerAt: playerIndex)
            lastActionMessage = "\(players[playerIndex].name) revealed \(rankDescription(for: card)) and picked up the Play Pile"
            advanceTurn()
            refillCurrentPlayerIfWaitingForDrawPile()
            return true
        }
    }

    private mutating func resolvePlayedCards(
        _ selectedCards: [PlayingCard],
        forPlayerAt playerIndex: Int,
        refillsHand: Bool
    ) -> Bool {
        playPile.append(contentsOf: selectedCards)
        updateRankRestriction(afterPlaying: selectedCards)

        if jokerCount(in: selectedCards).isMultiple(of: 2) == false {
            reverseDirection()
        }

        let completedBomb = hasTrailingBomb()
        let clearedWithTen = containsTen(selectedCards)
        let clearsPile = clearedWithTen || completedBomb

        if clearsPile {
            clearPlayPile()
        }

        lastActionMessage = actionMessage(
            playerName: players[playerIndex].name,
            playedCards: selectedCards,
            clearedWithTen: clearedWithTen,
            completedBomb: completedBomb
        )

        if refillsHand {
            refillHand(forPlayerAt: playerIndex)
        }

        if playerHasWon(playerIndex) {
            winnerIndex = playerIndex
            lastActionMessage = "\(players[playerIndex].name) won"
            return true
        }

        if clearsPile {
            currentPlayerIndex = playerIndex
        } else {
            advanceTurn()
        }

        refillCurrentPlayerIfWaitingForDrawPile()
        return true
    }

    private func playerHasWon(_ playerIndex: Int) -> Bool {
        players[playerIndex].hand.isEmpty &&
        players[playerIndex].faceUpCards.isEmpty &&
        players[playerIndex].faceDownCards.isEmpty
    }

    private func lowestLegalCard(in cards: [PlayingCard]) -> PlayingCard? {
        cards
            .filter { isLegalPlay(cards: [$0]) }
            .sorted { computerCardStrategyScore($0) < computerCardStrategyScore($1) }
            .first
    }

    private func bestComputerHandPlay(in hand: [PlayingCard]) -> [PlayingCard]? {
        guard let chosenCard = lowestLegalCard(in: hand) else {
            return nil
        }

        let chosenValue = playValue(for: chosenCard)
        let matchingCards = hand.filter { playValue(for: $0) == chosenValue }
        let selectedCards: [PlayingCard]

        switch chosenValue {
        case .normal:
            selectedCards = matchingCards
        case .two, .ten, .joker:
            let neededForBomb = 4 - trailingMatchCount(for: chosenValue)
            if (1...matchingCards.count).contains(neededForBomb) {
                selectedCards = Array(matchingCards.prefix(neededForBomb))
            } else {
                selectedCards = [chosenCard]
            }
        }

        guard isLegalPlay(cards: selectedCards) else {
            return nil
        }

        return selectedCards
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

        return trailingMatchCount(for: trailingValue) >= 4
    }

    private func trailingMatchCount(for value: PlayValue) -> Int {
        playPile.reversed().prefix { card in
            playValue(for: card) == value
        }.count
    }

    private mutating func clearPlayPile() {
        discardPile.append(contentsOf: playPile)
        playPile.removeAll()
        currentRankRestriction = nil
    }

    private mutating func pickUpPlayPile(forPlayerAt playerIndex: Int) {
        players[playerIndex].hand.append(contentsOf: playPile)
        sortHand(forPlayerAt: playerIndex)
        playPile.removeAll()
        currentRankRestriction = nil
    }

    private mutating func updateRankRestriction(afterPlaying cards: [PlayingCard]) {
        guard let playValue = playValue(for: cards) else {
            return
        }

        switch playValue {
        case .two, .ten:
            currentRankRestriction = nil
        case .joker:
            break
        case .normal(let rank):
            currentRankRestriction = rank
        }
    }

    private mutating func refillHand(forPlayerAt playerIndex: Int) {
        while players[playerIndex].hand.count < 3,
              let card = drawPile.popLast() {
            players[playerIndex].hand.append(card)
        }

        sortHand(forPlayerAt: playerIndex)
    }

    private mutating func refillCurrentPlayerIfWaitingForDrawPile() {
        if activeSource(forPlayerAt: currentPlayerIndex) == .waitingForDrawPileToEmpty {
            refillHand(forPlayerAt: currentPlayerIndex)
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

    private func computerCardStrategyScore(_ card: PlayingCard) -> Int {
        switch playValue(for: card) {
        case .normal(let rank):
            return rank.rawValue
        case .two:
            return 100
        case .joker:
            return 101
        case .ten:
            return 102
        }
    }

    private mutating func sortAllHands() {
        for index in players.indices {
            sortHand(forPlayerAt: index)
        }
    }

    private mutating func sortHand(forPlayerAt playerIndex: Int) {
        players[playerIndex].hand.sort {
            Game.handSortPriority(for: $0) < Game.handSortPriority(for: $1)
        }
    }

    private static func handSortPriority(for card: PlayingCard) -> Int {
        switch card.kind {
        case .joker:
            return 0
        case .standard(_, let rank):
            switch rank {
            case .ten: return 1
            case .two: return 2
            case .ace: return 3
            case .king: return 4
            case .queen: return 5
            case .jack: return 6
            case .nine: return 7
            case .eight: return 8
            case .seven: return 9
            case .six: return 10
            case .five: return 11
            case .four: return 12
            case .three: return 13
            }
        }
    }
}

private enum PlayValue: Equatable {
    case normal(Rank)
    case two
    case ten
    case joker
}

enum ActiveCardSource: Equatable {
    case hand
    case waitingForDrawPileToEmpty
    case faceUpSetup
    case faceDown
    case won

    var allowsVoluntaryPickup: Bool {
        self == .hand || self == .faceUpSetup
    }
}

struct PlannedComputerPlay {
    let cards: [PlayingCard]
    let faceDownIndex: Int?
}
