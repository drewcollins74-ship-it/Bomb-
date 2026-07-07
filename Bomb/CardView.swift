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

    private var height: CGFloat {
        PlayingCardLayout.height(forWidth: width)
    }

    private var cornerRadius: CGFloat {
        max(5, width * 0.12)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color(red: 1.0, green: 0.985, blue: 0.94))

            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.black.opacity(0.42), lineWidth: max(0.75, width * 0.014))

            cardContent
                .padding(width * 0.075)
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .shadow(color: .black.opacity(0.26), radius: max(1.5, width * 0.032), y: max(1, width * 0.02))
    }

    @ViewBuilder
    private var cardContent: some View {
        ZStack {
            switch card.kind {
            case .joker:
                JokerCenterView(width: width)

            case .standard(let suit, let rank):
                switch rank {
                case .ace:
                    AceCenterView(suitText: suit.symbol, color: suit.displayColor, width: width)
                case .jack, .queen, .king:
                    FaceCardCenterView(rankText: rank.shortText, suitText: suit.symbol, color: suit.displayColor, width: width)
                case .two, .three, .four, .five, .six, .seven, .eight, .nine, .ten:
                    NumberCardPipsView(suitText: suit.symbol, rank: rank, color: suit.displayColor, width: width)
                }
            }

            VStack {
                HStack {
                    CornerIndexView(rankText: rankText, suitText: suitText, color: cardColor, width: width)

                    Spacer()
                }

                Spacer()

                HStack {
                    Spacer()

                    CornerIndexView(rankText: rankText, suitText: suitText, color: cardColor, width: width)
                        .rotationEffect(.degrees(180))
                }
            }
        }
    }

    private var rankText: String {
        switch card.kind {
        case .joker:
            return "Jkr"
        case .standard(_, let rank):
            return rank.shortText
        }
    }

    private var suitText: String {
        switch card.kind {
        case .joker:
            return "★"
        case .standard(let suit, _):
            return suit.symbol
        }
    }

    private var cardColor: Color {
        switch card.kind {
        case .joker:
            return Color(red: 0.38, green: 0.13, blue: 0.62)
        case .standard(let suit, _):
            return suit.displayColor
        }
    }
}

private struct CornerIndexView: View {
    let rankText: String
    let suitText: String
    let color: Color
    let width: CGFloat

    var body: some View {
        VStack(spacing: -width * 0.006) {
            Text(rankText)
                .font(.system(size: rankText.count > 1 ? width * 0.145 : width * 0.18, weight: .heavy, design: .rounded))

            Text(suitText)
                .font(.system(size: width * 0.16, weight: .bold))
        }
        .foregroundStyle(color)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
}

private struct NumberCardPipsView: View {
    let suitText: String
    let rank: Rank
    let color: Color
    let width: CGFloat

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let pipSize = width * pipScale

            ZStack {
                ForEach(Array(pipPositions.enumerated()), id: \.offset) { _, point in
                    Text(suitText)
                        .font(.system(size: pipSize, weight: .semibold))
                        .foregroundStyle(color)
                        .position(
                            x: size.width * point.x,
                            y: size.height * point.y
                        )
                }
            }
        }
    }

    private var pipScale: CGFloat {
        rank == .ten ? 0.205 : 0.24
    }

    private var pipPositions: [CGPoint] {
        switch rank {
        case .two:
            return [
                CGPoint(x: 0.50, y: 0.29),
                CGPoint(x: 0.50, y: 0.71)
            ]
        case .three:
            return [
                CGPoint(x: 0.50, y: 0.27),
                CGPoint(x: 0.50, y: 0.50),
                CGPoint(x: 0.50, y: 0.73)
            ]
        case .four:
            return [
                CGPoint(x: 0.34, y: 0.29),
                CGPoint(x: 0.66, y: 0.29),
                CGPoint(x: 0.34, y: 0.71),
                CGPoint(x: 0.66, y: 0.71)
            ]
        case .five:
            return [
                CGPoint(x: 0.34, y: 0.28),
                CGPoint(x: 0.66, y: 0.28),
                CGPoint(x: 0.50, y: 0.50),
                CGPoint(x: 0.34, y: 0.72),
                CGPoint(x: 0.66, y: 0.72)
            ]
        case .six:
            return [
                CGPoint(x: 0.34, y: 0.25),
                CGPoint(x: 0.66, y: 0.25),
                CGPoint(x: 0.34, y: 0.50),
                CGPoint(x: 0.66, y: 0.50),
                CGPoint(x: 0.34, y: 0.75),
                CGPoint(x: 0.66, y: 0.75)
            ]
        case .seven:
            return [
                CGPoint(x: 0.34, y: 0.24),
                CGPoint(x: 0.66, y: 0.24),
                CGPoint(x: 0.50, y: 0.36),
                CGPoint(x: 0.34, y: 0.50),
                CGPoint(x: 0.66, y: 0.50),
                CGPoint(x: 0.34, y: 0.76),
                CGPoint(x: 0.66, y: 0.76)
            ]
        case .eight:
            return [
                CGPoint(x: 0.34, y: 0.23),
                CGPoint(x: 0.66, y: 0.23),
                CGPoint(x: 0.50, y: 0.35),
                CGPoint(x: 0.34, y: 0.47),
                CGPoint(x: 0.66, y: 0.47),
                CGPoint(x: 0.50, y: 0.65),
                CGPoint(x: 0.34, y: 0.77),
                CGPoint(x: 0.66, y: 0.77)
            ]
        case .nine:
            return [
                CGPoint(x: 0.34, y: 0.22),
                CGPoint(x: 0.66, y: 0.22),
                CGPoint(x: 0.34, y: 0.37),
                CGPoint(x: 0.66, y: 0.37),
                CGPoint(x: 0.50, y: 0.50),
                CGPoint(x: 0.34, y: 0.63),
                CGPoint(x: 0.66, y: 0.63),
                CGPoint(x: 0.34, y: 0.78),
                CGPoint(x: 0.66, y: 0.78)
            ]
        case .ten:
            return [
                CGPoint(x: 0.34, y: 0.20),
                CGPoint(x: 0.66, y: 0.20),
                CGPoint(x: 0.50, y: 0.31),
                CGPoint(x: 0.34, y: 0.38),
                CGPoint(x: 0.66, y: 0.38),
                CGPoint(x: 0.34, y: 0.62),
                CGPoint(x: 0.66, y: 0.62),
                CGPoint(x: 0.50, y: 0.69),
                CGPoint(x: 0.34, y: 0.80),
                CGPoint(x: 0.66, y: 0.80)
            ]
        case .jack, .queen, .king, .ace:
            return []
        }
    }
}

private struct AceCenterView: View {
    let suitText: String
    let color: Color
    let width: CGFloat

    var body: some View {
        Text(suitText)
            .font(.system(size: width * 0.48, weight: .semibold))
            .foregroundStyle(color)
            .shadow(color: color.opacity(0.18), radius: width * 0.035, y: width * 0.015)
    }
}

private struct FaceCardCenterView: View {
    let rankText: String
    let suitText: String
    let color: Color
    let width: CGFloat

    var body: some View {
        VStack(spacing: width * 0.025) {
            Image(systemName: crownSymbol)
                .font(.system(size: width * 0.16, weight: .bold))

            Text(rankText)
                .font(.system(size: width * 0.32, weight: .heavy, design: .serif))

            Text(suitText)
                .font(.system(size: width * 0.19, weight: .semibold))
        }
        .foregroundStyle(color)
        .frame(width: width * 0.52, height: width * 0.74)
        .background {
            RoundedRectangle(cornerRadius: width * 0.08)
                .fill(color.opacity(0.08))
        }
        .overlay {
            RoundedRectangle(cornerRadius: width * 0.08)
                .stroke(color.opacity(0.38), lineWidth: max(0.8, width * 0.012))
        }
        .overlay(alignment: .topLeading) {
            DiamondOrnament(color: color)
                .frame(width: width * 0.12, height: width * 0.12)
                .padding(width * 0.045)
        }
        .overlay(alignment: .bottomTrailing) {
            DiamondOrnament(color: color)
                .frame(width: width * 0.12, height: width * 0.12)
                .padding(width * 0.045)
        }
    }

    private var crownSymbol: String {
        switch rankText {
        case "K":
            return "crown.fill"
        case "Q":
            return "sparkles"
        default:
            return "shield.lefthalf.filled"
        }
    }
}

private struct JokerCenterView: View {
    let width: CGFloat

    var body: some View {
        VStack(spacing: width * 0.035) {
            Image(systemName: "sparkles")
                .font(.system(size: width * 0.18, weight: .heavy))

            Text("JOKER")
                .font(.system(size: width * 0.17, weight: .heavy, design: .rounded))
                .tracking(width * 0.012)

            Text("★")
                .font(.system(size: width * 0.25, weight: .bold))
        }
        .foregroundStyle(
            LinearGradient(
                colors: [
                    Color(red: 0.58, green: 0.12, blue: 0.78),
                    Color(red: 0.82, green: 0.14, blue: 0.24)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .frame(width: width * 0.62, height: width * 0.82)
        .background {
            RoundedRectangle(cornerRadius: width * 0.1)
                .fill(Color(red: 0.58, green: 0.12, blue: 0.78).opacity(0.08))
        }
        .overlay {
            RoundedRectangle(cornerRadius: width * 0.1)
                .stroke(Color(red: 0.58, green: 0.12, blue: 0.78).opacity(0.34), lineWidth: max(0.8, width * 0.012))
        }
    }
}

private struct DiamondOrnament: View {
    let color: Color

    var body: some View {
        Rectangle()
            .fill(color.opacity(0.4))
            .rotationEffect(.degrees(45))
    }
}

private extension Suit {
    var symbol: String {
        switch self {
        case .hearts:
            return "♥"
        case .diamonds:
            return "♦"
        case .clubs:
            return "♣"
        case .spades:
            return "♠"
        }
    }

    var displayColor: Color {
        switch self {
        case .hearts, .diamonds:
            return Color(red: 0.78, green: 0.04, blue: 0.07)
        case .clubs, .spades:
            return Color(red: 0.06, green: 0.06, blue: 0.07)
        }
    }
}

private extension Rank {
    var shortText: String {
        switch self {
        case .two:
            return "2"
        case .three:
            return "3"
        case .four:
            return "4"
        case .five:
            return "5"
        case .six:
            return "6"
        case .seven:
            return "7"
        case .eight:
            return "8"
        case .nine:
            return "9"
        case .ten:
            return "10"
        case .jack:
            return "J"
        case .queen:
            return "Q"
        case .king:
            return "K"
        case .ace:
            return "A"
        }
    }
}
