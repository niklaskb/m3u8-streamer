import UIKit
import AVKit
import AVFoundation

class ViewController: AVPlayerViewController {
    
    let streams = [
        "https://svt1-b.akamaized.net/se/svt1/master.m3u8", // SVT 1
        "https://svt2-b.akamaized.net/se/svt2/master.m3u8", // SVT 2
        "https://svtb-b.akamaized.net/se/svtb/master.m3u8", // SVT Barnkanalen
        "https://svtk-b.akamaized.net/se/svtk/master.m3u8", // SVT Kunskapskanalen
    ]
    
    var stream = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showsPlaybackControls = false
        self.player = AVPlayer()
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: OperationQueue.main,
            using: { (_) in
                self.applicationDidEnterBackground();
        })
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: OperationQueue.main,
            using: { (_) in
                self.applicationDidBecomeActive();
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if (presses.first?.type == .upArrow) {
            stream = stream + 1
            stream = stream % streams.count
            playStream()
        } else if (presses.first?.type == .downArrow) {
            stream = stream - 1
            if stream < 0 {
                stream = streams.count + stream
            }
            playStream()
        }
        super.pressesBegan(presses, with: event)
    }
    
    private func applicationDidEnterBackground() {
        player!.pause()
    }
    
    private func applicationDidBecomeActive() {
        playStream()
    }
    
    private func playStream() {
        let url = streams[stream]
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            if let data = data,
                let contents = String(data: data, encoding: String.Encoding.utf8) {
                contents.enumerateLines { line, _ in
                    if line.range(of: "/hls-v6/v6.m3u8") != nil {
                        let streamUrl = url.replacingOccurrences(of: "master.m3u8", with: line)
                        self.player!.replaceCurrentItem(with: AVPlayerItem(url: URL(string: streamUrl)!))
                        self.player!.play()
                    }
                }
            }
        }
        task.resume()
    }
}
