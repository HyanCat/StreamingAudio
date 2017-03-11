//
//  ViewController.swift
//  AudioDemo
//
//  Created by HyanCat on 22/01/2017.
//  Copyright © 2017 HyanCat. All rights reserved.
//

import UIKit
import StreamingKit
import iCheckbox
import StreamingAudio

class Music: Player {
}

class ViewController: UIViewController, iCheckboxDelegate, STKAudioPlayerDelegate {

    @IBOutlet weak var musicCheckboxPanel: UIView!
    @IBOutlet weak var noiseCheckboxPanel: UIView!

    @IBOutlet weak var musicPlayButton: UIButton!
    @IBOutlet weak var noisePlayButton: UIButton!

    @IBOutlet weak var musicSlider: UISlider!
    @IBOutlet weak var noiseSlider: UISlider!

    let musicPlayer: Music = Music()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addMusicCheckboxs()

        musicPlayButton.setTitle("Play", for: .normal)

        musicPlayer.appendFrequencyOutputName("111") { (rawPointer, count) in
//            let fs = Array(UnsafeBufferPointer(start: rawPointer, count: Int(count)))
//            print(fs)
        }
    }

    func didSelectCheckbox(withState state: Bool, identifier: Int, andTitle title: String) {
        print("Checkbox '\(title)', has selected state: \(state)")
    }

    @IBAction func musicPlayButtonTouched(_ sender: UIButton) {
        musicPlayer.play(Res.musics.last!.url)
    }

    @IBAction func musicSliderValueChanged(_ sender: UISlider) {
        print("Music slider value: \(sender.value)")
        musicPlayer.volume = sender.value
    }

    private func addMusicCheckboxs() {
        let checkboxBuilderConfig = iCheckboxBuilderConfig()
        checkboxBuilderConfig.headerTitle = "音乐"
        checkboxBuilderConfig.selection = .Multiple
        checkboxBuilderConfig.startPosition = CGPoint(x: 10, y: 10)

        var checkboxs: [iCheckboxState] = [iCheckboxState]()
        for music in Res.musics {
            let checkboxState = iCheckboxState()
            checkboxState.title = music.name
            checkboxs.append(checkboxState)
        }

        let checkboxBuilder = iCheckboxBuilder(withCanvas: self.musicCheckboxPanel, andConfig: checkboxBuilderConfig)
        checkboxBuilder.delegate = self
        checkboxBuilder.addCheckboxes(withStates: checkboxs)
    }

    private func addNoiseCheckboxs() {
        let checkboxBuilderConfig = iCheckboxBuilderConfig()
        checkboxBuilderConfig.headerTitle = "噪声"
        checkboxBuilderConfig.selection = .Multiple
        checkboxBuilderConfig.startPosition = CGPoint(x: 10, y: 10)

        var checkboxs: [iCheckboxState] = [iCheckboxState]()
        for music in Res.noises {
            let checkboxState = iCheckboxState()
            checkboxState.title = music.name
            checkboxs.append(checkboxState)
        }

        let checkboxBuilder = iCheckboxBuilder(withCanvas: self.noiseCheckboxPanel, andConfig: checkboxBuilderConfig)
        checkboxBuilder.delegate = self
        checkboxBuilder.addCheckboxes(withStates: checkboxs)
    }
}

