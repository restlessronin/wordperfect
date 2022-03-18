//
//  Solver.swift
//  WordPerfect Solver
//
//  Created by am on 6/4/21.
//

import Foundation

func readDictionary() -> [String] {
    let contents = try! String(contentsOfFile: "/Users/am/Desktop/WordPerfect Solver/Shared/wordlists/twl06.txt")
    let strings = contents.split(whereSeparator: \.isNewline)
    var words = strings.map { s -> String in
        return String(s)
    }
    words.sort();
    return words;
}

func removeDuplicates(_ orig: [String])->[String] {
    var prev = ""
    var res: [String] = []
    for i in 0..<orig.count {
        let cur = orig[i]
        if (cur != prev) {
            res.append(cur)
            prev = cur
        }
    }
    return res
}

func binarySearchRange<T: Comparable>(_ a: [T], _ key: T, _ l: Int, _ h: Int) -> Int {
    var low = l
    var high = h
    while (low <= high) {
        let mid = low + (high - low) / 2
        let midVal = a[mid]
        if (midVal < key) {
            low = mid + 1
        } else if (key < midVal){
            high = mid - 1
        } else {
            return mid
        }
    }
    return -(low + 1)
}
func nextLetter(_ letter: String) -> String? {
    guard let uniCode = UnicodeScalar(letter) else {
        return nil
    }
    switch uniCode {
    case "A" ... "Z":
        return String(UnicodeScalar(uniCode.value + 1)!)
    case "a" ... "z":
        return String(UnicodeScalar(uniCode.value + 1)!)
    default:
            return nil
    }
}
struct WordList {
    let allwords: [String]
    let slice : Range<Int>
    init(_ w: [String], _ r: Range<Int>) {
        allwords = w
        slice = r
    }
    func isEmpty() -> Bool{
        return slice.isEmpty
    }
    func search(_ word: String) -> Int{
        return binarySearchRange(allwords, word, slice.lowerBound, slice.upperBound - 1)
    }
    func hasWord(_ word: String)-> Bool {
        let idx = search(word)
        return 0 <= idx;
    }
    func getWithPfx(_ pfx: String) -> WordList {
        let f = search(pfx)
        let first = f >= 0 ? f : -(f + 1)
        let finalL = String(pfx.last!)
        let nextL = nextLetter(finalL)
        let firstE: Int
        if (nextL != nil) {
            let pfxE = String(pfx[pfx.startIndex..<pfx.index(pfx.endIndex, offsetBy: -1)]) + nextL!
            let l = search(pfxE)
            firstE = l >= 0 ? l : -(l + 1);
        } else {
            firstE = slice.upperBound
        }
        return WordList(allwords, first ..< firstE)
    }
}
struct BoardPosition : Equatable {
    let x: Int
    let y: Int
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    func offset(_ o : BoardPosition) -> BoardPosition {
        return BoardPosition(x + o.x, y + o.y)
    }
    func isValid (_ max: Int)-> Bool {
        return 0 <= x && 0 <= y && x < max && y < max;
    }
}
func getSearchOrder () -> [BoardPosition]{
    var res:[BoardPosition] = []
    for x in -1...1 {
        for y in -1...1 {
            if ( !(x == 0 && y == 0) ) {
                res +=  [BoardPosition(x, y)]
            }
        }
    }
    return res;
}
struct Board {
    let board:[[String]] = [
        ["b","d","i","n"],
        ["i","a","d","r"],
        ["l","a","f","t"],
        ["p","o","o","p"],
    ]
    let searchOrder = getSearchOrder()
    func getLetterAt(_ pos: BoardPosition) -> String {
        return board[pos.x][pos.y]
    }
}
struct Game {
    let board = Board()
    let allWords: WordList
    init() {
        let allwords = readDictionary()
        allWords = WordList(allwords, 0..<allwords.count)
    }
    struct NextState {
        let position: BoardPosition
        let index: Int
        init(_ p: BoardPosition, _ i: Int) {
            position = p
            index = i
        }
    }
    struct CurrentState {
        let board: Board
        let currentPfx: [BoardPosition]
        let wordlist: WordList
        init(_ b:Board, _ pfx:[BoardPosition], _ wl: WordList) {
            board=b
            currentPfx = pfx
            wordlist = wl
        }
        func getWord()->String {
            var word: String = ""
            for i in 0 ..< currentPfx.count {
                word += board.getLetterAt(currentPfx[i]);
            }
            return word
        }
        func next(_ nxtI: Int) -> NextState? {
            for n in nxtI..<board.searchOrder.count {
                let offset = board.searchOrder[n];
                let currentPosition = currentPfx.last!
                let next = currentPosition.offset(offset)
                if ( !next.isValid(board.board.count)) {
                    continue
                }
                if ( currentPfx.contains(next) ) {
                    continue
                }
                return NextState(next, n)
            }
            return nil
        }
        func isWord() -> Bool {
            let word = getWord()
            return wordlist.hasWord(word)
        }
    }
    func findDFS(_ current: CurrentState) -> [String] {
        var res: [String] = []
        if (current.isWord()) {
            res.append(current.getWord())
        }
        var nextState = current.next(0)
        while ( nextState != nil ) {
            let pos = nextState!.position
            let pfx = current.getWord() + board.getLetterAt(pos)
            let slice = current.wordlist.getWithPfx(pfx)
            if (!slice.isEmpty()) {
                let posPfx = current.currentPfx + [pos]
                let c = CurrentState(board, posPfx, slice)
                res += findDFS(c)
            }
            nextState = current.next(nextState!.index + 1)
        }
        return res;
    }
    func solve() -> [String] {
        var res: [String] = []
        for i in 0..<board.board.count {
            for j in 0..<board.board.count {
                let pos = BoardPosition(i, j)
                let pfx = board.getLetterAt(pos)
                let initial = CurrentState(board, [pos],allWords.getWithPfx(pfx))
                res += findDFS(initial)
            }
        }
        res.sort();
        return removeDuplicates(res)
    }
}
