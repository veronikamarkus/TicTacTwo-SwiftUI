import SwiftUI

struct GameView: View {
    @ObservedObject var gameModel: GameModel = GameModel()
    
    @State private var movePieceEnabled: Bool = false
    @State private var moveGridEnabled: Bool = false
    @State private var initialPieceTapped: Bool = false
    @State private var gridPieceTapped: Bool = false
    
    @State private var showSaveDialog: Bool = false
    @State private var sessionName: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            if isLandscape {
                ZStack {
                    Color.purple.opacity(0.1)
                        .edgesIgnoringSafeArea(.all)
                    HStack(spacing: 8) {
                        VStack {
                            Spacer()
                            gameGrid(geometry: geometry)
                                .padding(.top, 0)
                                .frame(width: geometry.size.width * 0.5)
                            Spacer()
                        }
                        .padding(.top, 0)
                        .padding(.vertical, 8)
                    
                        VStack(spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Active Player: \(gameModel.currentPlayer)")
                                        .font(.headline)
                                        .foregroundColor(.purple)
                                    Text("Moves Count: \(gameModel.totalMoves)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Button(action: {
                                    showSaveDialog = true
                                }) {
                                    Text("Save")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                        .padding(10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.green, lineWidth: 2)
                                        )
                                        .shadow(radius: 5)
                                }
                            }
                            .padding(.horizontal, 8)
                            
                            
                            // Move Buttons
                            HStack(spacing: 8) {
                                moveButton("Move Piece", isEnabled: !movePieceEnabled) {
                                    movePieceEnabled = true
                                    moveGridEnabled = false
                                    initialPieceTapped = false
                                }
                                moveButton("Move Grid", isEnabled: !moveGridEnabled && !initialPieceTapped && !gridPieceTapped && gameModel.totalMoves >= 4) {
                                    moveGridEnabled = true
                                    movePieceEnabled = false
                                }
                            }
                            
                            // X and O Pieces Section
                            VStack(spacing: 4) {
                                pieceButtonRow(piece: "❌")
                                pieceButtonRow(piece: "⭕")
                            }
                            
                            // Direction Buttons
                            directionButtons()
                                .frame(maxWidth: .infinity)
                        }
                        .padding(8)
                        .sheet(isPresented: $showSaveDialog) {
                                    SaveSessionDialog(
                                        sessionName: $sessionName,
                                        onSave: { name in
                                            gameModel.saveSession(name: name)
                                            print("Session \(name) saved!")
                                            showSaveDialog = false
                                        },
                                        onCancel: {
                                            showSaveDialog = false
                                        }
                                    )
                                }
                   
                    }
                }

            } else {
                ZStack {
                    Color.purple.opacity(0.1)
                        .edgesIgnoringSafeArea(.all)
                    VStack(spacing: 6) {
                        // Top Panel
                        HStack {
                            VStack(alignment: .leading, spacing: 4) { // Compact spacing
                                Text("Active Player: \(gameModel.currentPlayer)")
                                    .font(.headline)
                                    .foregroundColor(.purple)
                                Text("Moves Count: \(gameModel.totalMoves)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: {
                                showSaveDialog = true
                            }) {
                                Text("Save")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .frame(height: 7)
                                    .padding()
                                    .background(Color.clear)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.green, lineWidth: 2)
                                    )
                            }
                        }
                        .padding(.horizontal, 8)
                        
                        
                        // Game Grid
                        gameGrid(geometry: geometry).padding(.horizontal, 20)
                        
                        // Move Buttons
                        HStack(spacing: 8) {
                            moveButton("Move Piece", isEnabled: !movePieceEnabled) {
                                movePieceEnabled = true
                                moveGridEnabled = false
                                initialPieceTapped = false
                            }
                            moveButton("Move Grid", isEnabled: !moveGridEnabled && !initialPieceTapped && !gridPieceTapped && gameModel.totalMoves >= 4) {
                                moveGridEnabled = true
                                movePieceEnabled = false
                            }
                        }
                        
                        // X and O Pieces Section
                        VStack(spacing: 4) {
                            pieceButtonRow(piece: "❌")
                            pieceButtonRow(piece: "⭕")
                        }
                        
                        // Direction Buttons
                        directionButtons()
                            .frame(maxWidth: .infinity)
                    }
                    .padding(8)
                    
                    .sheet(isPresented: $showSaveDialog) {
                        SaveSessionDialog(
                            sessionName: $sessionName,
                            onSave: { name in
                                gameModel.saveSession(name: name)
                                print("Session \(name) saved!")
                                showSaveDialog = false
                            },
                            onCancel: {
                                showSaveDialog = false
                            }
                        )
                    }
                    
                }
            }
        }
    }
    
    private func gameGrid(geometry: GeometryProxy) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 6) {
            ForEach(0..<25, id: \.self) { index in
                Button(action: {
                    handleGridButtonTapped(index)
                }) {
                    Text(gameModel.board[index])
                        .frame(width: geometry.size.width / (geometry.size.width > geometry.size.height ? 12 : 7), height: geometry.size.width / (geometry.size.width > geometry.size.height ? 12 : 7)) // Adjust size dynamically
                        .background(gameModel.getActiveIndices().contains(index) ? Color.yellow.opacity(0.3) : Color.white)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black, lineWidth: 1))
                }
                .disabled(movePieceEnabled ? (!initialPieceTapped ? (
                                        gridPieceTapped ? gameModel.board[index] != "" || !gameModel.getActiveIndices().contains(index) : gameModel.board[index] != gameModel.currentPlayer)
                                              : !gameModel.getActiveIndices().contains(index) || gameModel.board[index] != ""
                                    ) : true)
            }
        }
    }
    
    private func moveButton(_ title: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            Text(title)
                .padding(6)
                .background(isEnabled ? Color.purple : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(6)
                .shadow(radius: 3)
        }
        .disabled(!isEnabled)
    }
    
    private func directionButtons() -> some View {
        VStack(spacing: 4) {
            LazyHGrid(rows: [GridItem(.flexible())], spacing: 4) {
                directionButton("↖️", action: { handleMove("upLeft") })
                directionButton("⬆️", action: { handleMove("up") })
                directionButton("↗️", action: { handleMove("upRight") })
            }.frame(height: 38)
            
            LazyHGrid(rows: [GridItem(.flexible())], spacing: 4) {
                directionButton("⬅️", action: { handleMove("left") })
                directionButton("", action: {}).disabled(true)
                directionButton("➡️", action: { handleMove("right") })
            }.frame(height: 38)
            
            LazyHGrid(rows: [GridItem(.flexible())], spacing: 4) {
                directionButton("↙️", action: { handleMove("downLeft") })
                directionButton("⬇️", action: { handleMove("down") })
                directionButton("↘️", action: { handleMove("downRight") })
            }.frame(height: 38)
        }
    }
    
    private func directionButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(symbol) {
            action()
        }
        .frame(width: 38, height: 38)
        .background(Color.purple.opacity(0.1))
        .cornerRadius(6)
    }
    
    private func handleGridButtonTapped(_ index: Int) {
        if movePieceEnabled && !initialPieceTapped && !gridPieceTapped {
            gridPieceTapped = true
            gameModel.board[index] = ""
        } else {
            if gameModel.isValidMove(index: index) {
                gameModel.makeMove(index: index)
                gridPieceTapped = false
                nextTurn()
                if let winner = gameModel.checkWinner() {
                    showWinner(winner)
                }
            }
        }
    }
    
    private func handleMove(_ direction: String) {
        gameModel.moveGrid(direction: direction)
        nextTurn()
        if let winner = gameModel.checkWinner() {
            showWinner(winner)
        }
    }
    
    private func nextTurn() {
        gameModel.totalMoves += 1
        movePieceEnabled = false
        moveGridEnabled = false
        gameModel.currentPlayer = gameModel.currentPlayer == "❌" ? "⭕" : "❌"
    }
    
    private func showWinner(_ winner: String) {
        print("\(winner) wins!")
    }
    
    func pieceButtonRow(piece: String) -> some View {
        HStack(spacing: 4) {
            ForEach(1...4, id: \.self) { count in
                Button(action: {
                    pieceButtonTapped(piece: piece, count: count)
                }) {
                    Text(piece)
                        .padding(6)
                        .background(gameModel.piecesRemaining[piece]! == count
                                    && gameModel.currentPlayer == piece
                                    && movePieceEnabled == true
                                    && !initialPieceTapped
                                    && !gridPieceTapped ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                .disabled(gameModel.piecesRemaining[piece]! != count
                          || movePieceEnabled == false
                          || gameModel.currentPlayer != piece
                          || initialPieceTapped
                          || gridPieceTapped)
                .opacity(gameModel.piecesRemaining[piece]! >= count ? 1 : 0)
            }
        }
    }
    
    func pieceButtonTapped(piece: String, count: Int) {
        initialPieceTapped = true
        gameModel.piecesRemaining[piece]! -= 1
    }

}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}

struct SaveSessionDialog: View {
    @Binding var sessionName: String
    let onSave: (String) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Session Name")
                .font(.headline)

            TextField("Session Name", text: $sessionName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            HStack {
                Button(action: {
                    onCancel()
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding(10)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(8)
                }

                Spacer()

                Button(action: {
                    if !sessionName.isEmpty {
                        onSave(sessionName)
                    }
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding(10)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .presentationDetents([.medium])
    }
}
