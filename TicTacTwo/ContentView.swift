import SwiftUI

struct MenuView: View {
    @State private var sessionNames: [String] = GameModel.getAllSessions()
    @State private var newGame = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Game Sessions")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                    .foregroundColor(Color.purple)

                if sessionNames.isEmpty {
                    Text("No saved sessions yet.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List {
                        ForEach(sessionNames, id: \.self) { sessionName in
                            NavigationLink(destination: {
                                if let gameModel = GameModel.loadSession(name: sessionName) {
                                    GameView(gameModel: gameModel)
                                        .onDisappear {
                                            refreshSessionList()
                                        }
                                } else {
                                    Text("Failed to load session: \(sessionName)")
                                        .foregroundColor(.red)
                                        .font(.headline)
                                }
                            }) {
                                Text(sessionName)
                                    .foregroundColor(Color.blue)
                            }
                        }
                        .onDelete(perform: deleteSession)
                    }
                    .listStyle(.plain)
                    .background(Color.purple.opacity(0.1))
                }

                Spacer()

                Button(action: {
                    newGame = true
                }) {
                    Text("New Game")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.pink)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
            .background(Color.purple.opacity(0.05))
            .navigationDestination(isPresented: $newGame) {
                GameView(gameModel: GameModel())
                    .onDisappear {
                        refreshSessionList()
                    }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                        .foregroundColor(Color.green)
                }
            }
        }
        .onAppear {
            refreshSessionList()
        }
    }

    private func refreshSessionList() {
        sessionNames = GameModel.getAllSessions()
    }

    private func deleteSession(at offsets: IndexSet) {
        for index in offsets {
            let sessionName = sessionNames[index]
            GameModel.deleteSession(name: sessionName)
        }
        refreshSessionList()
    }
}
