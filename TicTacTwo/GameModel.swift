import Foundation

class GameModel: ObservableObject, Codable {
    
    @Published var totalMoves: Int = 0
    // A 1D array (size 25) to represent the grid. Each cell can be "X", "O", or ""
    @Published var board: [String] = Array(repeating: "", count: 25)
    
    // Track the current player
    @Published var currentPlayer: String = "❌"

    // Number of pieces outside of the field remaining for each player
    @Published var piecesRemaining: [String: Int] = ["❌": 4, "⭕": 4]
    
    @Published private var gridOffset: Int = 0
    
    // Check if a move is valid
    func isValidMove(index: Int) -> Bool {
        return board[index] == "" && getActiveIndices().contains(index)
    }
    
    // Make a move by placing the current player's symbol
    func makeMove(index: Int) {
        if isValidMove(index: index) {
            board[index] = currentPlayer
            print("board index: \(board[index])")
        }
    }
    
    func checkWinner() -> String? {
        let activeIndices = getActiveIndices()
        
        // Check horizontal lines (3 pieces in the same row)
        for row in 0..<3 {
            let index1 = activeIndices[row * 3]
            let index2 = activeIndices[row * 3 + 1]
            let index3 = activeIndices[row * 3 + 2]
            if board[index1] == board[index2], board[index1] == board[index3], board[index1] != "" {
                return board[index1] // Return the player symbol (either "❌" or "⭕")
            }
        }

        // Check vertical lines (3 pieces in the same column)
        for col in 0..<3 {
            let index1 = activeIndices[col]
            let index2 = activeIndices[col + 3]
            let index3 = activeIndices[col + 6]
            if board[index1] == board[index2], board[index1] == board[index3], board[index1] != "" {
                return board[index1]
            }
        }

        // Check diagonal (top-left to bottom-right)
        let index1 = activeIndices[0]
        let index2 = activeIndices[4]
        let index3 = activeIndices[8]
        if board[index1] == board[index2], board[index1] == board[index3], board[index1] != "" {
            return board[index1]
        }

        // Check diagonal (top-right to bottom-left)
        let index4 = activeIndices[2]
        let index5 = activeIndices[4]
        let index6 = activeIndices[6]
        if board[index4] == board[index5], board[index4] == board[index6], board[index4] != "" {
            return board[index4]
        }

        // No winner yet
        return nil
    }
    
    func getActiveIndices() -> [Int] {
        // Offset shifts the starting position of the 3x3 grid
        return [
            gridOffset + 6, gridOffset + 7, gridOffset + 8,
            gridOffset + 11, gridOffset + 12, gridOffset + 13,
            gridOffset + 16, gridOffset + 17, gridOffset + 18
        ]
    }
    
    func moveGrid(direction: String) {
        // Calculate active indices to check for boundary overflow/underflow
        let activeIndices = getActiveIndices()

        switch direction {
        case "up":
            if activeIndices.min()! - 5 >= 0 {
                gridOffset -= 5
            }
        case "down":
            if activeIndices.max()! + 5 <= 24 {
                gridOffset += 5
            }
        case "left":
            if activeIndices.allSatisfy({ $0 % 5 > 0 }) {
                gridOffset -= 1
            }
        case "right":
            if activeIndices.allSatisfy({ $0 % 5 < 4 }) {
                gridOffset += 1
            }
        case "upLeft":
            if activeIndices.min()! - 5 >= 0 && activeIndices.allSatisfy({ $0 % 5 > 0 }) {
                gridOffset -= 6
            }
        case "upRight":
            if activeIndices.min()! - 5 >= 0 && activeIndices.allSatisfy({ $0 % 5 < 4 }) {
                gridOffset -= 4
            }
        case "downLeft":
            if activeIndices.max()! + 5 <= 24 && activeIndices.allSatisfy({ $0 % 5 > 0 }) {
                gridOffset += 4
            }
        case "downRight":
            if activeIndices.max()! + 5 <= 24 && activeIndices.allSatisfy({ $0 % 5 < 4 }) {
                gridOffset += 6
            }
        default:
            break
        }
    }
    
    // Custom coding keys to map property names for encoding/decoding
    enum CodingKeys: String, CodingKey {
        case totalMoves
        case board
        case currentPlayer
        case piecesRemaining
        case gridOffset
    }

    // Encoding function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(totalMoves, forKey: .totalMoves)
        try container.encode(board, forKey: .board)
        try container.encode(currentPlayer, forKey: .currentPlayer)
        try container.encode(piecesRemaining, forKey: .piecesRemaining)
        try container.encode(gridOffset, forKey: .gridOffset)
    }

    // Decoding initializer
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalMoves = try container.decode(Int.self, forKey: .totalMoves)
        board = try container.decode([String].self, forKey: .board)
        currentPlayer = try container.decode(String.self, forKey: .currentPlayer)
        piecesRemaining = try container.decode([String: Int].self, forKey: .piecesRemaining)
        gridOffset = try container.decode(Int.self, forKey: .gridOffset)
    }

    init() { }
    
    func saveSession(name: String) {
        let sessionKey = "game_sessions"
        let encoder = JSONEncoder()
        if let encodedGame = try? encoder.encode(self) {
            var sessions = UserDefaults.standard.dictionary(forKey: sessionKey) ?? [:]
            sessions[name] = encodedGame
            UserDefaults.standard.set(sessions, forKey: sessionKey)
        }
    }

    static func loadSession(name: String) -> GameModel? {
        let sessionKey = "game_sessions"
        let decoder = JSONDecoder()
        if let sessions = UserDefaults.standard.dictionary(forKey: sessionKey),
           let encodedGame = sessions[name] as? Data {
            return try? decoder.decode(GameModel.self, from: encodedGame)
        }
        return nil
    }

    static func getAllSessions() -> [String] {
        let sessionKey = "game_sessions"
        if let sessions = UserDefaults.standard.dictionary(forKey: sessionKey) {
            return Array(sessions.keys)
        }
        return []
    }

    static func deleteSession(name: String) {
        let sessionKey = "game_sessions"
        var sessions = UserDefaults.standard.dictionary(forKey: sessionKey) ?? [:]
        sessions.removeValue(forKey: name)
        UserDefaults.standard.set(sessions, forKey: sessionKey)
    }
}
