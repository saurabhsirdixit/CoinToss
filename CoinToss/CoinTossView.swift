import SwiftUI

struct CoinTossView: View {
    private enum Side: String, CaseIterable {
        case heads = "Heads"
        case tails = "Tails"

        var coinMark: String {
            switch self {
            case .heads:
                return "H"
            case .tails:
                return "T"
            }
        }
    }

    @State private var selectedSide: Side = .heads
    @State private var resultSide: Side = .heads
    @State private var spinAngle: Double = 0
    @State private var isFlipping: Bool = false
    @State private var showResult: Bool = false
    @State private var hapticTrigger: Int = 0
    @State private var showFairnessDebugPanel: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.3),
                    Color.yellow.opacity(0.18),
                    Color.brown.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {
                Text("Coin Toss")
                    .font(.largeTitle.weight(.bold))

                Text("Choose your side, then tap the coin")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                sideSelector

                coin

                if showResult {
                    VStack(spacing: 6) {
                        Text("Result: \(resultSide.rawValue)")
                            .font(.title2.weight(.semibold))

                        Text(selectedSide == resultSide ? "You guessed right" : "Try again")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    Text(isFlipping ? "Flipping..." : "Tap the coin to toss")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Toggle(isOn: $showFairnessDebugPanel) {
                    Text("Show Fairness Stats")
                        .font(.subheadline.weight(.semibold))
                }
                .toggleStyle(.switch)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                        )
                )

                if showFairnessDebugPanel {
                    CoinFairnessDebugPanel()
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Coin Toss")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.impact(weight: .medium), trigger: hapticTrigger)
        .animation(.spring(response: 0.38, dampingFraction: 0.86), value: showResult)
    }

    private var sideSelector: some View {
        HStack(spacing: 10) {
            ForEach(Side.allCases, id: \.self) { side in
                Button {
                    guard !isFlipping else { return }
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedSide = side
                    }
                } label: {
                    Text(side.rawValue)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(selectedSide == side ? Color.white : Color.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    selectedSide == side
                                    ? LinearGradient(
                                        colors: [Color.orange, Color.yellow],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    : LinearGradient(
                                        colors: [Color.white.opacity(0.38), Color.white.opacity(0.18)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private var coin: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            Color.yellow.opacity(0.85),
                            Color.orange.opacity(0.9),
                            Color.brown.opacity(0.72)
                        ],
                        center: .topLeading,
                        startRadius: 4,
                        endRadius: 160
                    )
                )
                .overlay(
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.95), Color.yellow.opacity(0.5), Color.orange.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                )
                .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 10)

            Circle()
                .strokeBorder(Color.white.opacity(0.28), lineWidth: 1)
                .padding(14)

            if showResult {
                let displayedSide = resultSide
                coinFace(for: displayedSide)
            } else {
                cricketBatFace
            }
        }
        .frame(width: 250, height: 250)
        .rotation3DEffect(.degrees(spinAngle), axis: (x: 0, y: 1, z: 0), perspective: 0.55)
        .contentShape(Circle())
        .onTapGesture {
            flipCoin()
        }
    }

    private var cricketBatFace: some View {
        ZStack {
            Circle()
                .strokeBorder(
                    AngularGradient(
                        colors: [
                            Color.white.opacity(0.75),
                            Color.yellow.opacity(0.6),
                            Color.orange.opacity(0.7),
                            Color.white.opacity(0.75)
                        ],
                        center: .center
                    ),
                    lineWidth: 6
                )
                .padding(24)

            Circle()
                .strokeBorder(Color.brown.opacity(0.35), lineWidth: 1.5)
                .padding(38)

            Image(systemName: "soccerball")
                .font(.system(size: 80, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white.opacity(0.95), Color.yellow.opacity(0.65), Color.orange.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 1)
        }
    }

    private func coinFace(for side: Side) -> some View {
        ZStack {
            Circle()
                .strokeBorder(
                    AngularGradient(
                        colors: [
                            Color.white.opacity(0.75),
                            Color.yellow.opacity(0.6),
                            Color.orange.opacity(0.7),
                            Color.white.opacity(0.75)
                        ],
                        center: .center
                    ),
                    lineWidth: 6
                )
                .padding(24)

            Circle()
                .strokeBorder(Color.brown.opacity(0.35), lineWidth: 1.5)
                .padding(38)

            Text(side.coinMark)
                .font(.system(size: 86, weight: .black, design: .serif))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white.opacity(0.95), Color.yellow.opacity(0.65), Color.orange.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 1)
        }
    }

    private var currentVisibleSide: Side {
        let normalized = spinAngle.truncatingRemainder(dividingBy: 360)
        let positiveNormalized = normalized >= 0 ? normalized : normalized + 360
        let isFront = positiveNormalized < 90 || positiveNormalized > 270
        return isFront ? .heads : .tails
    }

    private func flipCoin() {
        guard !isFlipping else { return }

        isFlipping = true
        showResult = false

        // Fair random outcome
        let targetSide: Side = Bool.random() ? .heads : .tails

        // Make every toss feel different
        let spinTurns = Int.random(in: 10...25)
        let spinDuration = Double.random(in: 1.8...3.0)
        let spinDirection = Bool.random() ? 1.0 : -1.0

        // Determine final orientation
        let finalFaceAngle: Double = targetSide == .heads ? 0 : 180

        // Normalize current angle
        let normalizedCurrent = spinAngle.truncatingRemainder(dividingBy: 360)

        // Large spin + guaranteed landing side
        let spinDelta =
            Double(spinTurns * 360) * spinDirection +
            (finalFaceAngle - normalizedCurrent)

        let finalRotation = spinAngle + spinDelta

        withAnimation(
            .timingCurve(
                0.18,
                0.88,
                0.20,
                1.0,
                duration: spinDuration
            )
        ) {
            spinAngle = finalRotation
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + spinDuration) {

            // Reveal the pre-selected fair result
            resultSide = targetSide

            hapticTrigger += 1

            withAnimation(.spring()) {
                showResult = true
            }

            isFlipping = false
        }
    }
}

#Preview {
    NavigationStack {
        CoinTossView()
    }
}

private struct CoinFairnessDebugPanel: View {
    @State private var headsCount: Int = 0
    @State private var tailsCount: Int = 0
    private let trials: Int = 1000

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Debug Fairness (Preview)")
                .font(.headline)

            Text("Heads: \(headsCount)   Tails: \(tailsCount)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Heads \(percent(headsCount))% | Tails \(percent(tailsCount))%")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button("Run 1,000 Tosses") {
                runSimulation()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .task {
            runSimulation()
        }
    }

    private func runSimulation() {
        var heads = 0
        var tails = 0

        for _ in 0..<trials {
            if Bool.random() {
                heads += 1
            } else {
                tails += 1
            }
        }

        headsCount = heads
        tailsCount = tails
    }

    private func percent(_ value: Int) -> String {
        String(format: "%.1f", (Double(value) / Double(trials)) * 100)
    }
}
