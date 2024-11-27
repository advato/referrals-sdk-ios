

import Foundation

/// Represents the possible errors that can occur within the SDK.
///
/// The following cases are handled:
/// - `.missingEntryPoint`: No valid entry point was provided.
/// - `.noDataFound`: The API response did not contain valid data.
/// - `.apiError`: An error occurred during the API request, with the underlying error wrapped.
/// - `.unknown`: An unexpected error occurred.
public enum ReferralError: Error {
    /// An entry point was missing.
    case missingEntryPoint
    
    /// No data was found in the API response.
    case noDataFound
    
    /// The API request failed with an underlying error.
    case apiError(Error)
    
    /// An unknown error occurred.
    case unknown
    
    /// Provides a user-friendly description of the error.
    public var localizedDescription: String {
        switch self {
        case .missingEntryPoint:
            return "Entry point is missing."
            
        case .noDataFound:
            return "No data was found in the API response."
            
        case .apiError(let error):
            return "API error: \(error.localizedDescription)"
            
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
