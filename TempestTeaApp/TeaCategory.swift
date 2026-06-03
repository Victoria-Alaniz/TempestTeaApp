//
//  TeaCategory.swift
//  TempestTeaApp
//
//  Created by Victoria Alaniz on 5/7/26.
//

import AlarmKit
import Foundation

enum TeaCategory: Int, AlarmMetadata, CaseIterable {
    case gongFu
    case whiteGreen
    case yellowOolong
    case blackPuErh
    case herbal

    //var allCases: [TeaCategory] {
        //return TeaCategory.allCases
    //}

    var name: String {
        switch self {
        case .gongFu: "GFC"
        case .whiteGreen: "WHT/GRN"
        case .yellowOolong: "YLW/OO"
        case .blackPuErh: "BLK/PUER"
        case .herbal: "HERB"
        }
    }

    var time: TimeInterval {
        switch self {
        case .gongFu: 15
        case .whiteGreen: 120
        case .yellowOolong: 180
        case .blackPuErh: 300
        case .herbal: 360
        }
    }
}
