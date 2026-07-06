//
//  CardView.swift
//  Bomb
//
//  Created by DREW COLLINS on 7/4/26.
//

import SwiftUI

enum PlayingCardLayout {
    static let aspectRatio: CGFloat = 5.0 / 7.0
    static let stackOffsetFraction: CGFloat = 0.11

    static func height(forWidth width: CGFloat) -> CGFloat {
        width / aspectRatio
    }

    static func stackedHeight(forWidth width: CGFloat) -> CGFloat {
        height(forWidth: width) + width * stackOffsetFraction * 2
    }
}

struct CardView: View {
    let card: PlayingCard
    var width: CGFloat = 70

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.white)
                .stroke(.gray, lineWidth: 1)
                .shadow(radius: 2)

            VStack(spacing: 4) {
                Text(rankText)
                    .font(.system(size: width * 0.24, weight: .bold))
                    .bold()

                Text(suitText)
                    .font(.system(size: width * 0.34))
            }
            .foregroundStyle(cardColor)
        }
        .frame(
            width: width,
            height: PlayingCardLayout.height(forWidth: width)
        )
    }

    private var rankText: String {
        switch card.kind {
        case .joker:
            return "JOKER"

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

    private var suitText: String {
        switch card.kind {
        case .joker:
            return "🃏"

        case .standard(let suit, _):
            switch suit {
            case .hearts: return "♥"
            case .diamonds: return "♦"
            case .clubs: return "♣"
            case .spades: return "♠"
            }
        }
    }

    private var cardColor: Color {
        switch card.kind {
        case .joker:
            return .purple

        case .standard(let suit, _):
            switch suit {
            case .hearts, .diamonds:
                return .red
            case .clubs, .spades:
                return .black
            }
        }
    }
}
