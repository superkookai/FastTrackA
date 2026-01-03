//
//  TrackView.swift
//  FastTrackA
//
//  Created by Weerawut on 3/1/2569 BE.
//

import SwiftUI

struct TrackView: View {
    let track: Track
    let onSelected: (Track) -> Void
    
    @State private var isHovering: Bool = false
    
    var body: some View {
        Button {
            onSelected(track)
        } label: {
            ZStack(alignment: .bottom) {
                AsyncImage(url: track.artworkURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable()
                    case .failure:
                        Image(systemName: "questionmark")
                            .symbolVariant(.circle)
                            .font(.largeTitle)
                    default:
                        ProgressView()
                    }
                }
                .frame(width: 150, height: 150)
                .scaleEffect(isHovering ? 1.2 : 1.0)

                VStack {
                    Text(track.trackName)
                        .font(.headline)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                    
                    Text(track.artistName)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                }
                .padding(5)
                .frame(width: 150)
                .background(.regularMaterial)
            }
            .clipShape(.rect(cornerRadius: 10))
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.red, lineWidth: isHovering ? 5.0 : 0)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation {
                isHovering = hovering
            }
        }
    }
}

#Preview {
    TrackView(
        track: Track(
            trackId: 1440783625,
            artistName: "Nirvana",
            trackName: "Smells Like Teen Spirit",
            previewUrl: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview125/v4/a6/53/1e/a6531efa-397c-eb73-ecab-9b2790c1471e/mzaf_16440344883389407474.plus.aac.p.m4a")!,
            artworkUrl100: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/95/fd/b9/95fdb9b2-6d2b-92a6-97f2-51c1a6d77f1a/00602527874609.rgb.jpg/100x100bb.jpg"
        ), onSelected: { _ in }
    )
    .padding(50)
}
