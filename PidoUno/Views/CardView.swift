//
//  CardView.swift
//  PidoUno
//
//  Created by Luciano Nicolini on 20/12/2024.
//

import SwiftUI

struct SportEventCard: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header con gradiente y superposición de imagen
            ZStack(alignment: .bottomLeading) {
                // Imagen de fondo (puedes reemplazar "sport_background" con tu imagen)
                Image("sport_background")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipped()
                
                // Superposición de gradiente
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.6), Color.clear]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                
                // Contenido del header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Complejo Plaza Colón")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Partido Amistoso")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
            }
            .frame(height: 150)
            
            // Información del evento
            VStack(spacing: 16) {
                // Detalles principales con iconos modernos
                HStack(spacing: 20) {
                    InfoItem(icon: "calendar", text: "08 Ago", color: .blue)
                    InfoItem(icon: "clock", text: "21:30", color: .orange)
                    InfoItem(icon: "dollarsign.circle", text: "$3.000", color: .green)
                }
                .padding(.top, 12)
                
                // Etiquetas de categoría
                HStack(spacing: 10) {
                    CategoryPill(text: "Mixto", color: .purple)
                    CategoryPill(text: "7vs7", color: .pink)
                }
                
                // Indicador de jugadores
                HStack {
                    Spacer()
                    PlayerCountIndicator(count: 6)
                }
                
                // Botón de acción principal
                Button(action: {}) {
                    HStack {
                        Text("Reservar lugar")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green)
                            .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
            }
            .padding()
            .background(Color.white)
        }
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
}

// Componente para los ítems de información
struct InfoItem: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}

// Componente para las etiquetas de categoría
struct CategoryPill: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(color.opacity(0.2))
            )
            .foregroundColor(color)
    }
}

// Componente para el indicador de jugadores
struct PlayerCountIndicator: View {
    let count: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: 60, height: 60)
            VStack(spacing: 2) {
                Text("\(count)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                Text("faltan")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    SportEventCard()
}
