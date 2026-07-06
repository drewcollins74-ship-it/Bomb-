//
//  ContentView.swift
//  Bomb!
//
//  Created by DREW COLLINS on 7/4/26.
//

import SwiftUI

struct ContentView: View {

    @State private var playerName = ""
    @State private var totalPlayers = 3
    @State private var game: Game?
    @State private var selectedSetupCardIDs: Set<PlayingCard.ID> = []
    @State private var selectedHandCardIDs: Set<PlayingCard.ID> = []
    @State private var isAutoPlayingComputerTurn = false

    var body: some View {
        if let game {
            if game.isSetupComplete {
                GameScreen(
                    game: game,
                    selectedHandCardIDs: selectedHandCardIDs,
                    toggleHandCardSelection: toggleHandCardSelection,
                    playSelectedHandCards: playSelectedHandCards,
                    pickUpPlayPile: pickUpPlayPile
                )
                .onAppear {
                    scheduleComputerTurnIfNeeded()
                }
                .onChange(of: game.currentPlayerIndex) {
                    scheduleComputerTurnIfNeeded()
                }
            } else {
                FaceUpSetupView(
                    game: game,
                    selectedCardIDs: $selectedSetupCardIDs,
                    toggleCardSelection: toggleSetupCardSelection,
                    finishSetup: finishSetup
                )
            }
        } else {
            NewGameView(
                playerName: $playerName,
                totalPlayers: $totalPlayers,
                startGame: startGame
            )
        }
    }

    private func startGame() {
        let trimmedName = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        let localPlayerName = trimmedName.isEmpty ? "Player" : trimmedName
        let computerPlayerNames = (1..<totalPlayers).map { "Computer \($0)" }
        selectedSetupCardIDs.removeAll()
        selectedHandCardIDs.removeAll()
        isAutoPlayingComputerTurn = false

        game = Game(
            localPlayerName: localPlayerName,
            computerPlayerNames: computerPlayerNames
        )
    }

    private func toggleSetupCardSelection(_ card: PlayingCard) {
        if selectedSetupCardIDs.contains(card.id) {
            selectedSetupCardIDs.remove(card.id)
        } else if selectedSetupCardIDs.count < 3 {
            selectedSetupCardIDs.insert(card.id)
        }
    }

    private func finishSetup() {
        game?.chooseLocalFaceUpCards(cardIDs: Array(selectedSetupCardIDs))
        selectedSetupCardIDs.removeAll()
        scheduleComputerTurnIfNeeded()
    }

    private func toggleHandCardSelection(_ card: PlayingCard) {
        if selectedHandCardIDs.contains(card.id) {
            selectedHandCardIDs.remove(card.id)
        } else {
            selectedHandCardIDs.insert(card.id)
        }
    }

    private func playSelectedHandCards() {
        guard game?.playLocalCards(cardIDs: selectedHandCardIDs) == true else {
            return
        }

        selectedHandCardIDs.removeAll()
        scheduleComputerTurnIfNeeded()
    }

    private func pickUpPlayPile() {
        guard game?.pickUpPlayPileForLocalPlayer() == true else {
            return
        }

        selectedHandCardIDs.removeAll()
        scheduleComputerTurnIfNeeded()
    }

    private func scheduleComputerTurnIfNeeded() {
        guard isAutoPlayingComputerTurn == false,
              let game,
              game.isSetupComplete,
              game.players[game.currentPlayerIndex].kind == .computer else {
            return
        }

        isAutoPlayingComputerTurn = true

        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            await MainActor.run {
                guard let game = self.game,
                      game.players[game.currentPlayerIndex].kind == .computer else {
                    self.isAutoPlayingComputerTurn = false
                    return
                }

                _ = self.game?.playCurrentComputerTurn()
                self.isAutoPlayingComputerTurn = false
                self.scheduleComputerTurnIfNeeded()
            }
        }
    }
}

struct NewGameView: View {
    @Binding var playerName: String
    @Binding var totalPlayers: Int
    let startGame: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Bomb!")
                .font(.largeTitle)
                .bold()

            VStack(alignment: .leading, spacing: 8) {
                Text("Player Name")
                    .font(.headline)

                TextField("Your name", text: $playerName)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Total Players")
                    .font(.headline)

                Picker("Total Players", selection: $totalPlayers) {
                    ForEach(2...5, id: \.self) { playerCount in
                        Text("\(playerCount)").tag(playerCount)
                    }
                }
                .pickerStyle(.segmented)
            }

            Button("Start Game", action: startGame)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct FaceUpSetupView: View {
    let game: Game
    @Binding var selectedCardIDs: Set<PlayingCard.ID>
    let toggleCardSelection: (PlayingCard) -> Void
    let finishSetup: () -> Void

    private var localPlayer: Player {
        game.localPlayer
    }

    var body: some View {
        GeometryReader { geometry in
            let metrics = FaceUpSetupMetrics(
                size: geometry.size,
                safeAreaInsets: geometry.safeAreaInsets,
                opponentCount: game.opponents.count
            )

            VStack(spacing: metrics.spacing) {
                Text("Bomb!")
                    .font(.system(size: metrics.titleFontSize, weight: .bold))

                Text("\(localPlayer.name), choose 3 face-up cards")
                    .font(.system(size: metrics.instructionFontSize, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text("Selected: \(selectedCardIDs.count) of 3")
                    .font(.system(size: metrics.bodyFontSize))

                VStack(spacing: metrics.gridControlSpacing) {
                    LazyVGrid(
                        columns: metrics.cardColumns,
                        spacing: metrics.cardSpacing
                    ) {
                        ForEach(localPlayer.hand) { card in
                            Button {
                                toggleCardSelection(card)
                            } label: {
                                CardView(card: card, width: metrics.cardWidth)
                                    .frame(
                                        width: metrics.cardWidth,
                                        height: metrics.cardHeight
                                    )
                                    .overlay {
                                        if selectedCardIDs.contains(card.id) {
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.blue, lineWidth: 4)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(height: metrics.cardGridHeight)
                    .padding(.bottom, metrics.gridBottomPadding)

                    Text("Face-Down Cards: \(localPlayer.faceDownCards.count)")
                        .font(.system(size: metrics.bodyFontSize))
                        .padding(.top, metrics.faceDownLabelTopPadding)

                    Button("Confirm Face-Up Cards", action: finishSetup)
                        .buttonStyle(.borderedProminent)
                        .controlSize(metrics.isShortScreen ? .small : .regular)
                        .disabled(selectedCardIDs.count != 3)
                }

                opponentsPreview(metrics: metrics)
            }
            .padding(.horizontal, metrics.horizontalPadding)
            .padding(.top, metrics.topPadding)
            .padding(.bottom, metrics.bottomPadding)
        }
    }

    private func opponentsPreview(metrics: FaceUpSetupMetrics) -> some View {
        VStack(spacing: metrics.opponentsSpacing) {
            Text("Opponents")
                .font(.system(size: metrics.bodyFontSize, weight: .semibold))

            ForEach(game.opponents) { opponent in
                Text("\(opponent.name): \(opponent.hand.count) cards in hand")
                    .font(.system(size: metrics.summaryFontSize))
                    .lineLimit(1)
            }
        }
    }
}

struct FaceUpSetupMetrics {
    let size: CGSize
    let safeAreaInsets: EdgeInsets
    let opponentCount: Int

    private var safeHeight: CGFloat {
        size.height - safeAreaInsets.top - safeAreaInsets.bottom
    }

    var isShortScreen: Bool {
        safeHeight < 700
    }

    var horizontalPadding: CGFloat {
        clamp(size.width * 0.045, min: 14, max: 22)
    }

    var topPadding: CGFloat {
        safeAreaInsets.top + clamp(safeHeight * 0.018, min: 10, max: 18)
    }

    var bottomPadding: CGFloat {
        safeAreaInsets.bottom + clamp(safeHeight * 0.012, min: 8, max: 14)
    }

    var spacing: CGFloat {
        clamp(safeHeight * 0.018, min: 8, max: 16)
    }

    var cardSpacing: CGFloat {
        clamp(size.width * 0.025, min: 8, max: 12)
    }

    var cardColumns: [GridItem] {
        Array(
            repeating: GridItem(.fixed(cardWidth), spacing: cardSpacing),
            count: 3
        )
    }

    var titleFontSize: CGFloat {
        clamp(safeHeight * 0.05, min: 28, max: 42)
    }

    var instructionFontSize: CGFloat {
        clamp(safeHeight * 0.027, min: 17, max: 23)
    }

    var bodyFontSize: CGFloat {
        clamp(safeHeight * 0.019, min: 13, max: 16)
    }

    var summaryFontSize: CGFloat {
        clamp(safeHeight * 0.016, min: 11, max: 14)
    }

    var opponentsSpacing: CGFloat {
        clamp(safeHeight * 0.007, min: 3, max: 7)
    }

    var gridControlSpacing: CGFloat {
        clamp(safeHeight * 0.014, min: 9, max: 14)
    }

    var gridBottomPadding: CGFloat {
        clamp(safeHeight * 0.018, min: 12, max: 18)
    }

    var faceDownLabelTopPadding: CGFloat {
        clamp(safeHeight * 0.006, min: 4, max: 8)
    }

    private var contentWidth: CGFloat {
        size.width - horizontalPadding * 2
    }

    private var estimatedNonCardHeight: CGFloat {
        titleFontSize * 1.15
        + instructionFontSize * 1.2
        + bodyFontSize * 2.4
        + 42
        + bodyFontSize * 1.3
        + CGFloat(opponentCount + 1) * summaryFontSize * 1.25
        + spacing * 6
        + gridControlSpacing * 2
        + gridBottomPadding
        + faceDownLabelTopPadding
        + topPadding - safeAreaInsets.top
        + bottomPadding - safeAreaInsets.bottom
    }

    var cardWidth: CGFloat {
        let widthBased = (contentWidth - cardSpacing * 2) / 3
        let availableGridHeight = safeHeight - estimatedNonCardHeight
        let heightBased = (availableGridHeight - cardSpacing) / 2 * PlayingCardLayout.aspectRatio
        return clamp(min(widthBased, heightBased), min: 54, max: 96)
    }

    var cardGridHeight: CGFloat {
        PlayingCardLayout.height(forWidth: cardWidth) * 2 + cardSpacing
    }

    var cardHeight: CGFloat {
        PlayingCardLayout.height(forWidth: cardWidth)
    }

    private func clamp(_ value: CGFloat, min minimum: CGFloat, max maximum: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, minimum), maximum)
    }
}

struct GameScreen: View {
    let game: Game
    let selectedHandCardIDs: Set<PlayingCard.ID>
    let toggleHandCardSelection: (PlayingCard) -> Void
    let playSelectedHandCards: () -> Void
    let pickUpPlayPile: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let metrics = GameScreenMetrics(
                size: geometry.size,
                safeAreaInsets: geometry.safeAreaInsets,
                opponentCount: game.opponents.count,
                localHandCount: game.localPlayer.hand.count
            )

            ZStack {
                TableBackground()
                    .ignoresSafeArea()

                VStack(spacing: metrics.sectionSpacing) {
                    header(metrics: metrics)
                        .frame(height: metrics.headerHeight)

                    opponentsSection(metrics: metrics)
                        .frame(height: metrics.opponentsHeight)

                    tableCenter(metrics: metrics)
                        .frame(height: metrics.centerHeight)

                    localPlayerSection(metrics: metrics)
                        .frame(height: metrics.playerHeight)

                    footer(metrics: metrics)
                        .frame(height: metrics.footerHeight)
                }
                .padding(.horizontal, metrics.outerPadding)
                .padding(.top, metrics.topPadding)
                .padding(.bottom, metrics.bottomPadding)
            }
        }
    }

    private func header(metrics: GameScreenMetrics) -> some View {
        HStack {
            CircleButton(
                systemName: "line.3.horizontal",
                size: metrics.iconButtonSize
            )

            Spacer()

            Text("Bomb!")
                .font(.system(size: metrics.titleFontSize, weight: .heavy, design: .rounded))
                .foregroundStyle(.primary)
                .padding(.horizontal, metrics.titleHorizontalPadding)
                .padding(.vertical, metrics.compactPadding)
                .background(
                    Capsule()
                        .fill(.ultraThickMaterial)
                        .shadow(color: .black.opacity(0.25), radius: 5, y: 3)
                )

            Spacer()

            CircleButton(
                systemName: "gearshape.fill",
                size: metrics.iconButtonSize
            )
        }
    }

    private func localPlayerSection(metrics: GameScreenMetrics) -> some View {
        let localPlayer = game.localPlayer

        return VStack(spacing: metrics.playerInnerSpacing) {
            PlayerBadge(
                name: localPlayer.name,
                count: nil,
                color: .yellow,
                compact: metrics.isShortScreen
            )

            Text("Your 3 setup cards")
                .font(.system(size: metrics.labelFontSize, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))

            TableCardPilesView(
                faceUpCards: localPlayer.faceUpCards,
                faceDownCount: localPlayer.faceDownCards.count,
                cardWidth: metrics.playerSetupCardWidth,
                spacing: metrics.playerSetupSpacing
            )

            HStack {
                Text("Your remaining hand (\(localPlayer.hand.count) cards)")
                    .font(.system(size: metrics.labelFontSize, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))

                Spacer()

                Button("Play") {
                    playSelectedHandCards()
                }
                .font(.system(size: metrics.labelFontSize, weight: .semibold))
                .disabled(
                    game.currentPlayerIndex != game.localPlayerIndex ||
                    selectedHandCardIDs.isEmpty
                )
            }

            ScrollView(.horizontal) {
                HStack(spacing: metrics.handCardSpacing) {
                    ForEach(localPlayer.hand) { card in
                        Button {
                            toggleHandCardSelection(card)
                        } label: {
                            CardView(card: card, width: metrics.handCardWidth)
                                .overlay {
                                    if selectedHandCardIDs.contains(card.id) {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.blue, lineWidth: 3)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        .disabled(game.currentPlayerIndex != game.localPlayerIndex)
                    }
                }
                .padding(.horizontal, metrics.handScrollHorizontalPadding)
            }
            .frame(height: PlayingCardLayout.height(forWidth: metrics.handCardWidth))
            .scrollIndicators(.hidden)
        }
        .padding(.vertical, metrics.panelPadding)
        .frame(maxWidth: .infinity)
        .background(PanelBackground())
    }

    private func opponentsSection(metrics: GameScreenMetrics) -> some View {
        VStack(spacing: metrics.opponentsInnerSpacing) {
            Label("Opponents", systemImage: "person.2.fill")
                .font(.system(size: metrics.opponentsTitleFontSize, weight: .bold))
                .foregroundStyle(.white)

            LazyVGrid(
                columns: metrics.opponentGridColumns,
                spacing: metrics.opponentRowSpacing
            ) {
                ForEach(Array(game.opponents.enumerated()), id: \.element.id) { index, opponent in
                    OpponentTableView(
                        opponent: opponent,
                        color: opponentColor(at: index),
                        cardWidth: metrics.opponentCardWidth,
                        compact: metrics.isShortScreen
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, metrics.panelPadding)
        .padding(.vertical, metrics.panelPadding)
        .frame(maxWidth: .infinity)
        .background(PanelBackground())
    }

    private func tableCenter(metrics: GameScreenMetrics) -> some View {
        VStack(spacing: metrics.centerInnerSpacing) {
            Text(game.lastActionMessage ?? (game.currentPlayerIndex == game.localPlayerIndex ? "Your Turn" : "\(game.players[game.currentPlayerIndex].name)'s Turn"))
                .font(.system(size: metrics.turnFontSize, weight: .semibold))
                .foregroundStyle(.green)
                .padding(.horizontal, metrics.titleHorizontalPadding)
                .padding(.vertical, metrics.compactPadding)
                .background(
                    Capsule()
                        .fill(.black.opacity(0.35))
                )

            HStack(alignment: .bottom) {
                VStack(spacing: metrics.pileInnerSpacing) {
                    PileLabel(text: "Draw Pile")
                    CardBackStackView(
                        count: game.drawPile.count,
                        cardWidth: metrics.pileCardWidth
                    )
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: metrics.pileInnerSpacing) {
                    PileLabel(text: "Play Pile")
                    PlayPileStackView(
                        cards: game.playPile,
                        cardWidth: metrics.playPileCardWidth,
                        placeholderFontSize: metrics.playPileFontSize
                    )

                    Button("Pick Up") {
                        pickUpPlayPile()
                    }
                    .font(.system(size: metrics.playPileFontSize, weight: .semibold))
                    .disabled(
                        game.currentPlayerIndex != game.localPlayerIndex ||
                        game.playPile.isEmpty
                    )
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: metrics.pileInnerSpacing) {
                    PileLabel(text: "Discard Pile")
                    if let topDiscard = game.discardPile.last {
                        CardView(card: topDiscard, width: metrics.pileCardWidth)
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.2))
                            .frame(
                                width: metrics.pileCardWidth,
                                height: PlayingCardLayout.height(forWidth: metrics.pileCardWidth)
                            )
                            .overlay {
                                Text("Discard")
                                    .font(.system(size: metrics.playPileFontSize))
                                    .foregroundStyle(.white.opacity(0.75))
                            }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, metrics.panelPadding)
        .padding(.vertical, metrics.panelPadding)
        .frame(maxWidth: .infinity)
        .background(PanelBackground())
    }

    private func footer(metrics: GameScreenMetrics) -> some View {
        HStack(spacing: metrics.compactPadding) {
            Image(systemName: "info.circle")
                .font(.system(size: metrics.footerIconSize))

            Text("Goal:")
                .bold()

            Text("Be the first to get rid of all cards.")
                .lineLimit(2)

            Spacer()

            Button("Rules") {}
                .buttonStyle(.bordered)
                .tint(.white)
        }
        .font(.system(size: metrics.footerFontSize))
        .foregroundStyle(.white)
        .padding(.horizontal, metrics.panelPadding)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.black.opacity(0.35))
        )
    }

    private func opponentColor(at index: Int) -> Color {
        let colors: [Color] = [.blue, .green, .purple, .orange]
        return colors[index % colors.count]
    }
}

struct GameScreenMetrics {
    let size: CGSize
    let safeAreaInsets: EdgeInsets
    let opponentCount: Int
    let localHandCount: Int

    private var safeHeight: CGFloat {
        size.height - safeAreaInsets.top - safeAreaInsets.bottom
    }

    private var safeWidth: CGFloat {
        size.width
    }

    var isShortScreen: Bool {
        safeHeight < 720
    }

    var outerPadding: CGFloat {
        clamp(safeWidth * 0.035, min: 10, max: 16)
    }

    var topPadding: CGFloat {
        safeAreaInsets.top + clamp(safeHeight * 0.006, min: 3, max: 8)
    }

    var bottomPadding: CGFloat {
        safeAreaInsets.bottom + clamp(safeHeight * 0.006, min: 3, max: 8)
    }

    var sectionSpacing: CGFloat {
        clamp(safeHeight * 0.008, min: 5, max: 10)
    }

    private var availableHeight: CGFloat {
        safeHeight - topPadding + safeAreaInsets.top - bottomPadding + safeAreaInsets.bottom - sectionSpacing * 4
    }

    var headerHeight: CGFloat {
        clamp(safeHeight * 0.075, min: 44, max: 60)
    }

    var footerHeight: CGFloat {
        clamp(safeHeight * 0.062, min: 40, max: 54)
    }

    var playerHeight: CGFloat {
        availableHeight - headerHeight - footerHeight - opponentsHeight - centerHeight
    }

    var centerHeight: CGFloat {
        clamp(safeHeight * (opponentRows > 1 ? 0.18 : 0.21), min: 112, max: 165)
    }

    var opponentsHeight: CGFloat {
        let titleHeight = opponentsTitleFontSize * 1.4
        let rowContentHeight = opponentBadgeHeight + opponentsInnerSpacing + PlayingCardLayout.stackedHeight(forWidth: opponentWidthBasedCardWidth)
        let rowsHeight = CGFloat(opponentRows) * rowContentHeight
        let rowSpacingHeight = CGFloat(max(0, opponentRows - 1)) * opponentRowSpacing
        let desiredHeight = panelPadding * 2 + titleHeight + opponentsInnerSpacing + rowsHeight + rowSpacingHeight
        let maximumHeight = availableHeight - headerHeight - footerHeight - centerHeight - 170

        return min(desiredHeight, maximumHeight)
    }

    var panelPadding: CGFloat {
        clamp(safeHeight * 0.011, min: 5, max: 10)
    }

    var compactPadding: CGFloat {
        clamp(safeHeight * 0.008, min: 4, max: 8)
    }

    var contentWidth: CGFloat {
        safeWidth - outerPadding * 2
    }

    var iconButtonSize: CGFloat {
        clamp(headerHeight * 0.75, min: 36, max: 48)
    }

    var titleFontSize: CGFloat {
        clamp(headerHeight * 0.48, min: 25, max: 34)
    }

    var titleHorizontalPadding: CGFloat {
        clamp(safeWidth * 0.055, min: 16, max: 28)
    }

    var labelFontSize: CGFloat {
        clamp(safeHeight * 0.017, min: 12, max: 15)
    }

    var turnFontSize: CGFloat {
        clamp(safeHeight * 0.018, min: 12, max: 16)
    }

    var opponentsTitleFontSize: CGFloat {
        clamp(safeHeight * 0.018, min: 13, max: 17)
    }

    var footerFontSize: CGFloat {
        clamp(safeHeight * 0.017, min: 12, max: 15)
    }

    var footerIconSize: CGFloat {
        clamp(footerHeight * 0.48, min: 20, max: 28)
    }

    var playerInnerSpacing: CGFloat {
        clamp(playerHeight * 0.026, min: 5, max: 8)
    }

    var playerSetupSpacing: CGFloat {
        clamp(contentWidth * 0.07, min: 16, max: 28)
    }

    var handCardSpacing: CGFloat {
        if localHandCount > 6 {
            return clamp(contentWidth * 0.025, min: 8, max: 12)
        }

        return clamp(contentWidth * 0.055, min: 14, max: 24)
    }

    var handScrollHorizontalPadding: CGFloat {
        clamp(contentWidth * 0.01, min: 4, max: 8)
    }

    var playerSetupCardWidth: CGFloat {
        let widthBased = (contentWidth - playerSetupSpacing * 2) / 3
        let labelHeight = labelFontSize * 2.5
        let badgeHeight: CGFloat = isShortScreen ? 28 : 34
        let available = playerHeight - panelPadding * 2 - labelHeight - badgeHeight - playerInnerSpacing * 4
        let heightBased = available / (1 / PlayingCardLayout.aspectRatio + PlayingCardLayout.stackedHeight(forWidth: 1))
        return clamp(min(widthBased, heightBased), min: 38, max: 64)
    }

    var handCardWidth: CGFloat {
        let widthBased = (contentWidth - handCardSpacing * 2) / 3
        let countBasedScale: CGFloat

        switch localHandCount {
        case 0...3:
            countBasedScale = 1
        case 4...6:
            countBasedScale = 0.92
        case 7...10:
            countBasedScale = 0.82
        default:
            countBasedScale = 0.72
        }

        return clamp(min(widthBased, playerSetupCardWidth) * countBasedScale, min: 34, max: 62)
    }

    var opponentsInnerSpacing: CGFloat {
        clamp(safeHeight * 0.008, min: 3, max: 8)
    }

    var opponentSpacing: CGFloat {
        clamp(contentWidth * 0.025, min: 6, max: 12)
    }

    var opponentRowSpacing: CGFloat {
        clamp(safeHeight * 0.01, min: 5, max: 9)
    }

    var opponentColumns: Int {
        switch opponentCount {
        case 0...1:
            return 1
        case 2:
            return 2
        case 3:
            return 3
        default:
            return 2
        }
    }

    var opponentRows: Int {
        Int(ceil(Double(max(1, opponentCount)) / Double(opponentColumns)))
    }

    var opponentGridColumns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: opponentSpacing),
            count: opponentColumns
        )
    }

    var opponentBadgeHeight: CGFloat {
        28
    }

    private var opponentWidthBasedCardWidth: CGFloat {
        let columns = CGFloat(opponentColumns)
        let availableWidth = contentWidth - panelPadding * 2 - opponentSpacing * (columns - 1)
        let tileWidth = availableWidth / columns
        return clamp((tileWidth - 12) / 3, min: 24, max: 44)
    }

    var opponentCardWidth: CGFloat {
        let titleHeight = opponentsTitleFontSize * 1.4
        let availableRowsHeight = opponentsHeight - panelPadding * 2 - titleHeight - opponentsInnerSpacing - opponentRowSpacing * CGFloat(max(0, opponentRows - 1))
        let availableTileHeight = availableRowsHeight / CGFloat(opponentRows)
        let heightBased = (availableTileHeight - opponentBadgeHeight - opponentsInnerSpacing) / PlayingCardLayout.stackedHeight(forWidth: 1)

        return clamp(min(opponentWidthBasedCardWidth, heightBased), min: 24, max: 44)
    }

    var centerInnerSpacing: CGFloat {
        clamp(centerHeight * 0.07, min: 5, max: 12)
    }

    var pileInnerSpacing: CGFloat {
        clamp(centerHeight * 0.04, min: 4, max: 7)
    }

    var pileCardWidth: CGFloat {
        let widthBased = contentWidth / 4.2
        let labelHeight: CGFloat = 22
        let turnHeight = turnFontSize + compactPadding * 2
        let available = centerHeight - panelPadding * 2 - turnHeight - centerInnerSpacing - labelHeight - pileInnerSpacing
        let heightBased = available * PlayingCardLayout.aspectRatio
        return clamp(min(widthBased, heightBased), min: 38, max: 62)
    }

    var playPileFontSize: CGFloat {
        clamp(pileCardWidth * 0.18, min: 9, max: 12)
    }

    var playPileCardWidth: CGFloat {
        pileCardWidth * 0.68
    }

    private func clamp(_ value: CGFloat, min minimum: CGFloat, max maximum: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, minimum), maximum)
    }
}

struct TableBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.42, green: 0.20, blue: 0.08),
                Color(red: 0.66, green: 0.34, blue: 0.14),
                Color(red: 0.36, green: 0.16, blue: 0.06)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Color.black.opacity(0.08)
        }
    }
}

struct CircleButton: View {
    let systemName: String
    var size: CGFloat = 58

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.42))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(.black.opacity(0.35))
                    .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
            )
    }
}

struct PanelBackground: View {
    var body: some View {
        Color.clear
    }
}

struct PlayerBadge: View {
    let name: String
    let count: Int?
    let color: Color
    var compact: Bool = false

    var body: some View {
        HStack(spacing: compact ? 6 : 10) {
            Circle()
                .fill(color)
                .frame(width: compact ? 12 : 18, height: compact ? 12 : 18)

            Text(name)
                .font(.system(size: compact ? 12 : 17, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .layoutPriority(1)

            if let count {
                Text("\(count)")
                    .font(.system(size: compact ? 12 : 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, compact ? 7 : 10)
                    .padding(.vertical, compact ? 2 : 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.white.opacity(0.75), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, compact ? 9 : 16)
        .padding(.vertical, compact ? 5 : 8)
        .frame(minWidth: compact ? 92 : 132)
        .background(
            Capsule()
                .fill(.black.opacity(0.38))
        )
    }
}

enum TableOpponentOrientation {
    case north
    case west
    case east
}

struct OpponentTableView: View {
    let opponent: Player
    let color: Color
    let cardWidth: CGFloat
    var compact: Bool = false

    var body: some View {
        VStack(spacing: compact ? 4 : 8) {
            PlayerBadge(
                name: opponent.name,
                count: opponent.hand.count,
                color: color,
                compact: true
            )

            TableCardPilesView(
                faceUpCards: opponent.faceUpCards,
                faceDownCount: opponent.faceDownCards.count,
                cardWidth: cardWidth,
                spacing: max(3, cardWidth * 0.12)
            )
        }
    }
}

enum TableCardPileAxis {
    case horizontal
    case vertical
}

struct TableCardPilesView: View {
    let faceUpCards: [PlayingCard]
    let faceDownCount: Int
    let cardWidth: CGFloat
    let spacing: CGFloat
    var axis: TableCardPileAxis = .horizontal

    var body: some View {
        Group {
            switch axis {
            case .horizontal:
                HStack(spacing: spacing) {
                    piles
                }
            case .vertical:
                VStack(spacing: spacing) {
                    piles
                }
            }
        }
    }

    private var piles: some View {
        ForEach(Array(faceUpCards.enumerated()), id: \.element.id) { index, card in
            TableCardPileView(
                faceUpCard: card,
                showsFaceDownCard: index < faceDownCount,
                cardWidth: cardWidth
            )
        }
    }
}

struct TableCardPileView: View {
    let faceUpCard: PlayingCard
    let showsFaceDownCard: Bool
    let cardWidth: CGFloat

    var body: some View {
        ZStack {
            if showsFaceDownCard {
                CardBackView(width: cardWidth)
                    .offset(y: cardWidth * PlayingCardLayout.stackOffsetFraction)
            }

            CardView(card: faceUpCard, width: cardWidth)
                .offset(y: -cardWidth * PlayingCardLayout.stackOffsetFraction)
        }
        .frame(
            width: cardWidth,
            height: PlayingCardLayout.stackedHeight(forWidth: cardWidth)
        )
    }
}

struct FaceDownCountView: View {
    let count: Int

    var body: some View {
        HStack(spacing: 6) {
            CardBackView()
                .scaleEffect(0.28)
                .frame(
                    width: 22,
                    height: PlayingCardLayout.height(forWidth: 22)
                )

            Text("\(count) face-down")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(.black.opacity(0.32))
        )
    }
}

struct CardBackView: View {
    var width: CGFloat = 70

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(.red)
            .frame(
                width: width,
                height: PlayingCardLayout.height(forWidth: width)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white, lineWidth: 4)
                    .padding(5)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.white.opacity(0.8), lineWidth: 1)
                    .padding(15)
            }
            .shadow(color: .black.opacity(0.35), radius: 3, y: 2)
    }
}

struct CardBackStackView: View {
    let count: Int
    var cardWidth: CGFloat = 70

    var body: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { index in
                CardBackView(width: cardWidth)
                    .offset(y: CGFloat(index) * cardWidth * 0.04)
            }
        }
        .overlay(alignment: .topTrailing) {
            Text("\(count)")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .padding(6)
                .background(Circle().fill(.black.opacity(0.5)))
                .offset(x: 10, y: -10)
        }
        .frame(
            width: cardWidth,
            height: PlayingCardLayout.height(forWidth: cardWidth) + cardWidth * 0.12
        )
    }
}

struct PlayPileStackView: View {
    let cards: [PlayingCard]
    let cardWidth: CGFloat
    let placeholderFontSize: CGFloat

    private var visibleCards: [PlayingCard] {
        Array(cards.suffix(3))
    }

    var body: some View {
        ZStack {
            if visibleCards.isEmpty {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.white.opacity(0.65), style: StrokeStyle(lineWidth: 2, dash: [7]))
                    .frame(
                        width: cardWidth,
                        height: PlayingCardLayout.height(forWidth: cardWidth)
                    )
                    .overlay {
                        Text("Play\nPile")
                            .font(.system(size: placeholderFontSize))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.75))
                    }
            } else {
                HStack(spacing: -cardWidth * 0.18) {
                    ForEach(Array(visibleCards.enumerated()), id: \.element.id) { index, card in
                        CardView(card: card, width: cardWidth)
                            .overlay(alignment: .topLeading) {
                                PlayPileCornerLabel(
                                    card: card,
                                    width: cardWidth
                                )
                            }
                            .zIndex(Double(index))
                    }
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            Text("\(cards.count)")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .padding(6)
                .background(Circle().fill(.black.opacity(0.5)))
                .offset(x: 10, y: -10)
        }
        .frame(
            width: cardWidth * 2.64,
            height: PlayingCardLayout.height(forWidth: cardWidth)
        )
    }
}

struct PlayPileCornerLabel: View {
    let card: PlayingCard
    let width: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            Text(rankText)
                .font(.system(size: width * 0.24, weight: .bold))

            Text(suitText)
                .font(.system(size: width * 0.22, weight: .bold))
        }
        .foregroundStyle(cardColor)
        .padding(width * 0.08)
    }

    private var rankText: String {
        switch card.kind {
        case .joker:
            return "J"
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

struct PileLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(.black.opacity(0.35))
            )
    }
}

#Preview {
    ContentView()
}
