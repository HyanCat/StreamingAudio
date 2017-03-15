//
//  Res.swift
//  AudioDemo
//
//  Created by HyanCat on 22/01/2017.
//  Copyright © 2017 HyanCat. All rights reserved.
//

import Foundation

struct Res {

    struct Audio {
        var name: String = ""
        var url: URL
    }

    static let musics: [Audio] = [
        Audio(name: "紫川录",
              url: URL(string: "http://picosong.com/media/songs/a320e9af1a9db7ff15f0ffcc3404c4c0.mp3")!),
        Audio(name: "锦鲤抄",
              url: URL(string: "http://picosong.com/media/songs/0fd216fc6e6c3984dd0ba65a20d07fb6.mp3")!),
        Audio(name: "琴师",
              url: URL(string: "http://picosong.com/media/songs/a320e9af1a9db7ff15f0ffcc3404c4c0.mp3")!),
    ]
    static let noises: [Audio] = [
        Audio(name: "🐩叫",
              url: Bundle.main.url(forResource: "dog", withExtension: "mp3")!),
        Audio(name: "🐦叫",
              url: Bundle.main.url(forResource: "rooster", withExtension: "mp3")!),
        Audio(name: "🐷叫",
              url: Bundle.main.url(forResource: "pig", withExtension: "mp3")!),
    ]
}
