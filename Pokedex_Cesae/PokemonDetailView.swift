import SwiftUI

struct PokemonDetailView: View {
    var pokemon: Pokemon
    @State private var commentText: String = ""
    @State private var comments: [String] = []
    private let commentsKey: String
    @Binding var favoritos: Set<Int> // Binding para favoritos
    
    init(pokemon: Pokemon, favoritos: Binding<Set<Int>>) {
        self.pokemon = pokemon
        self.commentsKey = "comments_\(pokemon.id)"
        self._favoritos = favoritos // Iniciando o binding de favoritos
    }
    
    var body: some View {
        ScrollView { // Utilizando ScrollView para rolagem de conteúdo
            VStack(spacing: 20) {
                // Exibir a imagem do Pokémon
                VStack {
                    if let imageURL = URL(string: pokemon.sprites.front_default) {
                        AsyncImage(url: imageURL) { image in
                            image.resizable()
                                 .scaledToFit()
                                 .frame(width: 200, height: 200) // Tamanho maior para a imagem
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    
                    // Nome do Pokémon centralizado com ícone de coração ao lado
                    HStack {
                        Spacer() // Isso empurra o nome para o centro
                        Text(pokemon.name.capitalized)
                            .font(.largeTitle)
                            .bold()
                            .padding(.top, 10)
                        Spacer() // Isso empurra o ícone de coração para o lado direito
                        
                        // Botão de Favorito
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
                                .padding(.top, 10) // Alinhando o ícone ao nome
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Exibir Tipos do Pokémon com cores personalizadas
                VStack(alignment: .leading) {
                    Text("Tipos:")
                        .font(.headline)
                    HStack {
                        ForEach(pokemon.types, id: \.type.name) { typeEntry in
                            Text(typeEntry.type.name.capitalized)
                                .padding(8)
                                .background(typeColor(type: typeEntry.type.name))
                                .foregroundColor(.black)
                                .cornerRadius(8)
                        }
                    }
                }
                
                // Exibir informações adicionais
                VStack(alignment: .leading) {
                    Text("Detalhes:")
                        .font(.headline)
                    HStack {
                        Text("Altura: \(pokemon.height) m")
                        Spacer()
                        Text("Peso: \(pokemon.weight) kg")
                    }
                    .padding(.bottom, 5)
                    
                    Text("Habilidades:")
                        .font(.headline)
                    ForEach(pokemon.abilities, id: \.ability.name) { abilityEntry in
                        Text(abilityEntry.ability.name.capitalized)
                            .padding(5)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(5)
                    }
                }
                
                // Adicionar Comentários
                VStack(alignment: .leading) {
                    Text("Adicionar Comentário:")
                        .font(.headline)
                        .padding(.top)
                    
                    TextField("Digite seu comentário aqui", text: $commentText)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.bottom)
                    
                    Button(action: {
                        if !commentText.isEmpty {
                            comments.append(commentText)
                            saveComments()
                            commentText = ""
                        }
                    }) {
                        Text("Adicionar Comentário")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                    // Exibir os comentários
                    VStack(alignment: .leading) {
                        Text("Comentários:")
                            .font(.headline)
                            .padding(.top)
                        
                        ForEach(comments, id: \.self) { comment in
                            Text("- \(comment)")
                                .padding(.top, 5)
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
    
    // Função para carregar os comentários do UserDefaults
    func loadComments() {
        if let savedComments = UserDefaults.standard.array(forKey: commentsKey) as? [String] {
            comments = savedComments
        }
    }
    
    // Função para salvar os comentários no UserDefaults
    func saveComments() {
        UserDefaults.standard.set(comments, forKey: commentsKey)
    }
    
    // Função para determinar a cor de fundo do tipo
    func typeColor(type: String) -> Color {
        switch type {
        case "fire": return Color.red
        case "water": return Color.blue
        case "grass": return Color.green
        case "electric": return Color.yellow
        case "psychic": return Color.purple
        case "bug": return Color.green.opacity(0.6)
        case "normal": return Color.gray
        case "ghost": return Color.purple.opacity(0.6)
        case "rock": return Color.gray.opacity(0.4)
        case "steel": return Color.blue.opacity(0.3)
        // Adicione outros tipos conforme necessário
        default: return Color.gray.opacity(0.2)
        }
    }
}

