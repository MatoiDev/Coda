//
//  FSManager.swift
//  Coda
//
//  Created by Matoi on 03.11.2022.
//

import Foundation
import SwiftUI
import Combine
import FirebaseCore
import FirebaseFirestore
import Firebase
import FirebaseStorage


protocol CloudFirestoreItemDelegate {
    var id: String { get }
}

class FirebaseFilesUploadingProgreessManager: ObservableObject {

//    @Published var images: [(StorageTaskStatus, @escaping (StorageTaskSnapshot) -> Void) -> String] = []
//    @Published var files: [(StorageTaskStatus, @escaping (StorageTaskSnapshot) -> Void) -> String] = []
    
    init() {
        self.addPublisherToProgressSnapshot()
    }
    
    @Published var imagesProgressSnapshots: [StorageTaskSnapshot : Double] = [:]
    @Published var filesProgressSnapshots: [StorageTaskSnapshot : Double] = [:]
    
    @Published var imagePercentage: Double = 0
    @Published var filesPercentage: Double = 0
    
    @Published var amountPercentage: Double = 0
    
    var cancellabels: Set<AnyCancellable> = Set<AnyCancellable>()

//    func getAmountPercentageOfImageUploadings(completion: @escaping (Double) -> ()) {
//        var amount: Double = 0
//        for snapshot in self.imagesProgressSnapshots.keys {
//            print("_______")
//            amount += imagesProgressSnapshots[snapshot]!
//        }
//        completion(amount)
//    }
    
    func addPublisherToProgressSnapshot() {
        $imagesProgressSnapshots
            .combineLatest($filesProgressSnapshots)
            .sink { completionResult in
                switch completionResult {
                case .finished:
                    print("ALL IMAGES AND FILES HAVE UPLOADED")
                case .failure(let err):
                    print("error with uploading files: \(err)")
                }
            } receiveValue: { [weak self] (dictOfImages, dictOfFiles) in
                guard let self = self else { return }
                guard self.imagePercentage != 100.0 && self.filesPercentage != 100.0 else {
                    self.amountPercentage = 90
                    return
                }
                var amount: Double = 0
                if !dictOfFiles.isEmpty {
                    for snapshot in dictOfFiles.keys {
                        amount += dictOfFiles[snapshot]!
                    }
                }
                if !dictOfImages.isEmpty {
                    for snapshot in dictOfImages.keys {
                        amount += dictOfImages[snapshot]!
                    }
                }
                self.amountPercentage = amount / (Double(dictOfFiles.keys.count) + Double(dictOfImages.count))
                print(self.amountPercentage)
            }
            .store(in: &self.cancellabels)

            
    }

}


class FSManager: ObservableObject {
    
    @AppStorage("UserID") private var userID : String = ""
    @AppStorage("LoginUserID") var loginUserID: String = ""

    @AppStorage("IsUserExists") var userExists : Bool = false
    
    @AppStorage("ShowPV") var showPV: Bool = false
    
    @AppStorage("UserEmail") private var userEmail : String = ""
    @AppStorage("UserUsername") var userUsername: String = ""
    @AppStorage("UserFirstName") var userFirstName: String = ""
    @AppStorage("UserLastName") var userLastName: String = ""
    @AppStorage("UserMates") var userMates: String = ""
    @AppStorage("avatarURL") var avatarURL: String = ""
    @AppStorage("UserReputation") var userReputation: String = ""
    @AppStorage("UserLanguage") var userLanguage: PLanguages.RawValue = ""
    @AppStorage("UserBio") var userBio : String = ""
    @AppStorage("UserRegisterDate") var userRegisterDate: String = ""
    
    @AppStorage("UserProjects") var userProjects : [String] = []
    @AppStorage("UserPosts") var userPosts : [String] = []
    @AppStorage("UserChats") var userChats: [String] = []
    
    @Published var uploadingProgress: Progress?
    
    private var cancellabels: Set<AnyCancellable> = Set<AnyCancellable>()

    private let db = Firestore.firestore()
    
    enum UploadFolderType {
        case order, service, idea, teamFinder, project
    }
    
    // MARK: - Generate IDs (Static)
    static func generate64CharactersLongID() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<64).map{ _ in letters.randomElement()! })
    }
    
    static func generate128CharactersLongID() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<128).map{ _ in letters.randomElement()! })
    }
    
    static func generateMessageImageID(messageID: String) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return messageID + String((0..<16).map{ _ in letters.randomElement()! })
    }
    
    // MARK: - Upload functions
    func upload(avatar: UIImage, completion: @escaping (Result<URL, Error>) -> Void) -> Void {
        
        
        let ref = Storage.storage().reference().child("Avatars").child(self.userID)
        
        guard let imageData = avatar.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        ref.putData(imageData, metadata: metadata) { metadata, error in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            
            ref.downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(url))
            }
        }
    }
    
    func upload(messageImage: UIImage, messageID: String, completion: @escaping (Result<URL, Error>) -> Void) -> Void {
        
        
        let imageID = FSManager.generateMessageImageID(messageID: messageID)
        let ref = Storage.storage().reference().child("MessageImages").child(imageID)
        
        guard let imageData = messageImage.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        ref.putData(imageData, metadata: metadata) { metadata, error in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
           
            ref.downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(url))
                
            }
        }
    }
    
    func upload(postImage: UIImage, id: String, completion: @escaping (Result<String, Error>) -> Void) -> Void {
        let ref = Storage.storage().reference().child("PostPreviews").child(id)
        
        guard let imageData = postImage.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        ref.putData(imageData, metadata: metadata) { metadata, error in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            
            ref.downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success("\(url)"))
            }
        }
        
    }
    
    func upload(preview: UIImage, id: String, completion: @escaping (Result<String, Error>) -> Void) -> Void {
        let ref = Storage.storage().reference().child("ProjectPreviews").child(id)
        
        guard let imageData = preview.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        ref.putData(imageData, metadata: metadata) { metadata, error in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            
            ref.downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success("\(url)"))
            }
        }
    }
    
    private func upload(previews: [UIImage], to folder: UploadFolderType, observeManager: FirebaseFilesUploadingProgreessManager, completion: @escaping (Result<[String], Error>) -> Void) -> Void {
        
        let storage = Storage.storage()
        
        var uploadedURLs: [String] = []
        var uploadCount: Int = 0
        
        var folderName: String {
            switch folder {
            case .order:
                return "FreelanceOrderPreviews"
            case .service:
                return "FreelanceServicePreviews"
            case .idea:
                return "IdeaPreviews"
            case .teamFinder:
                return "TeamFinderPreviews"
            case .project:
                return "ProjectPreviews"
                
            }
        }
        
        for preview in previews {
            
            guard let imageData = preview.jpegData(compressionQuality: 0.4) else { return }
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            
            let imageID = FSManager.generate128CharactersLongID()
            
            let ref = storage.reference().child(folderName).child(imageID)
            
            let uploadTask = ref.putData(imageData, metadata: metadata) { metadata, error in
                guard let _ = metadata else {
                    completion(.failure(error!.localizedDescription))
                    return
                }
                
                ref.downloadURL { url, error in
                    if let fileURL = url?.absoluteString {
                        print(fileURL)
                        uploadedURLs.append(fileURL)
                        uploadCount += 1
                        print("Number of previews successfully uploaded: \(uploadCount)")
                        if uploadCount == previews.count {
                            print("All previews are uploaded successfully, uploadedImageUrlsArray: \(uploadedURLs)")
                            completion(.success(uploadedURLs))
                        }
                    }
                    
                }
            }
           
            let observer = uploadTask.observe(.progress) { snapshot in
//                print(snapshot, "----------->>>>>>><<<<<<<----------")
                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                observeManager.imagesProgressSnapshots[snapshot] = percentComplete
            }
            
        }
       
    }
    
    func upload(PDFs files: [URL], to folder: UploadFolderType, observeManager: FirebaseFilesUploadingProgreessManager, completionHandler: @escaping (Result<[String], Error>) -> Void) {
        
        let storage = Storage.storage()

        var uploadedURLs: [String] = []
        var uploadCount: Int = 0
        
        var folderName: String {
            switch folder {
            case .order:
                return "FreelanceOrderFiles"
            case .service:
                return "FreelanceServiceFiles"
            case .idea:
                return "IdeaFiles"
            case .teamFinder:
                return "TeamFinderFiles"
            case .project:
                return "ProjectFiles"
            }
        }
        
        
        for file in files {
            let imageName = file.deletingPathExtension().lastPathComponent
            
            let ref = storage.reference().child(folderName).child("\(self.loginUserID)/\(imageName)")
            moveItemsToTempDirectory(originPath: file) { res in
                switch res {
                case .success(let filePath):
                    let uploadTask = ref.putFile(from: filePath, metadata: nil) { metadata, error in
                        if let error = error {
                            completionHandler(.failure(error.localizedDescription))
                        }
                        else {
                            ref.downloadURL { url, error in
                                if let fileURL = url?.absoluteString {
                                    print(fileURL)
                                    uploadedURLs.append(fileURL)
                                    uploadCount += 1
                                    print("Number of files successfully uploaded: \(uploadCount)")
                                    if uploadCount == files.count{
                                        print("All files are uploaded successfully, uploadedImageUrlsArray: \(uploadedURLs)")
                                        
                                        completionHandler(.success(uploadedURLs))
                                    }
                                }
                                
                            }
                        }
                    }
                    
                    let observer = uploadTask.observe(.progress) { snapshot in
        //                print(snapshot, "----------->>>>>>><<<<<<<----------")
                        let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                        observeManager.filesProgressSnapshots[snapshot] = percentComplete
                    }
                    
                case .failure(let e):
                    completionHandler(.failure(e.localizedDescription))
                }
            }
           
        }
    }
    
    
    // MARK: - Upload Publishers
    func uploadPublisher(PDFs files: [URL], observeManager: FirebaseFilesUploadingProgreessManager, folder: UploadFolderType = .order) -> Future<[String], Error> {
        Future { promise in
            if files.count == 0 {
                promise(.success([]))
                return
            }
            self.upload(PDFs: files, to: folder, observeManager: observeManager) { result in
                switch result {
                case .success(let urls):
                    observeManager.filesPercentage = 100.0
                    promise(.success(urls))
                case .failure(let failure):
                    promise(.failure(failure))
                }
            }
        }
    }
    
    func uploadPublisher(previews: [UIImage], observeManager: FirebaseFilesUploadingProgreessManager, folder: UploadFolderType = .order) -> Future<[String], Error> {
        Future { promise in
            if previews.count == 0 {
                promise(.success([]))
                return
            }
            
                self.upload(previews: previews, to: folder, observeManager: observeManager) { result in
                    switch result {
                    case .success(let urls):
                        observeManager.imagePercentage = 100.0
                        promise(.success(urls))
                        
                    case .failure(let failure):
                        promise(.failure(failure))
                    }
                }
        }
    }
    
    
    // MARK: - Remove functions
    
    func remove(project id: String) -> Void {
        
        // Delete project from FireBase
        
        self.db.collection("Projects").document(id).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func remove(message id: String, from chatID: String) -> Void {
        
        // Delete message from FireBase
        self.db.collection("Chats").document(chatID).updateData([
            "messages": FieldValue.arrayRemove([id])
        ]) { error in
            if error == nil {
                self.db.collection("Chats").document(chatID).getDocument { (document, _) in
                    if let document = document, document.exists {
                        print("HUI")
                        if let messages = (document.data()?["messages"] as? [String]) {
                            self.db.collection("Chats").document(chatID).updateData([
                                "lastMessage": messages.last ?? ""
                            ]) { err in
                                if err == nil {
                                    self.db.collection("Messages").document(id).delete() { e in
                                        if let e = e {
                                            print("Error removing document: \(e)")
                                        } else {
                                            print("Document successfully removed!")
                                        }
                                    }

                                } else {
                                    print("Cannot Update messages")
                                }
                            }

                        } else {
                            print("The chat doens't contain messages")
                        }
                    } else {
                        print("Chat doesn't exist")
                        
                    }
                }
            }
        }
    }
    
    func remove(messageImage id: String, completion: @escaping (Result<NSNull, Error>) -> Void) -> Void {
        guard id != "" else { completion(.failure("Not an image")); return }
        let desertRef = Storage.storage().reference().child("MessageImages").child(id)

        desertRef.delete { error in
            if let error = error {
                completion(.failure(error.localizedDescription))
            } else {
                completion(.success(NSNull()))
            }
        }
    }
    
    func remove(post id: String, userID: String, completion: @escaping (Result<String, Error>) -> Void) -> Void {
        
        // Delete post from FireBase
        
        self.db.collection("Users").document(userID).updateData([ // delete from user List
            
            "posts" : FieldValue.arrayRemove([id])
            
        ]) { err in
            if let err = err {
                completion(.failure(err))
                self.showPV = false
            } else {
                self.showPV = false
                self.db.collection("Posts").document(id).delete() { err in // delete from Posts base
                    if let err = err {
                        completion(.failure("Error removing document: \(err)"))
                    } else {
                        completion(.success("Document successfully removed!"))
                    }
                }
            }
        }
        self.getUsersData(withID: userID)
    }
    
    func remove(projectPriview id: String) -> Void {
        let desertRef = Storage.storage().reference().child("ProjectPreviews").child(id)
        // Delete the file
        desertRef.delete { error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                // File deleted successfully
            }
        }
    }

    func remove(postImage id: String, completion: @escaping (Result<NSNull, Error>) -> Void) -> Void {
        let desertRef = Storage.storage().reference().child("PostPreviews").child(id)

        desertRef.delete { error in
            if let error = error {
                completion(.failure(error.localizedDescription))
            } else {
                completion(.success(NSNull()))
            }
        }
    }
    
    
    // MARK: - Create functions
    
    func serveNewsPost(withID id: String, competion: @escaping (Result<String, Error>) -> Void) -> Void {
        self.db.collection("NewsPosts").document(id).setData([
            "id": id,
            "upvotes": [],
            "downvotes": [],
            "comments": []
            
        ]) { error in
            if let error = error {
                competion(.failure(error))
            } else {
                competion(.success(""))
            }
            
        }
    }
    
    func createFindTeamAnnouncement(owner userID: String,
                    title: String,
                    text: String,
                    category: FreelanceTopic,
                    devSubtopic: FreelanceSubTopic.FreelanceDevelopingSubTopic,
                    adminSubtopic: FreelanceSubTopic.FreelanceAdministrationSubTropic,
                    designSubtopic: FreelanceSubTopic.FreelanceDesignSubTopic,
                    testSubtopic: FreelanceSubTopic.FreelanceTestingSubTopic,
                    languages: [LangDescriptor],
                    coreSkills: String,
                    previews: [UIImage]?,
                    recruitsCount: Int,
                    observeManager: FirebaseFilesUploadingProgreessManager,
                    completionHandler: @escaping (Result<String, Error>) -> Void) -> Void {
        
        guard Reachability.isConnectedToNetwork() else { observeManager.amountPercentage = -1; return }
        
        
        self.uploadPublisher(previews: previews ?? [], observeManager: observeManager, folder: .teamFinder)
                .sink { res in
                    if case .failure = res {
                        print(res)
                    }
                } receiveValue: { previewsURL in
                    
                    let teamFinderID: String = FSManager.generate64CharactersLongID()
                    
                    
                    self.db.collection("TeamAnnouncements").document(teamFinderID).setData([
                        
                        "id" : teamFinderID,
                        "owner": userID,
                        "title": title,
                        "text": text,
                        "category": category.rawValue,
                        "devSubtopic": devSubtopic.rawValue,
                        "adminSubtopic": adminSubtopic.rawValue,
                        "designSubtopic": designSubtopic.rawValue,
                        "testSubtopic": testSubtopic.rawValue,
                        "langdescriptors": languages.map({$0.rawValue}),
                        "coreskills": coreSkills,
                        "previews": previewsURL,
                        "recruitsCount": recruitsCount,
                        "recruited": [],
                        "time": Date().timeIntervalSince1970,
                        "views": [userID],
                        "comments": [],
                        "date": Date().getFormattedDate(format: "d MMM, HH:mm")
                        
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                            self.showPV = false
                            observeManager.amountPercentage = -1
                            completionHandler(.failure("Error with creating team announcement: \(err.localizedDescription)"))
                        } else {
                            observeManager.amountPercentage = 100
                            completionHandler(.success(teamFinderID))
                        }
                    }
                    
                    
                }.store(in: &self.cancellabels)
        
        
    }
    
    func createIdea(owner userID: String,
                    title: String,
                    text: String,
                    category: FreelanceTopic,
                    devSubtopic: FreelanceSubTopic.FreelanceDevelopingSubTopic,
                    adminSubtopic: FreelanceSubTopic.FreelanceAdministrationSubTropic,
                    designSubtopic: FreelanceSubTopic.FreelanceDesignSubTopic,
                    testSubtopic: FreelanceSubTopic.FreelanceTestingSubTopic,
                    difficultyLevel: IdeaDifficultyLevel,
                    languages: [LangDescriptor],
                    coreSkills: String,
                    previews: [UIImage]?,
                    files: [URL]?,
                    observeManager: FirebaseFilesUploadingProgreessManager,
                    completionHandler: @escaping (Result<String, Error>) -> Void) -> Void {
        
        guard Reachability.isConnectedToNetwork() else { observeManager.amountPercentage = -1; return }
        
        self.uploadPublisher(PDFs: files ?? [], observeManager: observeManager, folder: .idea)
            .combineLatest(self.uploadPublisher(previews: previews ?? [], observeManager: observeManager, folder: .idea))
                .sink { res in
                    if case .failure = res {
                        print(res)
                    }
                } receiveValue: { (filesURL, previewsURL) in
                    
                    let ideaID: String = FSManager.generate64CharactersLongID()
                    var subtopic: String = ""
                    switch category {
                    case .Administration:
                        subtopic = adminSubtopic.rawValue
                    case .Design:
                        subtopic = designSubtopic.rawValue
                    case .Development:
                        subtopic = devSubtopic.rawValue
                    case .Testing:
                        subtopic = testSubtopic.rawValue
                    case .all:
                        subtopic = "All"
                    }
                    
                    
                    self.db.collection("Ideas").document(ideaID).setData([
                        
                        "id" : ideaID,
                        "owner": userID,
                        "title": title,
                        "text": text,
                        "category": category.rawValue,
                        "subcategory": subtopic,
                        "difficultylevel": difficultyLevel.rawValue,
                        "langdescriptors": languages.map({$0.rawValue}),
                        "coreskills": coreSkills,
                        "previews": previewsURL,
                        "files": filesURL,
                        "time": Date().timeIntervalSince1970,
                        "stars": [],
                        "responses": [],
                        "views": [userID],
                        "comments": [],
                        "saves": [],
                        "date": Date().getFormattedDate(format: "d MMM, HH:mm")
                        
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                            self.showPV = false
                            observeManager.amountPercentage = -1
                            completionHandler(.failure("Error with creating post: \(err.localizedDescription)"))
                        } else {
                            observeManager.amountPercentage = 100
                            completionHandler(.success(ideaID))
                        }
                    }
                    
                    
                }.store(in: &self.cancellabels)
        
        
    }
    
    func createVacancy(company companyID: String,
                       title: String,
                       description: String,
                       specialization: FreelanceTopic,
                       qualification: DeveloperQualificationType,
                       locationType: LocationType,
                       specifiedLocation: String,
                       typeOfEmployment: TypeOfEmployment,
                       salaryType: SalaryType,
                       currency: CurrencyType,
                       salaryLowerBound: String,
                       salaryUpperBound: String,
                       requirements: String,
                       languages: [LangDescriptor],
                       observeManager: FirebaseFilesUploadingProgreessManager,
                       completion: @escaping (Result<String, Error>) -> Void
                       
    ) {
        
        guard Reachability.isConnectedToNetwork() else { observeManager.amountPercentage = -1; return }
        
        let vacancyID: String = FSManager.generate64CharactersLongID()
        self.db.collection("Vacancy").document(vacancyID).setData([
            
            "id" : vacancyID,
            "company": companyID,
            "title": title,
            "description": description,
            "specialization": specialization.rawValue,
            "qualification":  qualification.rawValue,
            "locationType": locationType == .free ? "free" : "specified",
            "specifiedLocation": locationType == .free ? "not specified" : specifiedLocation,
            "typeOfEmployment": typeOfEmployment.rawValue,
            "salaryType": salaryType.rawValue,
            "currency": currency.rawValue,
            "salaryLowerBound": salaryLowerBound,
            "salaryUpperBound": salaryUpperBound,
            "requirements": requirements,
            "languages": languages.map({$0.rawValue}),
            "time": Date().timeIntervalSince1970,
            "responses": [],
            "views": [companyID],
            "comments": [],
            "date": Date().getFormattedDate(format: "d MMM, HH:mm")
            
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
                self.showPV = false
                observeManager.amountPercentage = -1
                completion(.failure("Error with creating post: \(err.localizedDescription)"))
            } else {
                observeManager.amountPercentage = 100
                completion(.success(vacancyID))
            }
        }
        
//        let observer = uploadTask.observe(.progress) { snapshot in
//
//            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
//            observeManager.filesProgressSnapshots[snapshot] = percentComplete
//        }
    }
    
    func createProject(
        author: String,
        title: String,
                       description: String,
                       category: FreelanceTopic,
                       devSubtopic: FreelanceSubTopic.FreelanceDevelopingSubTopic,
                       adminSubtopic: FreelanceSubTopic.FreelanceAdministrationSubTropic,
                       designSubtopic: FreelanceSubTopic.FreelanceDesignSubTopic,
                       testSubtopic: FreelanceSubTopic.FreelanceTestingSubTopic,
                       languages: [LangDescriptor],
                       projectDetails: String,
                       linkToTheSource: String,
                       previews: [UIImage]? = nil,
                       files: [URL]? = nil,
                       observeManager: FirebaseFilesUploadingProgreessManager,
                       completionHandler: @escaping (Result<String, Error>) -> Void) {
        guard Reachability.isConnectedToNetwork() else { observeManager.amountPercentage = -1; return }
        self.uploadPublisher(PDFs: files ?? [], observeManager: observeManager, folder: .project)
            .combineLatest(self.uploadPublisher(previews: previews ?? [], observeManager: observeManager, folder: .project))
                .sink { res in
                    if case .failure = res {
                        print(res)
                    }
                } receiveValue: { (filesURL, previewsURL) in
                    
                    let orderID: String = FSManager.generate64CharactersLongID()
                    var subtopic: String = ""
                    
                    switch category {
                    case .Administration:
                        subtopic = adminSubtopic.rawValue
                    case .Design:
                        subtopic = designSubtopic.rawValue
                    case .Development:
                        subtopic = devSubtopic.rawValue
                    case .Testing:
                        subtopic = testSubtopic.rawValue
                    case .all:
                        subtopic = "All"
                    }
                    
                    self.db.collection("FreelanceOrder").document(orderID).setData([
                        
                        "id" : orderID,
                        "author": author,
                        "title": title,
                        "description": description,
                        "category": category.rawValue,
                        "subtopic": subtopic,
                        "langdescriptors": languages.map({$0.rawValue}),
                        "projectDetails": projectDetails,
                        "linkToTheSource": linkToTheSource,
                        "previews": previewsURL,
                        "files": filesURL,
                        
                        "time": Date().timeIntervalSince1970,
                        "upvotes": [],
                        "downvotes": [],
                        "comments": [],
                        "views": [author],
                        "date": Date().getFormattedDate(format: "d MMM, HH:mm")
                        
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                            self.showPV = false
                            observeManager.amountPercentage = -1
                            completionHandler(.failure("Error with creating project: \(err.localizedDescription)"))
                        } else {
                            observeManager.amountPercentage = 100
                            completionHandler(.success(orderID))
                        }
                    }
                    
                    
                }.store(in: &self.cancellabels)
        
    }
    
    func createFreelanceOrder(owner userID: String,
                              name: String,
                              description: String,
                              priceType: FreelancePriceType,
                              price: String,
                              per: SpecifiedPriceType,
                              topic: FreelanceTopic,
                              
                              devSubtopic: FreelanceSubTopic.FreelanceDevelopingSubTopic,
                              adminSubtopic: FreelanceSubTopic.FreelanceAdministrationSubTropic,
                              designSubtopic: FreelanceSubTopic.FreelanceDesignSubTopic,
                              testSubtopic: FreelanceSubTopic.FreelanceTestingSubTopic,
    
                              languages: [LangDescriptor],
                              coreSkills: String,
                              previews: [UIImage]?,
                              files: [URL]?,
                              observeManager: FirebaseFilesUploadingProgreessManager,
                              completionHandler: @escaping (Result<String, Error>) -> Void) -> Void {
        
        guard Reachability.isConnectedToNetwork() else { observeManager.amountPercentage = -1; return }
            self.uploadPublisher(PDFs: files ?? [], observeManager: observeManager)
            .combineLatest(self.uploadPublisher(previews: previews ?? [], observeManager: observeManager, folder: .order))
                .sink { res in
                    if case .failure = res {
                        print(res)
                    }
                } receiveValue: { (filesURL, previewsURL) in
                    
                    let orderID: String = FSManager.generate64CharactersLongID()
                    var subtopic: String = ""
                    
                    switch topic {
                    case .Administration:
                        subtopic = adminSubtopic.rawValue
                    case .Design:
                        subtopic = designSubtopic.rawValue
                    case .Development:
                        subtopic = devSubtopic.rawValue
                    case .Testing:
                        subtopic = testSubtopic.rawValue
                    case .all:
                        subtopic = "All"
                    }
                    
                    self.db.collection("FreelanceOrder").document(orderID).setData([
                        
                        "id" : orderID,
                        "owner": userID,
                        "name": name,
                        "description": description,
                        "priceType": priceType == .negotiated ? "Negotiated" : "Specified",
                        "price": price,
                        "pricePer": per.rawValue,
                        "topic": topic.rawValue,
                        "subtopic": subtopic,
                        "langdescriptors": languages.map({$0.rawValue}),
                        "coreskills": coreSkills,
                        "previews": previewsURL,
                        "files": filesURL,
                        "time": Date().timeIntervalSince1970,
                        "stars": [],
                        "responses": [],
                        "views": [userID],
                        "date": Date().getFormattedDate(format: "d MMM, HH:mm")
                        
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                            self.showPV = false
                            observeManager.amountPercentage = -1
                            completionHandler(.failure("Error with creating post: \(err.localizedDescription)"))
                        } else {
                            observeManager.amountPercentage = 100
                            completionHandler(.success(orderID))
                        }
                    }
                    
                    
                }.store(in: &self.cancellabels)


        
    }
    
    func createFreelanceService(owner userID: String,
                              name: String,
                              description: String,
                              priceType: FreelancePriceType,
                              price: String,
                              per: SpecifiedPriceType,
                              topic: FreelanceTopic,
                              devSubtopic: FreelanceSubTopic.FreelanceDevelopingSubTopic,
                              adminSubtopic: FreelanceSubTopic.FreelanceAdministrationSubTropic,
                              designSubtopic: FreelanceSubTopic.FreelanceDesignSubTopic,
                              testSubtopic: FreelanceSubTopic.FreelanceTestingSubTopic,
                              languages: [LangDescriptor],
                              coreSkills: String,
                              previews: [UIImage]?,
                              observeManager: FirebaseFilesUploadingProgreessManager,
                              completionHandler: @escaping (Result<String, Error>) -> Void) -> Void {
        guard Reachability.isConnectedToNetwork() else { observeManager.amountPercentage = -1; return }
        self.uploadPublisher(previews: previews ?? [], observeManager: observeManager, folder: .service)
                .sink { res in
                    if case .failure = res {
                        print(res)
                    }
                } receiveValue: { (previewsURL) in
                    let serviceID: String = FSManager.generate64CharactersLongID()
                    var subtopic: String = ""
                    switch topic {
                    case .Administration:
                        subtopic = adminSubtopic.rawValue
                    case .Design:
                        subtopic = designSubtopic.rawValue
                    case .Development:
                        subtopic = devSubtopic.rawValue
                    case .Testing:
                        subtopic = testSubtopic.rawValue
                    case .all:
                        subtopic = "All"
                    }
                    
                    
                    self.db.collection("FreelanceService").document(serviceID).setData([
                        
                        "id" : serviceID,
                        "owner": userID,
                        "name": name,
                        "description": description,
                        "priceType": priceType == .negotiated ? "Negotiated" : "Specified",
                        "price": price,
                        "pricePer": per.rawValue,
                        "topic": topic.rawValue,
                        "subtopic": subtopic,
                        "langdescriptors": languages.map({$0.rawValue}),
                        "coreskills": coreSkills,
                        "previews": previewsURL,
                        "time": Date().timeIntervalSince1970,
                        "stars": [],
                        "responses": [],
                        "views": [userID],
                        "date": Date().getFormattedDate(format: "d MMM, HH:mm")
                        
                    ]) { err in
                
                        if let err = err {
                            print("Error writing document: \(err)")
                            self.showPV = false
                            observeManager.amountPercentage = -1
                            completionHandler(.failure("Error with creating post: \(err.localizedDescription)"))
                        } else {
                            observeManager.amountPercentage = 100
                            completionHandler(.success(serviceID))
                        }
                    }
                    
                    
                }.store(in: &self.cancellabels)


        
    }
    
    func createPost(owner userID: String, text: String, image: UIImage?=nil, completion: @escaping (Result<String, Error>) -> Void) {
        
        let id = FSManager.generate64CharactersLongID()
        
        // If post has image
        if let image = image {
            self.upload(postImage: image, id: id) { result in
                switch result {
                    
                case .success(let url):
                    self.db.collection("Posts").document(id).setData([
                        
                        "id" : id,
                        "owner": userID,
                        "image": url,
                        "body": text,
                        "time": Date().timeIntervalSince1970,
                        "stars": [],
                        "date": Date().getFormattedDate(format: "d MMM, HH:mm")
                        
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                            self.showPV = false
                            completion(.failure("Error with creating post: \(err.localizedDescription)"))
                        } else {
                            completion(.success(id))
                        }
                    }
                case .failure(let err):
                    print("FSManager | \(err)")
                    completion(.failure("Error with creating post: \(err.localizedDescription)"))
                    self.showPV = false
                }
            }
        } else {
            self.db.collection("Posts").document(id).setData([
                
                "id" : id,
                "owner": userID,
                "body": text,
                "time": Date().timeIntervalSince1970,
                "stars": [],
                "date": Date().getFormattedDate(format: "d MMM, HH:mm")
                
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    self.showPV = false
                    completion(.failure("Error with creating post: \(err.localizedDescription)"))
                } else {
                    completion(.success(id))
                }
            }
        }
    }
    
    func createUser(withID id: String, email : String, username: String, name: String, surname: String, mates: Int = 0, reputation : Int = 0, image: UIImage?, language: PLanguages.RawValue) -> Void {
        self.showPV = true
        
        guard let image = image else {
            print("Image didn't load")
            self.showPV = false
            return
        }
        
        self.upload(avatar: image) { (result) in
            switch result {
                
            case .success(let url):
                self.avatarURL = url.absoluteString
                self.db.collection("Users").document(id).setData([
                    
                    "email" : email,
                    "username": username,
                    "name": name,
                    "surname": surname,
                    "mates": mates,
                    "avatarURL": self.avatarURL,
                    "reputation": reputation,
                    "language": language,
                    "projects": [],
                    "posts": [],
                    "chats": [],
                    "bio": "",
                    "registerDate": Date().getFormattedDate(format: "dd MMMM yyyy")
                    
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                        self.showPV = false
                    } else {
                        
                        self.userUsername = username
                        self.userFirstName = name
                        self.userLastName = surname
                        self.userMates = String(mates)
                        self.userReputation = String(reputation)
                        self.userLanguage = language
                        self.userBio = ""
                        self.userProjects = []
                        self.userPosts = []
                        self.userRegisterDate = ""
                        
                        print("Document successfully written!")
                        self.userExists = true
                        self.showPV = false
                    }
                }
            case .failure(let err):
                print(err)
                self.showPV = false
            }
        }
    }
    
    func sentMessage(chat chatID: String, body: String, image: UIImage? = nil, completion: @escaping (Result<String, Error>) -> Void) -> Void {
        
        
        
        let date: String = Date().getFormattedDate(format: "dd.MM.yyyy")
        let hourAndMinute: String = Date().getFormattedDate(format: "HH:mm")
        let id: String = FSManager.generate64CharactersLongID()
        
        if let image = image {
            
            self.upload(messageImage: image, messageID: id) { result in
                switch result {
                    
                case .success(let url):
                    self.db.collection("Messages").document(id).setData([
                        
                        "id": id,
                        "chatID": chatID,
                        "body": body,
                        "date": date,
                        "dayTime": hourAndMinute,
                        "didEdit": "false",
                        "image": "\(url)",
                        "sender": self.loginUserID,
                        "timeSince1970": String(Date().timeIntervalSince1970),
                        "whoHasRead": []
                        
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                            self.showPV = false
                            completion(.failure("Error with creating message: \(err.localizedDescription)"))
                        } else {
                            self.db.collection("Chats").document(chatID).updateData([
                                
                                "messages": FieldValue.arrayUnion([id]),
                                "lastMessage": id
                                
                            ]) { err in
                                if let err = err {
                                    print("Error writing document: \(err)")
                                    self.showPV = false
                                    completion(.failure("Error with creating message: \(err.localizedDescription)"))
                                } else {
                                    print("Successfully writing message")
                                    self.showPV = false
                                    completion(.success(id))
                                }
                                
                            }
                            completion(.success(id))
                        
                        }
                    }
                case .failure(let err):
                    print("FSManager | \(err)")
                    completion(.failure("Error with creating message: \(err.localizedDescription)"))
                    self.showPV = false
                }
                
            }
            
        } else {
            
            self.db.collection("Messages").document(id).setData([
                
                "id": id,
                "chatID": chatID,
                "body": body,
                "date": date,
                "dayTime": hourAndMinute,
                "didEdit": "false",
                "sender": self.loginUserID,
                "timeSince1970": String(Date().timeIntervalSince1970),
                "whoHasRead": [],
                "image": ""
                
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    self.showPV = false
                    completion(.failure("Error with creating message: \(err.localizedDescription)"))
                } else {
                    
                    self.db.collection("Chats").document(chatID).updateData([
                        
                        "messages": FieldValue.arrayUnion([id]),
                        "lastMessage": id
                        
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                            self.showPV = false
                            completion(.failure("Error with creating message: \(err.localizedDescription)"))
                        } else {
                            print("Successfully writing message")
                            self.showPV = false
                            completion(.success(id))
                        }
                        
                    }
                    completion(.success(id))
                }
            }
        }
        
        
    }
    
    // MARK: - Check for user existing
    func isUserExist() {
        let docRef = db.collection("Users").document(self.userID)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.userExists = true
            } else {
                self.userExists = false
            }
        }
    }
    
    func newsPostIsServed(id: String, completion: @escaping (Bool) -> Void) {
        let docRef = db.collection("NewsPosts").document(id)
        docRef.getDocument { (doc, err) in
            if let doc = doc, doc.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    
    
    // MARK: -  Deploy project on FireBase storage
    func deploy(project: UOProject, completion: @escaping (Result<String, Error>) -> Void) {
        self.showPV = true
        print("deploying with ID:")
        print(project.id)
        self.db.collection("Projects").document(project.id).setData([
            
            "id": project.id,
            "name": project.name!,
            "description": project.description!,
            "imageURL": project.imageURL!,
            "link": project.link!
            
        ]) { err in
            if let err = err {
                completion(.failure(err))
                self.showPV = false
            } else {
                completion(.success("Success"))
                self.showPV = false
            }
        }
    }
    
//    func getReputation(withID id: String) -> Void {
//        db.collection("Users").document(id)
//            .addSnapshotListener { documentSnapshot, error in
//              guard let document = documentSnapshot else {
//                print("Error fetching document: \(error!)")
//                return
//              }
//              guard let data = document.data() else {
//                print("Document data was empty.")
//                return
//              }
//              print("Current data: \(data)")
//              print(data["reputation"])
//              self.userReputation = String((data["reputation"] as! Int))
//                
//            }
//    }
    
    // MARK: - Add functions
    func add(project id: String, to userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let docRef = db.collection("Users").document(userId)
        
        // Atomically add a new region to the "regions" array field.
        docRef.updateData([
            "projects": FieldValue.arrayUnion([id])
        ]) { err in
            if let err = err {
                completion(.failure("Can not update user's Data: \(err.localizedDescription)"))
            } else {
                completion(.success("Succes"))
            }
        }
    }
    
    func add(post id: String, to userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let docRef = db.collection("Users").document(userId)
        
        // Atomically add a new region to the "regions" array field.
        docRef.updateData([
            "posts": FieldValue.arrayUnion([id])
        ]) { err in
            if let err = err {
                completion(.failure("Can not update user's Data: \(err.localizedDescription)"))
            } else {
                completion(.success("Succes"))
            }
        }
    }
    
    func add(reader id: String, toMessage msgID: String, completion: @escaping (Result<String, Error>) -> Void) -> Void {
        let ownerRef = db.collection("Messages").document(msgID)
        
        ownerRef.updateData([
            "whoHasRead": FieldValue.arrayUnion([id])
        ]) { err in
            if let err = err {
                completion(.failure(err))
            } else {
                completion(.success("Successfully marked message \(msgID) as read by user: \(id)"))
            }
        }
    }
    
    // MARK: - Increment & Decrement functions
    
    func unlike(profilePost postID: String, user userID: String, owner ownerID: String) {
        let postsRef = db.collection("Posts").document(postID)
        let ownerRef = db.collection("Users").document(ownerID)
        
        postsRef.updateData([
            "stars": FieldValue.arrayRemove([userID])
        ]) { err in
            if let err = err {
                print(err)
            } else {
                ownerRef.updateData([
                    "reputation": FieldValue.increment(Int64(-1))
                ])
            }
        }
    }
    
    func unlike(newsPost postID: String, user userID: String) {
        let postsRef = db.collection("NewsPosts").document(postID)
        
        postsRef.updateData([
            "upvotes": FieldValue.arrayRemove([userID]),
            "downvotes": FieldValue.arrayUnion([userID])
        ]) { err in
            if let err = err {
                print(err)
            } else {
                print("Success")
            }
        }
    }
    
    func like(profilePost postID: String, user userID: String, owner ownerID: String) {
        let postsRef = db.collection("Posts").document(postID)
        
        let ownerRef = db.collection("Users").document(ownerID)
        
        
        
        postsRef.updateData([
            "stars": FieldValue.arrayUnion([userID])
        ]) { err in
            if let err = err {
                print(err)
            } else {
                ownerRef.updateData([
                    "reputation": FieldValue.increment(Int64(1))
                ]) { err in
                    if let err = err {
                        print("ERROR: \(err)")
                    }
                    
                }
            }
        }
    }
    
    func like(newsPost postID: String, user userID: String) {
        let postsRef = db.collection("NewsPosts").document(postID)
        
        postsRef.updateData([
            "upvotes": FieldValue.arrayUnion([userID]),
            "downvotes": FieldValue.arrayRemove([userID])
        ]) { err in
            if let err = err {
                print(err)
            } else {
                print("Success")
            }
        }
    }
    
    // MARK: - Override/Update/Replace functions
    
    func editMessage(_ id: String, body: String, image: UIImage? = nil, messageImageID: String = "", imageDidChange: Bool, completion: @escaping (Result<String, Error>) -> Void) -> Void {
        // Если сообщение с изображением
        if let image = image {
            // Если изображение было изменено, то обновляем его
            if imageDidChange {
                self.upload(messageImage: image, messageID: id) { result in
                    switch result {
                    case .success(let url):
                        self.db.collection("Messages").document(id).updateData([
                            "didEdit": "true",
                            "body": body,
                            "image": "\(url)"
                        ]){ err in
                            if let err = err {
                                completion(.failure(err))
                            }
                            completion(.success("Succesfully changed image&data."))
          
                        }
                    case .failure(let failure):
                        completion(.failure(failure))
                    }
                }
                // Если изображение не менялось, то оставляем всё как было
            } else {
                self.db.collection("Messages").document(id).updateData([
                    "didEdit": "true",
                    "body": body,
                ]){ err in
                    if let err = err {
                        completion(.failure(err))
                    }
                    completion(.success("Succesfully cheanged message."))
  
                }
            }
            
        } else {
            self.remove(messageImage: messageImageID) { _ in
                self.db.collection("Messages").document(id).updateData([
                    "didEdit": "true",
                    "body": body,
                    "image": ""
                ]) { err in
                    if let err = err {
                        completion(.failure(err))
                    }
                    completion(.success("Succesfully removed image&changed data."))
  
                }
            }
        }
    }
    
    func updateUser(withID id: String, email : String, username: String, name: String, surname: String, mates: Int = 0, reputation : Int = 0, image: UIImage?, language: PLanguages.RawValue, bio: String, projects: [String]) -> Void {
        self.showPV = true
        
        if let image = image {
            self.upload(avatar: image) { (result) in
                switch result {
                    
                case .success(let url):
                    self.avatarURL = url.absoluteString
                    self.db.collection("Users").document(id).updateData([
                        
                        "email" : email,
                        "username": username,
                        "name": name,
                        "surname": surname,
                        "mates": mates,
                        "avatarURL": self.avatarURL,
                        "language": language,
                        "projects": projects,
                        "bio": bio
                        
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                            self.showPV = false
                        } else {
                            print("Document successfully updated!")
                            
                            self.userUsername =  username
                            self.userFirstName = name
                            self.userLastName = surname
                            self.userMates = String(mates)
                            self.userLanguage = language
                            self.userBio = bio
                            self.userProjects = projects
                            self.userPosts = []
                            
                            self.userExists = true
                            self.showPV = false
                        }
                    }
                case .failure(let err):
                    print(err)
                    self.showPV = false
                }
            }
            
        } else {
            self.db.collection("Users").document(id).updateData([
                
                "email" : email,
                "username": username,
                "name": name,
                "surname": surname,
                "mates": mates,
                "avatarURL": self.avatarURL,
                "language": language,
                "bio": bio,
                "projects": projects
                
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    self.showPV = false
                } else {
                    print("Document successfully written!")
                    
                    self.userUsername =  username
                    self.userFirstName = name
                    self.userLastName = surname
                    self.userMates = String(mates)
                    self.userLanguage = language
                    self.userBio = bio
                    self.userProjects = projects
                    
                    self.userExists = true
                    self.showPV = false
                }
            }
        }
        self.showPV = false
    }

    func updatePost(id: String, text: String, image: UIImage?, completion: @escaping (Result<String, Error>) -> Void) -> Void {
        
        // If post has image
        self.remove(postImage: id) { result in
            if let image = image {
                
                self.upload(postImage: image, id: id) { result in
                    switch result {
                        
                    case .success(let url):
                        self.db.collection("Posts").document(id).updateData([
                            
                            "image": url,
                            "body": text,
                            
                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                                self.showPV = false
                                completion(.failure("Error with creating post: \(err.localizedDescription)"))
                            } else {
                                completion(.success(id))
                            }
                        }
                    case .failure(let err):
                        print("FSManager | \(err)")
                        completion(.failure("Error with creating post: \(err.localizedDescription)"))
                        self.showPV = false
                    }
                    
                }
                
            } else {
                
                self.db.collection("Posts").document(id).updateData([
                    
                    "body": text,
                    "image": FieldValue.delete()
                    
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                        self.showPV = false
                        completion(.failure("Error with creating post: \(err.localizedDescription)"))
                    } else {
                        completion(.success(id))
                    }
                }
            }
            
        }
    }
    
    func overrideProject(_ project: UOProject, completion: @escaping (Result<String, Error>) -> Void) {
        self.showPV = true
        self.db.collection("Projects").document(project.id).setData([
            
            "id": project.id,
            "name": project.name!,
            "description": project.description!,
            "imageURL": project.imageURL!,
            "link": project.link!
            
        ]) { err in
            if let err = err {
                completion(.failure(err))
                self.showPV = false
            } else {
                completion(.success("Success"))
                self.showPV = false
            }
        }
    }
    
    func replaceProjects(owner id: String, data: [String]) { }
    
    
    // MARK: - Functions for getting stuff

  
  
    
    @MainActor func loadIdeas(sortBy sortParameter: FirestoreSortDescriptor,
                              category: FreelanceTopic,
                              subDevCategory: FreelanceSubTopic.FreelanceDevelopingSubTopic,
                              subAdminCategory: FreelanceSubTopic.FreelanceAdministrationSubTropic,
                              subDesignCategory: FreelanceSubTopic.FreelanceDesignSubTopic,
                              subTestCategory: FreelanceSubTopic.FreelanceTestingSubTopic,
                              difficultLevel: IdeaDifficultyLevel,
                              languages: Array<LangDescriptor>,
                              completion: @escaping (_ ideas: Array<Idea>
                              ) -> Void) -> Void {
        
        
        var difLabel: String? = difficultLevel == .all ? nil : difficultLevel.rawValue
        var langDescriptors: Array<String>? = languages == [LangDescriptor.None] ? nil : languages.map({$0.rawValue})
        
        
        func containsCommonElement(array1: [String], array2: [String]) -> Bool {
          let set1 = Set(array1)
          let set2 = Set(array2)
          
          return !set1.isDisjoint(with: set2)
        }

        
        
        db.collection("Ideas").order(by: sortParameter.rawValue, descending: true)
            .getDocuments(completion: { querySnapshot, error in
                
                guard let documents = querySnapshot?.documents else {
                     print("Error fetching documents: \(error!)")
                     return
                  }
                
                var ideas: Array<Idea> = Array<Idea>()
                
                for i in 0 ..< documents.count {
                    let dictData = documents[i].data()
                      guard let id = dictData["id"] as? String,
                            
                            let author = dictData["owner"] as? String,
                            let title = dictData["title"] as? String,
                            let text = dictData["text"] as? String,
                            let category = dictData["category"] as? String,
                            let subcategory = dictData["subcategory"] as? String,
                            let difficultylevel = dictData["difficultylevel"] as? String,
                            let langdescriptors = dictData["langdescriptors"] as? Array<String>,
                            let coreskills = dictData["coreskills"] as? String,
                            let previews = dictData["previews"] as? Array<String>,
                            let files = dictData["files"] as? Array<String>,

                            let stars = dictData["stars"] as? Array<String>,
                            let responses = dictData["responses"] as? Array<String>,
                            let views = dictData["views"] as? Array<String>,
                            let comments = dictData["comments"] as? Array<String>,
                            let saves = dictData["saves"] as? Array<String>,
                            let date = dictData["date"] as? String else {
                          print("Invalid Document !!!")
                          return
                      }
                    let newIdea = Idea(id: id, author: author, title: title, text: text, category: category, subcategory: subcategory, difficultyLevel: difficultylevel, skills: coreskills, languages: langdescriptors, images: previews, files: files, comments: comments, stars: stars, responses: responses, views: views, saves: saves, dateOfPublish: date)
                    ideas.append(newIdea)
                }
                
                // Фильтр по категориям
                if category != .all {
                    ideas = ideas.filter({ idea in idea.category == category.rawValue })
                    var subcategory: String? = nil
                    switch category {
                    case .all:
                        subcategory = nil
                    case .Administration:
                        
                        subcategory = subAdminCategory == .all ? nil : subAdminCategory.rawValue
                    case .Design:
                        subcategory = subDesignCategory == .all ? nil : subDesignCategory.rawValue
                    case .Development:
                        subcategory = subDevCategory == .all ? nil : subDevCategory.rawValue
                    case .Testing:
                        subcategory = subTestCategory == .all ? nil : subTestCategory.rawValue
                    }
                    if subcategory != nil { ideas = ideas.filter({ idea in idea.subcategory == subcategory }) }
                }
            
                // Фильтрация по уровню слолжности
                if difLabel != nil {
                    ideas = ideas.filter({ idea in idea.difficultyLevel == difLabel!})
                }
                
                // Фильтрация по языкам
                if langDescriptors != nil {
                    ideas = ideas.filter({ idea in
                        !Set(idea.languages).isDisjoint(with: Set(langDescriptors!))
//                        containsCommonElement(array1: idea.languages, array2: languages)
                    })
                }
            
    
                completion(ideas)
                
            })
//                   .addSnapshotListener { (querySnapshot, error) in
//                   self.messages = []
//                   if let error = error {
//                       print(error.localizedDescription)
//                   } else {
//                       if let snapshotDocuments = querySnapshot?.documents {
//
//                           snapshotDocuments.forEach { doc in
//                               print(doc.data())
//                               let data = doc.data()
//                               if let sender = data[K.FStore.senderField] as? String, let body = data[K.FStore.bodyField] as? String {
//                                   let newMessage = Message(sender: sender, body: body)
//                                   self.messages.append(newMessage)
//
//                                   DispatchQueue.main.async {
//                                       self.tableView.reloadData()
//                                       let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
//                                       self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//
//                                   }
//                               }
//                           }
//                       }
//                   }
//               }
        
    }
    
   
//    @MainActor func getMessageInfoNonAsync(id: String) -> Dictionary<String, Any>? {
//        if id != "" {
//            var isEmpty : Bool = true
//            var res: Dictionary<String, Any> = Dictionary<String, Any>()
//            
//            db.collection("Messages").document(id) .addSnapshotListener { documentSnapshot, error in
//                guard let document = documentSnapshot else {
//                    print("Document is not a document")
//                    waitPlease = false
//                    return
//                }
//                guard let data = document.data() else {
//                    print("data is not data")
//                    waitPlease = false
//                    return
//                }
//                
//                res["id"] = (data["id"] as! String)
//                res["chatID"] = (data["chatID"] as! String)
//                res["sender"] = (data["sender"] as? String)
//                res["timeSince1970"] = (data["timeSince1970"] as! String)
//                res["date"] = (data["date"] as! String) // dd.mm.yyyy
//                res["dayTime"] = (data["dayTime"] as! String)
//                res["body"] = (data["body"] as! String)
//                res["didEdit"] = (data["didEdit"] as! String)
//                res["whoHasRead"] = (data["whoHasRead"] as! [String])
//                res["image"] = (data["image"] as! String)
//                print(res)
//                isEmpty = false
//                
//            }
//            return nil
//        }
//        return nil
//    }
    
    
    func getNewsPostInfo(id: String, completion: @escaping (Result<Dictionary<String, Any>, Error>) -> Void) -> Void {
        if id != "" {
            var res: Dictionary<String, Any> = Dictionary<String, Any>()
            self.db.collection("NewsPosts").document(id).addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    completion(.failure("Error fetching document: \(error!.localizedDescription)"))
                    return
                }
                guard let data = document.data() else {
                    completion(.failure("Document data was empty."))
                  return
                }
                res["id"] = (data["id"] as! String)
                res["upvotes"] = (data["upvotes"] as! [String])
                res["downvotes"] = (data["downvotes"] as! [String])
                res["comments"] = (data["comments"] as! [String])
                
                completion(.success(res))
            }
        } else {
            completion(.failure("The document does not exists"))
        }
    }
    
    
    func getMessageInfo(id: String, completion:  @escaping (Result<Dictionary<String, Any>, Error>) -> Void) async -> Void {
        print(id)
        if id != "" {
            var res: Dictionary<String, Any> = Dictionary<String, Any>()
            self.db.collection("Messages").document(id) .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    completion(.failure("Error fetching document: \(error!)"))
                  return
                }
                guard let data = document.data() else {
                    completion(.failure("Document data was empty."))
                  return
                }
                    
                    res["id"] = (data["id"] as? String)
                    res["chatID"] = (data["chatID"] as! String)
                    res["sender"] = (data["sender"] as! String)
                    res["timeSince1970"] = (data["timeSince1970"] as! String)
                    res["date"] = (data["date"] as! String) // dd.mm.yyyy
                    res["dayTime"] = (data["dayTime"] as! String)
                    res["body"] = (data["body"] as! String)
                    res["didEdit"] = (data["didEdit"] as! String)
                    res["whoHasRead"] = (data["whoHasRead"] as! [String])
                    res["image"] = (data["image"] as! String)
                
                    completion(.success(res))
            }
        } else {
            completion(.failure("Incorrect ID"))
        }
    }
    

    func getChatInfo(of: ChatInfoProperties.RawValue, by id: String, completion: @escaping (Result<Dictionary<String, Any>, Error>) -> Void) async -> Void {
        if id != "" {
            var res: Dictionary<String, Any> = Dictionary<String, Any>()
            db.collection("Chats").document(id) .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    completion(.failure("Error fetching document: \(error!)"))
                  return
                }
                guard let data = document.data() else {
                    completion(.failure("Document data was empty."))
                  return
                }
                
                res["id"] = (data["id"] as! String)
                res["members"] = (data["members"] as! [String])
                res["lastMessage"] = (data["lastMessage"] as? String) ?? "No messages"
                res["name"] = (data["name"] as! String)
                res["messages"] = (data["messages"] as? [String]) ?? []
                
                completion(.success(res))
            }
        } else {
            completion(.failure("Incorrect ID"))
        }
    }

    func getUserChats(completion: @escaping (Result<Array<String>, Error>) -> Void) async -> Void {
        if self.loginUserID != "" {
            db.collection("Users").document(self.loginUserID)
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        completion(.failure("Error fetching document: \(error!)"))
                      return
                    }
                    guard let data = document.data() else {
                        completion(.failure("Document data was empty."))
                      return
                    }
                    completion(.success(data["chats"] as! [String]))
                }
//            docRef.getDocument { (document, error) in
//                if let document = document, document.exists {
//                    if let chats = (document.data()?["chats"] as? Array<String>) {
//                        completion(.success(chats))
//                    } else { completion(.failure("User doesn't have chats field."))}
//                } else {
//                    completion(.failure("This document does not exist."))
//                }
//            }
        } else {
            completion(.failure("Incorrect ID"))
        }
        
    }
    
    func getUsersData(withID id: String) -> Void {

        if id != "" {
            
            db.collection("Users").document(id)
                .addSnapshotListener { documentSnapshot, error in
                  guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                  }
                  guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                  }
                  print("Current data: \(data)")
//                  print(data["reputation"])
                            
                          
                            self.userUsername = (data["username"] as! String)
                            self.userFirstName = (data["name"] as! String)
                            self.userLastName = (data["surname"] as! String)
                            self.userMates = String((data["mates"] as! Int))
                            self.userReputation = String((data["reputation"] as! Int))
                            self.userLanguage = (data["language"] as! String)
                            self.userBio = (data["bio"] as! String)
                            self.userProjects = (data["projects"] as! [String])
                            self.userPosts = (data["posts"] as! [String]).reversed()
                            self.avatarURL = (data["avatarURL"] as! String)
                            self.userRegisterDate = (data["registerDate"] as! String)

                }
            
//            let docRef = db.collection("Users").document(id)
//            docRef.getDocument { (document, error) in
//                if let document = document, document.exists {
//
//                    self.userUsername = (document.data()?["username"] as? String) ?? "username"
//                    self.userFirstName = (document.data()?["name"] as? String) ?? "name"
//                    self.userLastName = (document.data()?["surname"] as? String) ?? "surname"
//                    self.userMates = (document.data()?["mates"] as? String) ?? "0"
//                    self.userReputation = "\(document.data()?["reputation"] as! Int64)"
//                    self.userLanguage = (document.data()?["language"] as? String) ?? PLanguages.swift.rawValue
//                    self.userBio = (document.data()?["bio"] as? String) ?? "Bio"
//                    self.userProjects = (document.data()?["projects"] as? [String]) ?? []
//                    self.userPosts = (document.data()?["posts"] as? [String])?.reversed() ?? []
//                    self.avatarURL = (document.data()?["avatarURL"] as? String) ?? "AvatarURL"
//                    self.userRegisterDate = (document.data()?["registerDate"] as? String) ?? "01 January 1970"
//
//
//                }
//            }
        
            
            
            
        }
    }
    
    func getUserAvatar(withID id: String, completion: @escaping (Result<String, Error>) -> Void) -> Void {
        if id != "" {
            let docRef = db.collection("Users").document(id)
            docRef.getDocument { (document, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let document = document, document.exists {
                    completion(.success((document.data()?["avatarURL"] as! String)))
                }
            }
        }
    }
    
    func getPost(by id: String, completion: @escaping (Result<Dictionary<String, Any>, Error>) -> Void) async -> Void {
        
        var res : Dictionary<String, Any> = Dictionary<String, Any>()
        if id != "" {
            let docRef = db.collection("Posts").document(id).addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                  print("Error fetching document: \(error!)")
                  return
                }
                guard let data = document.data() else {
                  print("Document data was empty.")
                  return
                }
                
                    res["body"] = (data["body"] as! String)
                    res["date"] = (data["date"] as! String)
//                    res["time"] = (data["time"] as! Int)
                    if let url = (data["image"] as?  String) { res["image"] =  url }
                    res["stars"] = (data["stars"] as!  [String])
                    res["owner"] = (data["owner"] as!  String)
                    completion(.success(res))
            }
        } else {
            completion(.failure("Incorrect id"))
        }
        
    }
    
    func getUserName(forID id: String, completion: @escaping (Result<String, Error>) -> Void) async {
        
        let docRef = db.collection("Users").document(id)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                if let username = (document.data()?["username"] as? String) {
                    completion(.success(username))
                } else { completion(.failure("Username")) }
                
            } else { completion(.failure("Username")) }
        }
    }

    func getPostImage(from url: String, completion: @escaping (Result<UIImage, Error>) -> Void) async {
        print(url)
        let ref = Storage.storage().reference().child("PostPreviews").child(url)
        ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                completion(.failure("Could not load the image: \(error)"))
            } else {
                let image = UIImage(data: data!)!
                completion(.success(image))
            }
        }
    }
    
    func getProjectImage(from url: String, completion: @escaping (Result<UIImage, Error>) -> Void) async {
        print("Project url: \(url)")
        let ref = Storage.storage().reference().child("ProjectPreviews").child(url)
        ref.getData(maxSize: 1024 * 1024) { data, error in
            if let error = error {
                completion(.failure("Could not load the image: \(error)"))
            } else {
                let image = UIImage(data: data!)!
                completion(.success(image))
            }
        }
    }
    
    
    func getProject(by id: String, completion: @escaping (Result<Dictionary<String, String>, Error>) -> Void) -> Void {
        var res : Dictionary<String, String> = Dictionary<String, String>()
        if id != "" {
            let docRef = db.collection("Projects").document(id)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    res["name"] = (document.data()?["name"] as? String) ?? "Project name"
                    res["description"] = (document.data()?["description"] as? String) ?? "Project description"
                    res["imageURL"] = (document.data()?["imageURL"] as? String) ?? "Project imageURL"
                    res["link"] = (document.data()?["link"] as? String) ?? "Project link"
                    completion(.success(res))
                } else {
                    completion(.failure("The project does not exist"))
                }
            }
        } else {
            completion(.failure("Incorrect id"))
        }
    }
}

