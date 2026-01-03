//
//  ContentView.swift
//  FastTrackA
//
//  Created by Weerawut on 3/1/2569 BE.
//

import SwiftUI
import AVKit

enum SearchState {
    case none, searching, success, error
}

struct ContentView: View {
    let gridItems: [GridItem] = [GridItem(.adaptive(minimum: 150, maximum: 200))]
    
    @AppStorage("searchText") var searchText: String = ""
    @State private var tracks: [Track] = []
    @State private var audioPlayer: AVPlayer?
    @State private var searchState: SearchState = .none
    
    @State private var selectedTrack: Track?
    @State private var searchTerms: [String] = []
    @State private var selectedSearchTerm: String?
    
    var body: some View {
        NavigationSplitView {
            List(searchTerms, id: \.self, selection: $selectedSearchTerm) { term in
                Text(term)
            }
            .onChange(of: selectedSearchTerm) { _, newValue in
                audioPlayer?.pause()
                if let newValue {
                    searchText = newValue
                    startSearch()
                }
            }
        } detail: {
            VStack {
                switch searchState {
                case .none:
                    ContentUnavailableView("Enter the search term to begin", systemImage: "magnifyingglass")
                        .frame(maxHeight: .infinity)
                case .searching:
                    ProgressView()
                        .frame(maxHeight: .infinity)
                case .success:
                    ScrollView {
                        LazyVGrid(columns: gridItems) {
                            ForEach(tracks) { track in
                                TrackView(track: track) { track in
                                    play(track)
                                    selectedTrack = track
                                }
                                .overlay {
                                    if let selectedTrack, selectedTrack == track {
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 50))
                                            .foregroundStyle(.regularMaterial)
                                            .symbolEffect(.bounce.up.byLayer, options: .repeat(.continuous))
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                case .error:
                    ContentUnavailableView("Sorry your search is failed! Please check your Internet and try again.", systemImage: "exclamationmark.triangle")
                        .frame(maxHeight: .infinity)
                }
            }
            .searchable(text: $searchText)
            .onSubmit(of: .search) {
                audioPlayer?.pause()
                searchTerms.append(searchText)
                startSearch()
            }
        }
        .navigationTitle("Fast Track")
    }
    
}

extension ContentView {
    func startSearch() {
        searchState = .searching
        Task {
            do {
                try await performSearch()
                searchState = .success
            } catch {
                searchState = .error
                print("DEBUG: Error Fetching: \(error.localizedDescription)")
            }
        }
    }
    
    func performSearch() async throws {
        guard let searchText = self.searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let url = URL(string: "https://itunes.apple.com/search?term=\(searchText)&limit=100&entity=song") else { return }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return }
        
        let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
        
        tracks = searchResult.results
    }
    
    func play(_ track: Track) {
        audioPlayer?.pause()
        audioPlayer = AVPlayer(url: track.previewUrl)
        audioPlayer?.play()
    }
}

#Preview {
    ContentView()
}
