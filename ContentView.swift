import SwiftUI
import Alamofire

struct APIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let text: String
}

struct ContentView: View {
    @State private var userInput: String = ""
    @State private var chatbotResponse: String = ""
    
    var body: some View {
        VStack {
            HStack {
                BatteryView()
                Spacer()
            }
            TextField("Ask ChatGPT something...", text: $userInput, onCommit: {
                sendRequestToChatGPT(userInput: userInput)
            })
            .padding()
            
            ScrollView {
                Text(chatbotResponse)
                    .padding()
                    .multilineTextAlignment(.leading)
            }
        }
    }
    
    func sendRequestToChatGPT(userInput: String) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer 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"
        ]
        
        let parameters: Parameters = [
            "prompt": "You are a helpful assistant. \(userInput)",
            "max_tokens": 50,
            "n": 1,
            "stop": ["\n"],
            "temperature": 0.7
        ]

        
        AF.request("https://api.openai.com/v1/engines/davinci/completions",
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers)
            .validate()
            .responseDecodable(of: APIResponse.self) { response in
                switch response.result {
                case .success(let apiResponse):
                    if let chatbotText = apiResponse.choices.first?.text {
                        DispatchQueue.main.async {
                            self.chatbotResponse = chatbotText.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    }
                    
                case .failure(let error):
                    print("Error:", error)
                    let errorString = error.localizedDescription
                    self.chatbotResponse = errorString
                }
            }
    }
}
