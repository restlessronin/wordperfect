//
//  ContentView.swift
//  Shared
//
//  Created by am on 6/4/21.
//

import SwiftUI

struct ContentView: View {
    @State var results: String = ""

    var body: some View {
        let game = Game()
        VStack {
            Button("Run Solver") {
                let words = game.solve()
                for i in 0..<words.count {
                    results += words[i] + "\n"
                }
            }
            let board = game.board.board
            let columns: [GridItem] =
                Array(repeating: .init(.flexible()), count: board.count)
            LazyVGrid(columns: columns) {
                ForEach((0..<board.count), id: \.self) {
                    Text(game.board.getLetterAt(BoardPosition($0,0)))
                    Text(game.board.getLetterAt(BoardPosition($0,1)))
                    Text(game.board.getLetterAt(BoardPosition($0,2)))
                    Text(game.board.getLetterAt(BoardPosition($0,3)))
                }
            }
            ScrollView {
                Text(results)
            }
        }

    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
