//
//  AuthenticationErrorDescriptions.swift
//  PidoUno
//
//  Created by Luciano Nicolini on 18/12/2024.
//

import Foundation

extension ErrorDescriptions {
    var errorDescription: String? {
        switch self {
            case .emailAlreadyInUse:
                return NSLocalizedString("El correo ya está registrado", comment: "Error message for email already in use")
            case .weakPassword:
                return NSLocalizedString("Contraseña muy débil", comment: "Error message for weak password")
            case .invalidEmail:
                return NSLocalizedString("Email inválido", comment: "Error message for invalid email")
            case .passwordsDoNotMatch:
                return NSLocalizedString("Las contraseñas no coinciden", comment: "Error message when passwords do not match")
            case .emailNotVerified:
                return NSLocalizedString("Por favor, verifica tu correo electrónico antes de iniciar sesión.", comment: "Error message for unverified email")
            case .userNotFound:
                return NSLocalizedString("El usuario no fue encontrado", comment: "Error message for user not found")
            case .invalidCredential:
                return NSLocalizedString("Credenciales inválidas.", comment: "Error message for invalid credentials")
            case .userDisabled:
                 return NSLocalizedString("Este usuario está deshabilitado.", comment: "Error message when user is disabled")
            case .operationNotAllowed:
                return NSLocalizedString("Esta operación no está permitida.", comment: "Error message when operation is not allowed")
            case .tooManyRequests:
                return NSLocalizedString("Demasiadas solicitudes, intente de nuevo más tarde.", comment: "Error message when there are too many requests")
            case .tokenMissing:
                return NSLocalizedString("Falta el token de identificación.", comment: "Error message for missing token")
            case .unableToSerializeTokenString:
               return NSLocalizedString("No se pudo serializar el token.", comment: "Error message for unable to serialize token string")
            case .invalidAuthenticationState:
                 return NSLocalizedString("Estado de autenticación inválido.", comment: "Error message for invalid authentication state")
            case .networkError:
                return NSLocalizedString("Error de red, verifica tu conexión", comment: "Error message for network error")
            case .timeOutError:
                return NSLocalizedString("La petición tardo mucho tiempo en responder", comment: "Error message for timeout error")
            case .cancelledByUser:
                return NSLocalizedString("Operación cancelada por el usuario", comment: "Error message when the user cancelled the process")
            case .providerDisabled:
                return NSLocalizedString("Este proveedor de autenticación está deshabilitado.", comment: "Error message when the provider is disabled")
            case .invalidProvider:
                 return NSLocalizedString("Proveedor de autenticación inválido", comment: "Error message when provider is invalid")
            case .missingName:
                return NSLocalizedString("Por favor ingresa tu nombre", comment: "Error message when name is missing")
            case .missingEmail:
                return NSLocalizedString("Por favor ingresa tu correo", comment: "Error message when email is missing")
             case .missingPassword:
                 return NSLocalizedString("Por favor ingresa tu contraseña", comment: "Error message when password is missing")
            case .invalidName:
                return NSLocalizedString("Nombre inválido", comment: "Error message when name is invalid")
            case .unknown(let error):
              return error.localizedDescription
            }
        }
    }
