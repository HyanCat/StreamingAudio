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
              url: URL(string: "http://picosong.com/media/songs/4dd2f031e35a1f300e28463a637d822e.mp3")!),
        Audio(name: "锦鲤抄",
              url: URL(string: "http://picosong.com/media/songs/3ebb1d65be74c3481c16976ee0768e6c.mp3")!),
        Audio(name: "琴师",
              url: URL(string: "http://picosong.com/media/songs/3ebb1d65be74c3481c16976ee0768e6c.mp3")!),
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
