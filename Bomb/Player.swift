//
//  Player.swift
//  Bomb!
//
//  Created by DREW COLLINS on 7/4/26.
//

import Foundation

enum PlayerKind {
    case localHuman
    case computer
    case remoteHuman
}

struct Player: Identifiable {
    let id: UUID
    var name: String
    var kind: PlayerKind

    // Cards held in the player's hand
    var hand: [PlayingCard]

    // Three visible cards on the table
    var faceUpCards: [PlayingCard]

    // Three hidden cards on the table
    var faceDownCards: [PlayingCard]

    init(
        id: UUID = UUID(),
        name: String,
        kind: PlayerKind
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.hand = []
        self.faceUpCards = []
        self.faceDownCards = []
    }
}
