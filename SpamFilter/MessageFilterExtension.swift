//
//  MessageFilterExtension.swift
//  SpamFilter
//
//  Created by Ethan Mohammed on 4/12/23.
//

import IdentityLookup
import TensorFlowLite
import CoreData

extension Data {
  init<T>(copyingBufferOf array: [T]) {
    self = array.withUnsafeBufferPointer(Data.init)
  }
}

extension Array {
  init?(unsafeData: Data) {
    guard unsafeData.count % MemoryLayout<Element>.stride == 0 else { return nil }
    #if swift(>=5.0)
    self = unsafeData.withUnsafeBytes { .init($0.bindMemory(to: Element.self)) }
    #else
    self = unsafeData.withUnsafeBytes {
      .init(UnsafeBufferPointer<Element>(
        start: $0,
        count: unsafeData.count / MemoryLayout<Element>.stride
      ))
    }
    #endif
  }
}

final class MessageFilterExtension: ILMessageFilterExtension {}

extension MessageFilterExtension: ILMessageFilterQueryHandling {
    
    func handle(_ queryRequest: ILMessageFilterQueryRequest, context: ILMessageFilterExtensionContext, completion: @escaping (ILMessageFilterQueryResponse) -> Void) {
        let offlineAction = self.offlineAction(for: queryRequest)
        
        switch offlineAction {
            // Filter messages based on the results of offlineAction
        case .allow, .junk, .promotion, .transaction:
            let response = ILMessageFilterQueryResponse()
            response.action = offlineAction
            completion(response)
            
            // We don't need to send anything over the network
        case .none:
            let response = ILMessageFilterQueryResponse()
            response.action = .none
            completion(response)
            
        @unknown default:
            break
        }
    }
    
    private func offlineAction(for queryRequest: ILMessageFilterQueryRequest) -> ILMessageFilterAction {
        
        guard let messageSender = queryRequest.sender else {
            return .none
        }
        
        guard let messageBody = queryRequest.messageBody else {
            return .none
        }
        
        //check if number is blocked
        let blockNumber = numberBlock(messageSender: messageSender)
        if (blockNumber == true) {
            return .junk
        }
        
        //number allowed
        let allowNumber = numberAllow(messageSender: messageSender)
        if (allowNumber == true) {
            let actionPromo = hasPromo(messageBody: messageBody)
            if (actionPromo == true)
            {
                return .promotion
            }
            else
            {
                //check if it's a transaction
                let actionTransaction = hasTransaction(messageBody: messageBody)
                if (actionTransaction == true) {
                    return .transaction
                } else {
                    return .none
                }
            }
        }
        
        //check if keyword in message is blocked
        let blockKeyword = keywordBlock(messageBody: messageBody)
        if (blockKeyword == true) {
            return .junk
        }
        
        //keyword allowed
        let allowKeyword = keywordAllow(messageBody: messageBody)
        if (allowKeyword == true) {
            let actionPromo = hasPromo(messageBody: messageBody)
            if (actionPromo == true)
            {
                return .promotion
            }
            else
            {
                //check if it's a transaction
                let actionTransaction = hasTransaction(messageBody: messageBody)
                if (actionTransaction == true) {
                    return .transaction
                } else {
                    return .none
                }
            }
        }
        
        //check model
        //ML Model
        let result = analyzeMessage(messageBody: messageBody)
        //it's spam
        if (result == true)
        {
            return .junk
        }
        //it's not spam
        else
        {
            //check if it's a promo
            let actionPromo = hasPromo(messageBody: messageBody)
            if (actionPromo == true)
            {
                return .promotion
            }
            else
            {
                //check if it's a transaction
                let actionTransaction = hasTransaction(messageBody: messageBody)
                if (actionTransaction == true) {
                    return .transaction
                } else {
                    return .none
                }
            }
        }
    }
}
    

func numberAllow(messageSender: String) -> Bool {
    let context = SharedPersistentContainer.shared.persistentContainer.viewContext
    let request: NSFetchRequest<AllowNums> = AllowNums.fetchRequest()
    
    do {
        let model = try context.fetch(request)
        let senderNumbers = messageSender.filter("0123456789".contains)
        for item in model {
            let filteredNumber = item.number!.filter("0123456789".contains)
            if (senderNumbers.contains(filteredNumber)) {
                return true
            }
        }
    } catch {
        print("Error fetching objects: \(error)")
    }
    
    return false
}

func numberBlock(messageSender: String) -> Bool {
    let context = SharedPersistentContainer.shared.persistentContainer.viewContext
    let request: NSFetchRequest<BlockNums> = BlockNums.fetchRequest()
    
    do {
        let model = try context.fetch(request)
        let senderNumbers = messageSender.filter("0123456789".contains)
        for item in model {
            let filteredNumber = item.number!.filter("0123456789".contains)
            if (senderNumbers.contains(filteredNumber)) {
                return true
            }
        }
    } catch {
        print("Error fetching objects: \(error)")
    }
    
    return false
}

func keywordBlock(messageBody: String) -> Bool {
    let context = SharedPersistentContainer.shared.persistentContainer.viewContext
    let request: NSFetchRequest<BlockKeywords> = BlockKeywords.fetchRequest()

    do {
        let model = try context.fetch(request)
        let filteredMessageBody = messageBody.lowercased()
        for keyword in model {
            if (filteredMessageBody.contains(keyword.keyword!)) {
                return true
            }
        }
    } catch {
        print("Error fetching objects: \(error)")
    }
    return false
}

func keywordAllow(messageBody: String) -> Bool {
    let context = SharedPersistentContainer.shared.persistentContainer.viewContext
    let request: NSFetchRequest<AllowKeywords> = AllowKeywords.fetchRequest()

    do {
        let model = try context.fetch(request)
        let filteredMessageBody = messageBody.lowercased()
        for keyword in model {
            if (filteredMessageBody.contains(keyword.keyword!)) {
                return true
            }
        }
    } catch {
        print("Error fetching objects: \(error)")
    }
    return false
}

func hasPromo(messageBody: String) -> Bool {
    let promos = [
        "coupon",
        "coupons",
        "sale",
        "sales",
        "discount",
        "discounts",
        "charity",
        "charities",
        "fundraiser",
        "fundraisers",
    ]
    
    let filteredMessageBody = messageBody.lowercased()
    for promo in promos {
        if (filteredMessageBody.contains(promo)) {
            return true
        }
    }
    return false
}

func hasTransaction(messageBody: String) -> Bool {
    let transactions = [
        "code",
        "password",
        "reset",
        "authentication",
        "order",
        "orders",
        "verification",
        "verifications",
        "activate",
        "reservation",
        "reservations",
        "appointment",
        "appointments",
        "yelp",
        "uber",
        "doordash",
        "grubhub",
        "postmates",
        "postmate",
    ]
    
    let filteredMessageBody = messageBody.lowercased()
    for transaction in transactions {
        if (filteredMessageBody.contains(transaction)) {
            return true
        }
    }
    return false
}

    
    func convert_sentence(sentence: String) -> [Int32]{
        // This func will split a sentence into individual words, while stripping punctuation
        // If the word is present in the dictionary it's value from the dictionary will be added to
        // the sequence. Otherwise we'll continue
        
        // Initialize the sequence to be all 0s, and the length to be determined
        // by the const SEQUENCE_LENGTH. This should be the same length as the
        // sequences that the model was trained for
        
        let SEQUENCE_LENGTH = 20
        var sequence = [Int32](repeating: 0, count: SEQUENCE_LENGTH)
        var words : [String] = []
        sentence.enumerateSubstrings(
            in: sentence.startIndex..<sentence.endIndex,options: .byWords) {
                (substring, _, _, _) -> () in words.append(substring!) }
        var thisWord = 0
        for word in words{
            if (thisWord>=SEQUENCE_LENGTH){
                break
            }
            let seekword = word.lowercased()
            if let val = words_dictionary[seekword]{
                sequence[thisWord]=Int32(val)
                thisWord = thisWord + 1
            }
        }
        return sequence
    }
    
    func classify(sequence: [Int32]) -> Bool{
        // Model Path is the location of the model in the bundle
        let modelPath = Bundle.main.path(forResource: "model", ofType: "tflite")
        var interpreter: Interpreter
        do{
            interpreter = try Interpreter(modelPath: modelPath!)
        } catch _{
            print("Error loading model!")
            return false
        }
        
        let tSequence = Array(sequence)
        let myData = Data(copyingBufferOf: tSequence.map { Int32($0) })
        let outputTensor: Tensor
        
        do {
            // Allocate memory for the model's input `Tensor`s.
            try interpreter.allocateTensors()
            
            // Copy the data to the input `Tensor`.
            try interpreter.copy(myData, toInputAt: 0)
            
            // Run inference by invoking the `Interpreter`.
            try interpreter.invoke()
            
            // Get the output `Tensor` to process the inference results.
            outputTensor = try interpreter.output(at: 0)
            // Turn the output tensor into an array. This will have 2 values
            // Value at index 0 is the probability of negative sentiment
            // Value at index 1 is the probability of positive sentiment
            let resultsArray = outputTensor.data
            let results: [Float32] = [Float32](unsafeData: resultsArray) ?? []
            
            let positiveSpamValue = results[1]
            if(positiveSpamValue>0.8){
                return true
            } else {
                return false
            }
        } catch let error {
            print("Failed to invoke the interpreter with error: \(error.localizedDescription)")
        }
        return false
    }
    
    func doClassificationFor(sentence: String) -> Bool{
        let sequence = convert_sentence(sentence: sentence)
        var isSpam: Bool
        isSpam = classify(sequence: sequence)
        return isSpam
    }
    
    var words_dictionary = [String : Int]()
    
    func loadVocab(){
        // This func will take the file at vocab.txt and load it into a has table
        // called words_dictionary. This will be used to tokenize the words before passing them
        // to the model trained by TensorFlow Lite Model Maker
        if let filePath = Bundle.main.path(forResource: "vocab", ofType: "txt") {
            do {
                let dictionary_contents = try String(contentsOfFile: filePath)
                let lines = dictionary_contents.split(whereSeparator: \.isNewline)
                for line in lines{
                    let tokens = line.components(separatedBy: " ")
                    let key = String(tokens[0])
                    let value = Int(tokens[1])
                    words_dictionary[key] = value
                }
            } catch {
                print("Error vocab could not be loaded")
            }
        } else {
            print("Error -- vocab file not found")
            
        }
    }
    
    func analyzeMessage(messageBody: String) -> Bool  {
        // Filter
        loadVocab()
        var isSpam: Bool
        isSpam = doClassificationFor(sentence: messageBody)
        return isSpam
    }

