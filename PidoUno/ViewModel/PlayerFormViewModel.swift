//
//  PlayerFormViewModel.swift
//  PidoUno
//
//  Created by Luciano Nicolini on 19/12/2024.
//


import Foundation
import FirebaseFirestore

struct PlayerProfile: Identifiable, Codable {
    let id: String
    var name: String
    var photoURL: String?
    var location: String
    var rating: PlayerRating
    var reviews: [PlayerReview]
    
    // Agregar relación con Firebase Auth User
    var firebaseUID: String
    
    // Nueva propiedad para el estilo de juego
    var playerStyle: PlayerStyle
}

// Nueva estructura para el estilo de juego
struct PlayerStyle: Codable {
    var preferredSizes: [FieldSize] // Cancha 11, 8, 6, etc.
    var preferredPosition: String // Portero, Defensa, Mediocampista, Delantero, etc
    var secondaryPosition: String? // Posicion Secundaria
    var preferredMatches: [MatchType] // Informales, Competitivos, Mixtos
    var preferredSurfaces: [SurfaceType] // Cesped, Sintetico, Piso
    var skillLevel: SkillLevel // Nivel de Habilidad
    var dominantFoot: DominantFoot // Pie Dominante
    var ageRange: String?  // Rango de edad
    var availability: [DayAvailability] // Disponibilidad
}

// Enumeración para tamaños de cancha
enum FieldSize: String, Codable, CaseIterable {
    case eleven = "11"
    case eight = "8"
    case six = "6"
    case five = "5"
    case futsal = "Futsal"
    case other = "Otro"
}

// Enumeración para tipos de partido
enum MatchType: String, Codable, CaseIterable {
    case informal = "Informales"
    case competitive = "Competitivos"
    case mixed = "Mixtos"
}

// Enumeración para tipos de superficie
enum SurfaceType: String, Codable, CaseIterable {
    case grass = "Césped"
    case synthetic = "Sintético"
    case floor = "Piso"
}

// Enumeracion para niveles de habilidad
enum SkillLevel: String, Codable, CaseIterable {
    case beginner = "Principiante"
    case intermediate = "Intermedio"
    case advanced = "Avanzado"
}

// Enumeracion para Pie Dominante
enum DominantFoot: String, Codable, CaseIterable {
    case left = "Izquierdo"
    case right = "Derecho"
    case both = "Ambos"
}

// Renombramos Rating a PlayerRating
struct PlayerRating: Codable {
    var punctuality: Double
    var payment: Double
    var averageRating: Double {
        (punctuality + payment) / 2
    }
}

// Renombramos Review a PlayerReview
struct PlayerReview: Identifiable, Codable {
    let id: String
    let reviewerId: String
    let comment: String
    let date: Date
}

// Modelos ya definidos

struct TimeInterval: Identifiable, Hashable, Codable {
    var id = UUID()
    var startTime: Date
    var endTime: Date
    
    static func == (lhs: TimeInterval, rhs: TimeInterval) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct DayAvailability: Identifiable, Codable {
    var id = UUID()
    var day: String
    var timeSlots: [TimeInterval]
}
