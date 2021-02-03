//
//  PostError.swift
//  Continuum
//
//  Created by Lee McCormick on 2/2/21.
//  Copyright © 2021 trevorAdcock. All rights reserved.
//

import Foundation


enum PostError: LocalizedError {
    
    case ckError
    case thrownError(Error)
    case unableToUpwrap
    
    var errorDescription: String {
        switch self {
        case .ckError:
            return "The server failed to reach data in the CloudKit."
        case .thrownError(let error):
            return "Opps, there was an error: \(error.localizedDescription)"
        case .unableToUpwrap:
            return "The server failed to load any data from the CloudKit."
        }
    }
}

