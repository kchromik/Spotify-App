import SwiftUI
import SpotifyiOS
import Combine

struct PlayerView: View {

    @ObservedObject var player: Player
    
    var body: some View {

        NavigationView {
            VStack {
                HStack {
                    Text(player.playerState?.contextTitle ?? "")
                        .foregroundColor(.textPrimary)
                }
                .padding(.bottom, 40)

                ZStack {
                    Image(uiImage: (player.artworkImage ?? UIImage(named: "album")!))
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(12)
                        .padding(EdgeInsets(top: 0, leading: 40, bottom: 20, trailing: 40))
                        .if(player.playerState?.isPaused == false, apply: { view in
                            AnyView(view.shadow(color: .gray, radius: 10, x: 0, y: 0))
                        })
                }

                VStack(alignment: .leading) {
                    Text(player.playerState?.track.name ?? "N/A")
                        .font(.title)
                        .foregroundColor(.textPrimary)
                    Text(player.playerState?.track.artist.name ?? "N/A")
                        .font(.title2)
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 40)

                HStack {
                    Text(player.progressString)
                        .foregroundColor(Color.textSecondary)
                    Spacer()
                    Text(player.durationString)
                        .foregroundColor(Color.textSecondary)
                }
                .padding(EdgeInsets(top: 10, leading: 40, bottom: 0, trailing: 40))

                ProgressView(value: player.currentProgress, total: Float(player.playerState?.track.duration ?? 1))
                    .accentColor(.textPrimary)
                    .frame(height: 16.0)
                    .scaleEffect(x: 1, y: 4, anchor: .center)
                    .cornerRadius(8, corners: .allCorners)
                    .padding([.leading, .trailing], 40)

                HStack {
                    Button {
                        player.skipToPrevious()
                    } label: {
                        Image(systemName: "arrow.left.to.line.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.leading, 40)

                    Spacer()

                    Button {
                        player.playerState?.isPaused == true ? player.resume() : player.pause()
                    } label: {
                        if player.playerState?.isPaused == true {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 100))
                                .foregroundColor(.textSecondary)
                        } else {
                            Image(systemName: "pause.circle.fill")
                                .font(.system(size: 100))
                                .foregroundColor(.textSecondary)
                        }
                    }

                    Spacer()

                    Button {
                        player.skipToNext()
                    } label: {
                        Image(systemName: "arrow.right.to.line.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.trailing, 40)
                }
                .padding(.bottom, 30)

            }
            .background(Color.backgroundPrimary)
            .onAppear {
                player.updateState()
            }
        }
        
    }
}
