//
//  FreelanceEnums.swift
//  Coda
//
//  Created by Matoi on 05.02.2023.
//

import Foundation


enum FreelanceTopic: String {
    
    case Administration = "Administration"
    case Design = "Design"
    case Development = "Development"
    case Testing = "Testing"
    
}

struct FreelanceSubTopic {
    
    enum FreelanceDevelopingSubTopic: String {
        
        case Backend = "Backend"
        case Frontend = "Frontend"
        case Prototyping = "Prototyping"
        case IOS = "iOS"
        case Android = "Android"
        case DesktopSoftware = "Desktop software"
        case BotsAndDataParsing = "Bots and data parsing"
        case GameDev = "Game Development"
        case OneCprogramming = "1C-programming"
        case ScriptsAndPlugins = "Scripts and plugins"
        case VoiceInterfaces = "Voice interfaces"
        case Offtop = "Off topic"
        
        static let values: [FreelanceDevelopingSubTopic] = [.Backend, .Frontend, .Prototyping, .IOS, .Android, .DesktopSoftware, .BotsAndDataParsing, .GameDev, .OneCprogramming, .ScriptsAndPlugins, .VoiceInterfaces, .Offtop]
        
    }

    enum FreelanceTestingSubTopic: String {
        
        case Sites = "Sites"
        case Mobile = "Mobile"
        case Software = "Software"
        
        static let values: [FreelanceTestingSubTopic] = [.Sites, .Mobile, .Software]
        
    }

    enum FreelanceDesignSubTopic: String {
        
        case Sites = "Sites"
        case LandingPages = "Landing pages"
        case Logos = "Logos"
        case DrawingsAndIllustrations = "Drawings and illustrations"
        case MobileApplications = "Mobile applications"
        case Icons = "Icons"
        case Polygraphy = "Polygraphy"
        case Banners = "Banners"
        case VectorGraphics = "Vector graphics"
        case CorporateIdentity = "Corporate identity"
        case Presentations = "Presentations"
        case ThreeD = "3D"
        case Animation = "Animation"
        case PhotoProcessing = "Photo processing"
        case Offtop = "Off topic"
        
        static let values: [FreelanceDesignSubTopic] = [.Sites, .LandingPages, .Logos, .DrawingsAndIllustrations, .MobileApplications, .Icons, .Polygraphy, .Banners, .VectorGraphics, .CorporateIdentity, .Presentations, .ThreeD, .Animation, .PhotoProcessing, .Offtop]
        
    }

    enum FreelanceAdministrationSubTropic: String {
        
        case Servers = "Servers"
        case ComputerNetworks = "Computer networks"
        case Databases = "Databases"
        case SoftwareProtectionAndSecurity = "Software protection and security"
        case Offtop = "Off topic"
        
        static let values: [FreelanceAdministrationSubTropic] = [.Servers, .ComputerNetworks, .Databases, .SoftwareProtectionAndSecurity, .Offtop]
        
    }
}

// MARK: - Order

enum FreelanceOrderTypeReward: Equatable {
    case negotiated
    case specified(price: String)
}

// MARK: - Service
