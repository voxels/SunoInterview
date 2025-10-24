//
//  InfoView.swift
//  SunoInterview
//
//  Created by Michael A Edgcumbe on 10/24/25.
//


import SwiftUI

struct InfoView : View {
    var clip:Clip
    
    var body: some View {
        VStack {
            Spacer()
            Text(clip.title)
                .font(.largeTitle)
            Text(clip.handle)
                .font(.title2)
        }
    }
}
