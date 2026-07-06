//
//  PlayingCard.swift
//  Bomb!
//
//  Created by DREW COLLINS on 7/4/26.
//

import Foundation

enum Suit: String, CaseIterable, Codable {
    case hearts
    case diamonds
    case clubs
    case spades
}

enum Rank: Int, CaseIterable, Comparable, Codable {
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
    case ten = 10
    case jack = 11
    case queen = 12
    case king = 13
    case ace = 14

    static func < (lhs: Rank, rhs: Rank) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

enum CardKind: Equatable, Codable {
    case standard(suit: Suit, rank: Rank)
    case joker
}

struct PlayingCard: Identifiable, Equatable, Codable {
    let id: UUID
    let kind: CardKind

    init(
        id: UUID = UUID(),
        kind: CardKind
    ) {
        self.id = id
        self.kind = kind
    }
}
