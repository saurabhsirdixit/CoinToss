import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.35),
                        Color.cyan.opacity(0.2),
                        Color.indigo.opacity(0.28)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    Text("CoinToss")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .padding(.top, 8)

                    Text("Choose a feature")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 16) {
                        NavigationLink {
                            CoinTossView()
                        } label: {
                            FeatureCard(
                                title: "Coin Toss",
                                subtitle: "Flip a coin like in real life",
                                systemImage: "circle.lefthalf.filled"
                            )
                        }
                        .buttonStyle(CardPressStyle())

                        NavigationLink {
                            TeamRankingView()
                        } label: {
                            FeatureCard(
                                title: "Team Ranking",
                                subtitle: "Randomly rank teams or players",
                                systemImage: "list.number"
                            )
                        }
                        .buttonStyle(CardPressStyle())
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

private struct FeatureCard: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                    )
                    .frame(width: 58, height: 58)

                Image(systemName: systemImage)
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.trailing, 2)
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 128, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

private struct CardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    HomeView()
}
