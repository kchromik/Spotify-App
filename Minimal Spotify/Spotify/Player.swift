import SpotifyiOS
import Combine

class Player: NSObject, ObservableObject  {

    var didChange = PassthroughSubject<Void, Never>()
    var spotifyController: SpotifyController

    @Published var playerState: SPTAppRemotePlayerState? { didSet { didChange.send() }}
    @Published var artworkImage: UIImage? { didSet { didChange.send() }}
    var durationString: String {
        get {
            guard let duration = playerState?.track.duration else { return ""}

            let minutes = Int(duration / 1000 / 60 )
            let seconds = String(format: "%02d", Int(duration / 1000 % 60))
            return "\(minutes):\(seconds)"
        }
    }
    var progressString: String {
        get {
            guard let progress = playerState?.playbackPosition else { return "" }

            let minutes = Int(progress / 1000 / 60 )
            let seconds = String(format: "%02d", Int(progress / 1000 % 60))
            return "\(minutes):\(seconds)"
        }
    }

    @Published var currentProgress: Float {
         didSet { didChange.send() }
    }

    var refreshTimer: Timer?

    var defaultCallback: SPTAppRemoteCallback {
        get {
            {[weak self] _, error in
                if let error = error {
                    print("Error: " + error.localizedDescription)
                }
                self?.updateState()
            }
        }
    }

    init(spotifyController: SpotifyController) {
        self.spotifyController = spotifyController

        self.currentProgress = 0
        super.init()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.updateState()
        }
        let timer = Timer(timeInterval: 1.0, target: self, selector: #selector(self.fireTimer), userInfo: [], repeats: true)
        self.refreshTimer = timer
        RunLoop.current.add(timer, forMode: .default)
        self.refreshTimer?.fire()
    }

    @objc func fireTimer() {
        guard let state = playerState, !state.isPaused else { return }

        currentProgress = Float(state.playbackPosition)
        updateState()
    }

    func skipToNext() {
        spotifyController.appRemote.playerAPI?.skip(toNext: defaultCallback)
    }

    func skipToPrevious() {
        spotifyController.appRemote.playerAPI?.skip(toPrevious: defaultCallback)
    }

    func pause() {
        spotifyController.appRemote.playerAPI?.pause(defaultCallback)
    }

    func resume() {
        spotifyController.appRemote.playerAPI?.resume(defaultCallback)
    }

    func updateState() {
        spotifyController.appRemote.playerAPI?.getPlayerState({ [weak self] state, _ in
            self?.playerState = state as? SPTAppRemotePlayerState
            self?.loadAlbumArt()
        })
    }

    func loadAlbumArt() {
        guard let track = playerState?.track else { return }

        spotifyController.appRemote.imageAPI?.fetchImage(forItem: track, with: .zero, callback: { [weak self] image, error in
            if let error = error {
                print("Error fetching track image: " + error.localizedDescription)
            } else if let image = image as? UIImage {
                self?.artworkImage = image
            }
        })
    }
}
