//
//  PlayerViewController.swift
//  MusicPlayer
//
//  Created by Alexander Korchak on 27.05.2023.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import AVFoundation

class PlayerViewController: UIViewController {
    
    var trackName: BehaviorRelay = BehaviorRelay<String>(value: "")
    var bandName: BehaviorRelay = BehaviorRelay<String>(value: "")
    public var position: BehaviorRelay = BehaviorRelay<Int>(value: 0)
    private let disposeBag = DisposeBag()
    let viewModel = MainViewModel()
  
    public var tracks: [Track] = []

    var timeObserverToken: Any?
    fileprivate let seekDuration: Float64 = 10

    private lazy var trackNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.theme.accent
        label.backgroundColor = UIColor.theme.background
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        return label
    }()
    
    private lazy var bandNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.theme.accent
        label.backgroundColor = UIColor.theme.background
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(playPause), for: .touchUpInside)
        button.setBackgroundImage(UIImage(systemName: "pause"), for: .normal)
        return button
    }()
    
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.theme.accent
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    private lazy var totalTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.theme.accent
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(goToNext), for: .touchUpInside)
        button.setBackgroundImage(UIImage(systemName: "forward.end"), for: .normal)
        
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        button.setBackgroundImage(UIImage(systemName: "backward.end"), for: .normal)
        return button
    }()
    
    private lazy var player: AVPlayer = {
        let player = AVPlayer()
        return player
    }()
    
    private lazy var playbackSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.addTarget(self, action: #selector(playbackSliderValueChanged(_:)), for: .valueChanged)
        return slider
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.theme.background
        setupUI()
        bindElements()
        Task {
           await configurePlayer()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
    }

    private func setupUI() {
    
        view.addSubviews([
            trackNameLabel,
            bandNameLabel,
            playbackSlider,
            playPauseButton,
            nextButton,
            backButton,
            currentTimeLabel,
            totalTimeLabel
        ])
        
        trackNameLabel.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(400)
            make.centerX.equalToSuperview()
            make.height.equalTo(23)
        }
        
        bandNameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(trackNameLabel.snp.bottom).offset(12)
            make.height.equalTo(20)
        }
        
        playbackSlider.snp.makeConstraints { make in
            make.top.equalTo(bandNameLabel.snp.bottom).offset(50)
            make.leading.equalTo(view.snp.leading).offset(16)
            make.trailing.equalTo(view.snp.trailing).offset(-16)
        }
        
        playPauseButton.snp.makeConstraints { make in
            make.top.equalTo(playbackSlider.snp.bottom).offset(50)
            make.centerX.equalTo(playbackSlider.snp.centerX)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(playbackSlider.snp.bottom).offset(50)
            make.leading.equalTo(playPauseButton.snp.trailing).offset(12)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(playbackSlider.snp.bottom).offset(50)
            make.trailing.equalTo(playPauseButton.snp.leading).offset(-12)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        
        currentTimeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(playbackSlider.snp.top).offset(-6)
            make.leading.equalTo(view.snp.leading).offset(16)
            make.height.equalTo(10)
        }
        
        totalTimeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(playbackSlider.snp.top).offset(-6)
            make.trailing.equalTo(view.snp.trailing).offset(-16)
            make.height.equalTo(10)
        }
    }

    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    @objc private func playPause() {
        if player.rate == 0 {
           player.play()
           playPauseButton.setBackgroundImage(UIImage(systemName: "pause"), for: .normal)
         } else {
           player.pause()
           playPauseButton.setBackgroundImage(UIImage(systemName: "play"), for: .normal)
         }
    }
    
    @objc private func goToNext() {
        
        if position.value == tracks.count - 1 {
            position.accept(tracks.startIndex - 1)
        }
        
        if position.value < (tracks.count - 1) {
            position.accept(position.value + 1)
            Task {
               await configurePlayer()
            }
        }
    }
    
    @objc private func goBack() {
        
        if position.value == tracks.startIndex {
            position.accept(tracks.count)
        }
        
        if position.value > 0 {
            position.accept(position.value - 1)
            Task {
               await configurePlayer()
            }
        }
    }
    
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider) {
          let seconds : Int64 = Int64(playbackSlider.value)
           let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
           player.seek(to: targetTime)
       }

    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func configurePlayer() async {
        
        let track = tracks[position.value]
        
        bandNameLabel.text = tracks[position.value].bandName
        trackNameLabel.text = tracks[position.value].trackName.replacingOccurrences(of: "-", with: " ").capitalized
        playPauseButton.setBackgroundImage(UIImage(systemName: "pause"), for: .normal)
        
        guard let path = Bundle.main.path(forResource: track.trackName, ofType: "mp3") else {
                    debugPrint("audio.mp3 not found")
                    return
                }
        
        let playerItem: AVPlayerItem = AVPlayerItem(url: URL(fileURLWithPath: path))
        player = AVPlayer(playerItem: playerItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)
   
        do {
            let totalDuration: CMTime =  try await playerItem.asset.load(.duration)
            let seconds: Float64 = CMTimeGetSeconds(totalDuration)
            totalTimeLabel.text = stringFromTimeInterval(interval: seconds)

            let currentDuration: CMTime =  player.currentTime()
            let currentSeconds: Float64 = CMTimeGetSeconds(currentDuration)
            currentTimeLabel.text = stringFromTimeInterval(interval: currentSeconds)
            player.play()
            
            playbackSlider.maximumValue = Float(seconds)
            playbackSlider.isContinuous = true
            
            player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1),
                                           queue: DispatchQueue.main) { (CMTime) -> Void in
                if self.player.currentItem?.status == .readyToPlay {
                    let time : Float64 = CMTimeGetSeconds(self.player.currentTime())
                    self.playbackSlider.value = Float(time)
                    
                    self.currentTimeLabel.text = self.stringFromTimeInterval(interval: time)
                }
            }
       
        } catch let error  {
            print(error)
        }
    }
    
    @objc func finishedPlaying( _ myNotification: NSNotification) {
   
        Task {
            if position.value == tracks.count - 1 {
                position.accept(tracks.startIndex - 1)
            }
            
            position.accept(position.value + 1)
               await configurePlayer()
        }
    }
    
    private func bindElements() {
        trackName.bind(to: trackNameLabel
            .rx
            .text)
        .disposed(by: disposeBag)
        
        bandName.bind(to: bandNameLabel
            .rx
            .text)
        .disposed(by: disposeBag)
        
        viewModel.tracks
            .subscribe { [weak self] tracks in
            self?.tracks = tracks
        }
        .disposed(by: disposeBag)
    }
}

