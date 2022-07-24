//
//  String + Extension.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 22.07.2022.
//

import Foundation

extension String {

    func trim() -> String {

        if self.trimmingCharacters(in: .whitespaces).isEmpty {
            return ""
        }

        return self.trimmingCharacters(in: .whitespaces)
    }
}