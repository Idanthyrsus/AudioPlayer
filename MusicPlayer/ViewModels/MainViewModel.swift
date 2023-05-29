//
//  MainViewModel.swift
//  MusicPlayer
//
//  Created by Alexander Korchak on 27.05.2023.
//

import Foundation
import RxSwift

class MainViewModel {
    
    var tracks = Observable<[Track]>.of(
        [
            Track(bandName: "Metallica", trackName: "the-unforgiven", time: "6:27"),
            Track(bandName: "King Crimson", trackName: "thela-hun-ginjeet", time: "6:26"),
            Track(bandName: "Van Der Graaf Generator", trackName: "darkness", time: "7:17"),
            Track(bandName: "Radiohead", trackName: "karma-police", time: "4:24")
        ]
    )
}
