import SwiftUI

struct TeamRankingView: View {
    @State private var teamCount: Int = 4
    @State private var teamNames: [String] = Array(repeating: "", count: 4)
    @State private var rankedTeams: [RankedTeam] = []
    @State private var rankingTrigger: Int = 0
    @State private var isShuffling: Bool = false
    @State private var shuffleNames: [String] = []
    @State private var shuffleIndex: Int = 0
    @State private var shuffleTimer: Timer? = nil

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.green.opacity(0.28),
                    Color.mint.opacity(0.2),
                    Color.teal.opacity(0.24)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    headerCard

                    if rankedTeams.isEmpty {
                        countSelectorCard
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))

                        namesCard
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))

                        Button {
                            guard !isShuffling else { return }
                            rankTeams()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: isShuffling ? "hourglass.circle" : "shuffle")
                                    .font(.headline)
                                    .symbolEffect(.pulse, isActive: isShuffling)
                                Text(isShuffling ? "Shuffling…" : "Rank Teams")
                                    .font(.headline.weight(.semibold))
                                    .contentTransition(.interpolate)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 58)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: isShuffling
                                                ? [Color.gray.opacity(0.6), Color.gray.opacity(0.4)]
                                                : [Color.teal, Color.green],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .disabled(isShuffling)
                        .animation(.easeInOut(duration: 0.3), value: isShuffling)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))

                        if isShuffling {
                            shufflingIndicator
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Results")
                                .font(.title2.weight(.bold))
                                .transition(.opacity)

                            ForEach(rankedTeams) { item in
                                RankingCard(item: item)
                                    .transition(
                                        .asymmetric(
                                            insertion: .scale(scale: 0.82, anchor: .leading)
                                                .combined(with: .opacity)
                                                .combined(with: .move(edge: .leading)),
                                            removal: .opacity
                                        )
                                    )
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                        Button {
                            resetRanking()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.headline)
                                Text("Refresh Ranking")
                                    .font(.headline.weight(.semibold))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 58)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.cyan, Color.blue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
        .navigationTitle("Team Ranking")
        .navigationBarTitleDisplayMode(.inline)
        .sensoryFeedback(.success, trigger: rankingTrigger)
        .animation(.spring(response: 0.4, dampingFraction: 0.88), value: teamCount)
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: rankedTeams)
        .animation(.easeInOut(duration: 0.3), value: isShuffling)
    }

    private var shufflingIndicator: some View {
        VStack(spacing: 10) {
            Text("🔀 Picking order…")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            if !shuffleNames.isEmpty {
                Text(shuffleNames[shuffleIndex % shuffleNames.count])
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)
                    .id(shuffleIndex)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                    .animation(.easeInOut(duration: 0.12), value: shuffleIndex)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(cardBackground)
    }

    private var headerCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "list.number")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 56, height: 56)
                .background(.ultraThinMaterial, in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("Team Ranking")
                    .font(.title2.weight(.bold))

                Text("Enter names and generate a random ranking")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(cardBackground)
    }

    private var countSelectorCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Number of Teams")
                .font(.headline)

            HStack {
                Text("\(teamCount)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())

                Spacer(minLength: 0)

                Stepper("", value: $teamCount, in: 2...20)
                    .labelsHidden()
                    .onChange(of: teamCount) { _, newValue in
                        syncTeamNames(with: newValue)
                    }
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private var namesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Teams / Players")
                .font(.headline)

            ForEach(0..<teamCount, id: \.self) { index in
                TextField("Team \(index + 1)", text: nameBinding(at: index))
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 12)
                    .frame(minHeight: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.primary.opacity(0.06))
                    )
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
            )
    }

    private func nameBinding(at index: Int) -> Binding<String> {
        Binding(
            get: {
                if index < teamNames.count {
                    return teamNames[index]
                }
                return ""
            },
            set: { newValue in
                if index >= teamNames.count {
                    teamNames.append(contentsOf: Array(repeating: "", count: index - teamNames.count + 1))
                }
                teamNames[index] = newValue
            }
        )
    }

    private func syncTeamNames(with newCount: Int) {
        if newCount > teamNames.count {
            teamNames.append(contentsOf: Array(repeating: "", count: newCount - teamNames.count))
        } else if newCount < teamNames.count {
            teamNames = Array(teamNames.prefix(newCount))
        }

        if rankedTeams.count > newCount {
            rankedTeams = Array(rankedTeams.prefix(newCount))
        }
    }

    private func rankTeams() {
        var names = Array(teamNames.prefix(teamCount)).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        for index in names.indices where names[index].isEmpty {
            names[index] = "Team \(index + 1)"
        }

        let shuffled = names.shuffled()
        let newRankings = shuffled.enumerated().map { offset, name in
            RankedTeam(position: offset + 1, name: name)
        }

        // Reset and start shuffle phase
        withAnimation {
            rankedTeams = []
            isShuffling = true
            shuffleNames = names
            shuffleIndex = 0
        }
        rankingTrigger += 1

        // Spin through names rapidly to create a slot-machine effect
        let spinCount = max(names.count * 4, 12)
        var fireCount = 0
        shuffleTimer?.invalidate()
        shuffleTimer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { timer in
            withAnimation {
                shuffleIndex += 1
            }
            fireCount += 1
            if fireCount >= spinCount {
                timer.invalidate()
                shuffleTimer = nil

                // Reveal each ranked team one by one after spinning stops
                for (index, team) in newRankings.enumerated() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            rankedTeams.append(team)
                        }
                    }
                }

                let totalDelay = Double(newRankings.count) * 0.2 + 0.15
                DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) {
                    withAnimation {
                        isShuffling = false
                    }
                }
            }
        }
    }

    private func resetRanking() {
        withAnimation {
            rankedTeams = []
            isShuffling = false
        }
        shuffleTimer?.invalidate()
        shuffleTimer = nil
    }
}

private struct RankedTeam: Identifiable, Equatable {
    let position: Int
    let name: String

    var id: Int { position }

    var rankLabel: String {
        switch position {
        case 1:
            return "🥇 Rank 1"
        case 2:
            return "🥈 Rank 2"
        case 3:
            return "🥉 Rank 3"
        default:
            return "\(position)th"
        }
    }

    var backgroundColors: [Color] {
        switch position {
        case 1:
            return [Color.yellow.opacity(0.75), Color.orange.opacity(0.75)]
        case 2:
            return [Color.gray.opacity(0.65), Color.white.opacity(0.6)]
        case 3:
            return [Color.brown.opacity(0.7), Color.orange.opacity(0.55)]
        default:
            return [Color.blue.opacity(0.35), Color.teal.opacity(0.35)]
        }
    }
}

private struct RankingCard: View {
    let item: RankedTeam
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.rankLabel)
                    .font(.headline.weight(.semibold))

                Text(item.name)
                    .font(.title3.weight(.bold))
            }

            Spacer(minLength: 0)

            Image(systemName: item.position == 1 ? "trophy.fill" : "rosette")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.95))
                .symbolEffect(.bounce, value: appeared)
        }
        .foregroundStyle(.white)
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 84, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: item.backgroundColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
        )
        .scaleEffect(appeared ? 1.0 : 0.9)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                appeared = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        TeamRankingView()
    }
}
