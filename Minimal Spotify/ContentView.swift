import SwiftUI

struct ContentView: View {

    @StateObject var spotifyController = SpotifyController()
    
    var body: some View {
        PlayerView(player: Player(spotifyController: spotifyController))
        .onOpenURL { url in
            spotifyController.setAccessToken(from: url)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didFinishLaunchingNotification), perform: { _ in
            spotifyController.connect()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
