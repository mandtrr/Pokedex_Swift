import SwiftUI

struct PokemonDetailView: View {
    var pokemon: Pokemon
    @State private var commentText: String = ""
    @State private var comments: [String] = []
    private let commentsKey: String
    @Binding var favoritos: Set<Int>

    init(pokemon: Pokemon, favoritos: Binding<Set<Int>>) {
        self.pokemon = pokemon
        self.commentsKey = "comments_\(pokemon.id)"
        self._favoritos = favoritos
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Card Principal
                ZStack {
                    // Fundo do card
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    typeColor(type: pokemon.types.first?.type.name ?? "").opacity(0.2),
                                    Color.white
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(typeColor(type: pokemon.types.first?.type.name ?? ""), lineWidth: 2)
                        )
                        .shadow(color: typeColor(type: pokemon.types.first?.type.name ?? "").opacity(0.4), radius: 10, x: 0, y: 5)

                    // Imagem do Pokémon, Nome e Tipos - Centralizados
                    VStack(spacing: 16) {
                        // Imagem do Pokémon
                        if let imageURL = URL(string: pokemon.sprites.front_default) {
                            AsyncImage(url: imageURL) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .background(Circle().fill(Color.white))
                                    .shadow(radius: 8)
                            } placeholder: {
                                ProgressView()
                            }
                        }

                        // Nome do Pokémon
                        Text(pokemon.name.capitalized)
                            .font(.system(size: 35, weight: .bold, design: .rounded))
                            .foregroundColor(typeColor(type: pokemon.types.first?.type.name ?? "").opacity(0.8))
                            .multilineTextAlignment(.center)

                        // Tipos do Pokémon
                        HStack(spacing: 10) {
                            ForEach(pokemon.types, id: \.type.name) { typeEntry in
                                Text(typeEntry.type.name.capitalized)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                typeColor(type: typeEntry.type.name).opacity(0.8),
                                                typeColor(type: typeEntry.type.name)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                                    .shadow(radius: 4)
                            }
                        }
                    }
                    .padding()
                    
                    // Coração no canto superior direito
                    HStack {
                        Spacer()
                        Button(action: {
                            if favoritos.contains(pokemon.id) {
                                favoritos.remove(pokemon.id)
                            } else {
                                favoritos.insert(pokemon.id)
                            }
                        }) {
                            Image(systemName: favoritos.contains(pokemon.id) ? "heart.fill" : "heart")
                                .foregroundColor(favoritos.contains(pokemon.id) ? .red : .gray)
                                .font(.title)
                                .padding()
                        }
                    }
                    .padding(.top, 16)
                    .padding(.trailing, 16)
                }
                .padding(.horizontal)

                // Informações Detalhadas
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "ruler.fill")
                            .foregroundColor(.blue)
                        Text("Altura:")
                            .font(.headline)
                        Spacer()
                        Text("\(pokemon.height) m")
                            .font(.subheadline)
                    }

                    HStack {
                        Image(systemName: "scalemass.fill")
                            .foregroundColor(.green)
                        Text("Peso:")
                            .font(.headline)
                        Spacer()
                        Text("\(pokemon.weight) kg")
                            .font(.subheadline)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(.yellow)
                            Text("Habilidades:")
                                .font(.headline)
                        }
                        ForEach(pokemon.abilities, id: \.ability.name) { abilityEntry in
                            Text(abilityEntry.ability.name.capitalized)
                                .padding(8)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.gray.opacity(0.1))
                )
                .padding(.horizontal)

                // Adicionar Comentários
                VStack(alignment: .leading, spacing: 16) {
                    Text("Adicionar Comentário:")
                        .font(.headline)

                    HStack {
                        TextField("Digite seu comentário", text: $commentText)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                            .foregroundColor(.black)

                        Button(action: {
                            if !commentText.isEmpty {
                                comments.append(commentText)
                                saveComments()
                                commentText = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                    }

                    if !comments.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Comentários:")
                                .font(.headline)
                            ForEach(comments, id: \.self) { comment in
                                Text("- \(comment)")
                                    .font(.subheadline)
                                    .padding(8)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                            }
                        }
                    }
                }
                .padding()
            }
            .padding()
        }
        .navigationTitle("Detalhes de \(pokemon.name.capitalized)")
        .onAppear {
            loadComments()
        }
    }

    func typeColor(type: String) -> Color {
        switch type {
           case "fire":
               return Color.red // Vermelho para Fire
           case "water":
               return Color.blue // Azul para Water
           case "grass":
               return Color.green // Verde para Grass
           case "electric":
               return Color.yellow // Amarelo para Electric
           case "psychic":
               return Color.purple.opacity(0.8) // Roxo intenso para Psychic
           case "bug":
               return Color.green.opacity(0.7) // Verde claro/amarelado para Bug
           case "normal":
               return Color(red: 0.96, green: 0.87, blue: 0.7) // Beige para Normal (RGB)
           case "ghost":
               return Color.purple.opacity(0.6) // Roxo escuro para Ghost
           case "rock":
               return Color.brown.opacity(0.7) // Marrom para Rock
           case "steel":
               return Color.gray.opacity(0.9) // Cinza metálico para Steel
           default:
               return Color.gray.opacity(0.4) // Cinza mais neutro para outros
           }
       }

    func loadComments() {
        if let savedComments = UserDefaults.standard.array(forKey: commentsKey) as? [String] {
            comments = savedComments
        }
    }

    func saveComments() {
        UserDefaults.standard.set(comments, forKey: commentsKey)
    }
}

