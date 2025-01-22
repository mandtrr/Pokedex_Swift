import Foundation

// Estrutura para representar um Pokémon
struct Pokemon: Codable, Identifiable {
    let id: Int
    let name: String
    let types: [TypeEntry]
    let sprites: SpriteEntry
    let height: Int  // Altura em decímetros (décimos de metro)
    let weight: Int  // Peso em hectogramas (10 gramas)
    let abilities: [AbilityEntry] // Habilidades do Pokémon
    
    struct TypeEntry: Codable {
        let type: TypeName
        
        struct TypeName: Codable {
            let name: String
        }
    }
    
    struct SpriteEntry: Codable {
        let front_default: String
    }

    struct AbilityEntry: Codable {
        let ability: AbilityName
        
        struct AbilityName: Codable {
            let name: String
        }
    }
}

