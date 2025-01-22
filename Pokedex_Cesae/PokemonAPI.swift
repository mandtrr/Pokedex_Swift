//
//  PokemonAPI.swift
//  Pokedex_Cesae
//
//  Created by MultiLab on 20/01/2025.
//
import Foundation

class PokemonAPI {
    static let shared = PokemonAPI()
    private let baseURL = "https://pokeapi.co/api/v2/"
    
    // Função para buscar a lista de Pokémon
    func fetchPokemonList(completion: @escaping ([Pokemon]) -> Void) {
        guard let url = URL(string: "\(baseURL)pokemon?limit=50") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let result = try JSONDecoder().decode(PokemonListResponse.self, from: data)
                let group = DispatchGroup()
                var pokemonList: [Pokemon] = []
                
                for pokemon in result.results {
                    group.enter()
                    self.fetchPokemonDetails(url: pokemon.url) { details in
                        if let details = details {
                            pokemonList.append(details)
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion(pokemonList)
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    // Função para buscar os detalhes de um Pokémon
    func fetchPokemonDetails(url: String, completion: @escaping (Pokemon?) -> Void) {
        guard let url = URL(string: url) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let pokemon = try JSONDecoder().decode(Pokemon.self, from: data)
                DispatchQueue.main.async {
                    completion(pokemon)
                }
            } catch {
                print(error)
                completion(nil)
            }
        }.resume()
    }
}

// Estrutura para a resposta inicial da API
struct PokemonListResponse: Codable {
    let results: [PokemonEntry]
    
    struct PokemonEntry: Codable {
        let name: String
        let url: String
    }
}
