import SwiftUI

struct ContentView: View {
    @State private var pokemonList: [Pokemon] = []
    @State private var filteredPokemonList: [Pokemon] = []
    @State private var isLoading = true
    @State private var favoritos: Set<Int> = Set()
    @State private var selectedType: String = "Todos"
    @State private var mostrarFavoritos: Bool = false
    @State private var hoveredPokemonID: Int? = nil // Para armazenar o ID do Pokémon sobre o qual o mouse está
    let tiposDisponiveis = ["Todos", "fire", "water", "grass", "electric", "psychic", "ghost", "bug", "normal"]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Título
                Text("Pokédex")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 2)
                    .padding(.top, 20)

                // Filtros
                HStack {
                    // Filtro por Tipo
                    Menu {
                        ForEach(tiposDisponiveis, id: \.self) { tipo in
                            Button(tipo.capitalized) {
                                selectedType = tipo
                                updateFilteredList()
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedType.capitalized)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                    }

                    // Toggle Favoritos
                    Toggle(isOn: $mostrarFavoritos) {
                        Text("Favoritos")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                .padding(.horizontal)

                // Botão Aplicar Filtros
                Button(action: {
                    updateFilteredList()
                }) {
                    Text("Aplicar Filtros")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue))
                }
                .padding(.horizontal)

                // Lista de Pokémon ou Loading
                if isLoading {
                    ProgressView("Carregando Pokémon...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .padding(.top, 50)
                } else {
                    ScrollView {
                        // Ajuste para 3 colunas
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ],
                            spacing: 16
                        ) {
                            ForEach(filteredPokemonList) { pokemon in
                                VStack {
                                    // Imagem do Pokémon
                                    NavigationLink(destination: PokemonDetailView(pokemon: pokemon, favoritos: $favoritos)) {
                                        if let imageURL = URL(string: pokemon.sprites.front_default) {
                                            AsyncImage(url: imageURL) { image in
                                                image.resizable()
                                                     .scaledToFit()
                                                     .frame(width: 90, height: 90)
                                                     .background(Circle().fill(Color.white))
                                                     .shadow(radius: 4)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                        }
                                    }

                                    VStack(alignment: .center, spacing: 4) {
                                        // Nome do Pokémon
                                        Text(pokemon.name.capitalized)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .frame(maxWidth: .infinity)
                                            .multilineTextAlignment(.center)

                                        // Tipos do Pokémon
                                        Text(pokemon.types.map { $0.type.name.capitalized }.joined(separator: ", "))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(backgroundColor(forType: pokemon.types.first?.type.name ?? ""))
                                )
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                .scaleEffect(hoveredPokemonID == pokemon.id ? 1.1 : 1)
                                .shadow(color: .black.opacity(hoveredPokemonID == pokemon.id ? 0.2 : 0.1), radius: hoveredPokemonID == pokemon.id ? 6 : 4, x: 0, y: 2)
                                .onHover { hovering in
                                    if hovering {
                                        hoveredPokemonID = pokemon.id
                                    } else {
                                        hoveredPokemonID = nil
                                    }
                                }
                                .animation(.easeInOut(duration: 0.2), value: hoveredPokemonID)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                ).edgesIgnoringSafeArea(.all)
            )
            .onAppear {
                PokemonAPI.shared.fetchPokemonList { pokemon in
                    self.pokemonList = pokemon
                    self.filteredPokemonList = pokemon
                    self.isLoading = false
                    updateFilteredList()
                }
            }
        }
    }

    func updateFilteredList() {
        filteredPokemonList = pokemonList.filter { pokemon in
            let matchesType = selectedType == "Todos" || pokemon.types.contains { $0.type.name == selectedType }
            let matchesFavorite = !mostrarFavoritos || favoritos.contains(pokemon.id)
            return matchesType && matchesFavorite
        }
        filteredPokemonList.sort { $0.name < $1.name }
    }

    private func backgroundColor(forType type: String) -> Color {
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
}
