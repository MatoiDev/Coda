//
//  Extensions.swift
//  Coda
//
//  Created by Matoi on 26.10.2022.
//

import Foundation
import SwiftUI

// MARK: - NSError
extension NSError : Identifiable {
    public var id: Int { code }
}


// MARK: - Blur View
extension View {
    func backgroundBlur(radius: CGFloat = 3, opaque: Bool = false) -> some View {
        self.background(Blur(radius: radius, opaque: opaque))
    }
}

 // MARK: - UserDefaults saving class types
extension UserDefaults {

    func setClass<T: Encodable>(encodable: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(encodable) {
            set(data, forKey: key)
        }
    }

    func getClass<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = object(forKey: key) as? Data,
            let value = try? JSONDecoder().decode(type, from: data) {
            return value
        }
        return nil
    }
}


extension View {
    public func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}

extension UIView {
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}


extension String : Error, LocalizedError {
    var localizedDescription : String? { return self }
}


extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}


extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        dateformat.locale = Locale(identifier: "en")
       if dateformat.string(from: self).contains(",") {
           let date = dateformat.string(from: self).split(separator: ",")
            return "\(date[0]) at\(date[1])"
       }
           return dateformat.string(from: self)
       
    }
}

extension UITableView {
    func scrollTableViewToBottom(animated: Bool) {
        guard let dataSource = dataSource else { return }

        var lastSectionWithAtLeasOneElements = (dataSource.numberOfSections?(in: self) ?? 1) - 1

        while dataSource.tableView(self, numberOfRowsInSection: lastSectionWithAtLeasOneElements) < 1 {
            lastSectionWithAtLeasOneElements -= 1
        }

        let lastRow = dataSource.tableView(self, numberOfRowsInSection: lastSectionWithAtLeasOneElements) - 1

        guard lastSectionWithAtLeasOneElements > -1 && lastRow > -1 else { return }

        let bottomIndex = IndexPath(item: lastRow, section: lastSectionWithAtLeasOneElements)
        scrollToRow(at: bottomIndex, at: .bottom, animated: animated)
    }
}


extension String {
    subscript (range: Range<Int>) -> String {
        guard self.count > range.count else { return self }
        let firstIndex = self.startIndex
        let cutIndex = self.index(self.startIndex, offsetBy: range.count)
        return "\(self[firstIndex..<cutIndex])"
    }
}

class Cache: NSCache<AnyObject, AnyObject> {
    static let shared = NSCache<AnyObject, AnyObject>()
    private override init() {
        super.init()
        
    }
    
}

// Hide keyboard
extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension URL {

    private var fileSize: Int? {
        let value = try? resourceValues(forKeys: [.fileSizeKey])
        return value?.fileSize
    }
    
    private var fileName: String? {
        let value = try? resourceValues(forKeys: [.nameKey])
        return value?.name
    }
    
    private var fileExtension: String? {
        let value = try? resourceValues(forKeys: [.contentTypeKey])
        
        if let value = value, value.contentType == .pdf {
            return "PDF"
        }
        return nil
    }
    
    var fileAttributes: (name: String, extension: String, size: Int)? {
        if let fileName: String = self.fileName?.components(separatedBy: ".")[0],
           let fileExtension: String = self.fileExtension,
           let fileSize: Int = self.fileSize {
            print("We have")
            return (name: fileName, extension: fileExtension, size: fileSize)
        }
        return nil
    }
}

extension Double {
    
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func bytesToHumanReadFormat() -> String {
        if self >= 1024 * 1024 * 1024 {
            return String(Double(self / Double(1024 * 1024 * 1024)).rounded(toPlaces: 2)) + (LocalizedStringKey(" GB").stringValue() ?? " MB")
        }
        else if self >= 1024 * 1024 {
            return String(Double(self / Double(1024 * 1024)).rounded(toPlaces: 2)) + (LocalizedStringKey(" MB").stringValue() ?? " MB")
        } else if self >= 1024 {
            return String(Double(self / 1024.0).rounded(toPlaces: 2)) + (LocalizedStringKey(" KB").stringValue() ?? " KB")
        }
        return String(self) + (LocalizedStringKey(" B").stringValue() ?? " B")
    }
    
}

extension String {
    func count(of needle: Character) -> Int {
        return reduce(0) {
            $1 == needle ? $0 + 1 : $0
        }
    }
}

extension String {
    static func localizedString(for key: String,
                                locale: Locale = .current) -> String {
        
        let language = locale.languageCode
        let path = Bundle.main.path(forResource: language, ofType: "lproj")!
        let bundle = Bundle(path: path)!
        let localizedString = NSLocalizedString(key, bundle: bundle, comment: "")
        
        return localizedString
    }
}

extension LocalizedStringKey {
    var stringKey: String? {
        Mirror(reflecting: self).children.first(where: { $0.label == "key" })?.value as? String
    }
    
    func stringValue(locale: Locale = .current) -> String? {
        guard let stringKey = self.stringKey else { return nil }
        let language = locale.languageCode
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else { return stringKey }
        guard let bundle = Bundle(path: path) else { return stringKey }
        let localizedString = NSLocalizedString(stringKey, bundle: bundle, comment: "")
        return localizedString
    }
}
