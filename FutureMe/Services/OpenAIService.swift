import Foundation

class OpenAIService {
    static let shared = OpenAIService()
    
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let defaultModel = "gpt-4.1-mini-2025-04-14"
    
    private init() {}
    
    func generateQuestions(for decision: String) async throws -> [Question] {
        guard let url = URL(string: baseURL) else { throw NetworkError.invalidURL }
        
        let systemPrompt = "You are an assistant that helps analyze life decisions."
        let userPrompt = """
        User decision:
        \(decision)

        Generate 3 to 5 short clarifying questions that help understand the context of this decision.
        
        Return JSON:
        {
         "questions":[
          {"text":"..."},
          {"text":"..."}
         ]
        }
        """
        
        let requestBody = OpenAIRequest(
            model: defaultModel,
            messages: [
                OpenAIMessage(role: "system", content: systemPrompt),
                OpenAIMessage(role: "user", content: userPrompt)
            ],
            responseFormat: ResponseFormat(type: "json_object"),
            temperature: 0.7
        )
        
        let headers = [
            "Authorization": "Bearer \(APIConfig.apiKey)",
            "Content-Type": "application/json"
        ]
        
        let bodyData = try JSONEncoder().encode(requestBody)
        
        let response: OpenAIResponse = try await NetworkService.shared.performRequest(
            url: url,
            method: "POST",
            headers: headers,
            body: bodyData
        )
        
        guard let responseContent = response.choices.first?.message.content else {
            throw NetworkError.decodingFailed(NSError(domain: "OpenAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No content"]))
        }
        
        struct QuestionsResponse: Codable {
            struct Q: Codable { let text: String }
            let questions: [Q]
        }
        
        guard let data = responseContent.data(using: .utf8) else { throw NetworkError.invalidResponse }
        let parsed = try JSONDecoder().decode(QuestionsResponse.self, from: data)
        
        return parsed.questions.map { Question(id: UUID(), text: $0.text, answer: nil) }
    }
    
    private func modeTwistPrompt(for mode: SimulationMode) -> String {
        switch mode {
        case .realistic:
            return "Keep the scenarios grounded in reality, focusing on realistic, probable outcomes based on the context."
        case .extreme:
            return "Create one absolute best-case scenario (with a very low probability, <5%) and one absolute worst-case scenario (with a very low probability, <5%), pushing the boundaries of what's possible in an extreme way."
        case .sciFi:
            return "Infuse the scenarios with plausible science-fiction elements, futuristic technology, or subtle cyberpunk/solarpunk aesthetics. Make the outcomes feel technologically advanced and imaginative."
        case .stoic:
            return "Focus on how the outcomes affect the individual's internal state, character, and resilience. Emphasize what is within their control versus what is external, written in a philosophical, profound tone."
        case .butterflyEffect:
            return "Focus on chaos theory 'butterfly effect'. Show how one tiny, almost unnoticed, seemingly insignificant detail from the decision cascades into dramatically unpredictable, life-altering consequences down the line."
        case .absurd:
            return "Write something completely absurd, hilarious, and surreal. A highly improbable chain of funny events where everything goes wildly off script and defies common sense."
        case .fantasy:
            return "Reimagine the user's life path as an epic medieval high-fantasy quest, as if they are in a world with dragons, magic, knights, elves, and old kingdoms. Use rich fantasy tropes and heroic vocabulary."
        case .cyberpunk:
            return "Reimagine the user's trajectory in a dystopian, high-tech, low-life, neon-lit cyberpunk future. Include AI megacorps, strange cyberware, neon rain, and hacker undertones."
        }
    }
    
    func generateScenarios(decision: String, mode: SimulationMode = .realistic, questions: [Question]) async throws -> [Scenario] {
        guard let url = URL(string: baseURL) else { throw NetworkError.invalidURL }
        
        let systemPrompt = "You simulate possible future outcomes for life decisions."
        
        let qaList = questions.map { "Q: \($0.text)\nA: \($0.answer ?? "No answer")" }.joined(separator: "\n\n")
        let modeTwist = modeTwistPrompt(for: mode)
        
        let userPrompt = """
        Decision:
        \(decision)

        Context answers:
        \(qaList)

        Style / Mode Instruction:
        \(modeTwist)

        Generate two scenarios:

        1 optimistic scenario
        1 challenging scenario
        
        CRITICAL: For the "probability" field, YOU MUST dynamically calculate a realistic percentage based on the specific situation. DO NOT just output 65 and 35. Evaluate the realistic likelihood (0-100) of each scenario occurring in this context.

        Return JSON:
        {
         "scenarios":[
          {
           "title":"Optimistic Path",
           "probability":72,
           "description":"...",
           "iconName":"sun.max.fill",
           "events":[
              {"title":"First 3 months","description":"..."},
              {"title":"1 year later","description":"..."}
           ]
          },
          {
           "title":"Challenging Path",
           "probability":28,
           "description":"...",
           "iconName":"cloud.bolt.fill",
           "events":[
              {"title":"First 3 months","description":"..."},
              {"title":"1 year later","description":"..."}
           ]
          }
         ]
        }
        """
        
        let requestBody = OpenAIRequest(
            model: defaultModel,
            messages: [
                OpenAIMessage(role: "system", content: systemPrompt),
                OpenAIMessage(role: "user", content: userPrompt)
            ],
            responseFormat: ResponseFormat(type: "json_object"),
            temperature: 0.8
        )
        
        let headers = [
            "Authorization": "Bearer \(APIConfig.apiKey)",
            "Content-Type": "application/json"
        ]
        
        let bodyData = try JSONEncoder().encode(requestBody)
        
        let response: OpenAIResponse = try await NetworkService.shared.performRequest(
            url: url,
            method: "POST",
            headers: headers,
            body: bodyData
        )
        
        guard let responseContent = response.choices.first?.message.content else {
            throw NetworkError.decodingFailed(NSError(domain: "OpenAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No content"]))
        }
        
        struct ScenariosResponse: Codable {
            struct S: Codable {
                let title: String
                let probability: Int
                let description: String
                let iconName: String?
                let events: [E]
            }
            struct E: Codable {
                let title: String
                let description: String
            }
            let scenarios: [S]
        }
        
        guard let data = responseContent.data(using: .utf8) else { throw NetworkError.invalidResponse }
        let parsed = try JSONDecoder().decode(ScenariosResponse.self, from: data)
        
        return parsed.scenarios.map {
            Scenario(
                id: UUID(),
                title: $0.title,
                probability: $0.probability,
                description: $0.description,
                type: $0.title.lowercased().contains("challeng") ? .challenging : .optimistic,
                iconName: $0.iconName,
                events: $0.events.map { FutureEvent(id: UUID(), title: $0.title, description: $0.description) }
            )
        }
    }
    
    func generateNextSteps(for scenario: Scenario, decision: String, mode: SimulationMode = .realistic) async throws -> [Scenario] {
        guard let url = URL(string: baseURL) else { throw NetworkError.invalidURL }
        
        let systemPrompt = "You simulate possible future outcomes for life decisions."
        
        let modeTwist = modeTwistPrompt(for: mode)
        
        let userPrompt = """
        Original Decision:
        \(decision)

        Current scenario outcome been reached:
        Title: \(scenario.title)
        Description: \(scenario.description)

        Style / Mode Instruction:
        \(modeTwist)

        Generate TWO possible next steps/branches that follow DIRECTLY from this scenario.
        1 optimistic continuation
        1 challenging continuation
        
        CRITICAL: For the "probability" field, YOU MUST dynamically calculate a realistic percentage based on the specific situation. DO NOT just output 65 and 35. Evaluate the realistic likelihood (0-100) of each continuation occurring from this specific point.

        Return JSON:
        {
         "scenarios":[
          {
           "title":"Optimistic Path",
           "probability":60,
           "description":"...",
           "iconName":"star.fill",
           "events":[
              {"title":"3 months later","description":"..."},
              {"title":"6 months later","description":"..."}
           ]
          },
          {
           "title":"Challenging Path",
           "probability":40,
           "description":"...",
           "iconName":"xmark.seal.fill",
           "events":[
              {"title":"3 months later","description":"..."},
              {"title":"6 months later","description":"..."}
           ]
          }
         ]
        }
        """
        
        let requestBody = OpenAIRequest(
            model: defaultModel,
            messages: [
                OpenAIMessage(role: "system", content: systemPrompt),
                OpenAIMessage(role: "user", content: userPrompt)
            ],
            responseFormat: ResponseFormat(type: "json_object"),
            temperature: 0.8
        )
        
        let headers = [
            "Authorization": "Bearer \(APIConfig.apiKey)",
            "Content-Type": "application/json"
        ]
        
        let bodyData = try JSONEncoder().encode(requestBody)
        
        let response: OpenAIResponse = try await NetworkService.shared.performRequest(
            url: url,
            method: "POST",
            headers: headers,
            body: bodyData
        )
        
        guard let responseContent = response.choices.first?.message.content else {
            throw NetworkError.decodingFailed(NSError(domain: "OpenAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No content"]))
        }
        
        struct ScenariosResponse: Codable {
            struct S: Codable {
                let title: String
                let probability: Int
                let description: String
                let iconName: String?
                let events: [E]
            }
            struct E: Codable {
                let title: String
                let description: String
            }
            let scenarios: [S]
        }
        
        guard let data = responseContent.data(using: .utf8) else { throw NetworkError.invalidResponse }
        let parsed = try JSONDecoder().decode(ScenariosResponse.self, from: data)
        
        return parsed.scenarios.map {
            Scenario(
                id: UUID(),
                title: $0.title,
                probability: $0.probability,
                description: $0.description,
                type: $0.title.lowercased().contains("challeng") ? .challenging : .optimistic,
                iconName: $0.iconName,
                events: $0.events.map { FutureEvent(id: UUID(), title: $0.title, description: $0.description) }
            )
        }
    }
    
    func generateGoalPlan(for goal: String) async throws -> GoalPlan {
        guard let url = URL(string: baseURL) else { throw NetworkError.invalidURL }
        
        let systemPrompt = "You are an expert life coach and strategic planner."
        
        let userPrompt = """
        The user has the following major long-term goal:
        \(goal)

        Reverse-engineer the path backward from achieving this goal to the present day. Create a structured timeline of milestones. Start with the final achieved state and work backward to "Tomorrow", "Next Week", "Next Month", "In 1 Year", etc. Keep it actionable and inspiring.

        Return JSON constraint:
        {
         "steps":[
          {"timeframe":"In 5 years (Final Goal)","title":"...","description":"..."},
          {"timeframe":"In 3 years","title":"...","description":"..."},
          {"timeframe":"In 1 year","title":"...","description":"..."},
          {"timeframe":"In 6 months","title":"...","description":"..."},
          {"timeframe":"Next month","title":"...","description":"..."},
          {"timeframe":"Next week","title":"...","description":"..."},
          {"timeframe":"Tomorrow","title":"...","description":"..."}
         ]
        }
        """
        
        let requestBody = OpenAIRequest(
            model: defaultModel,
            messages: [
                OpenAIMessage(role: "system", content: systemPrompt),
                OpenAIMessage(role: "user", content: userPrompt)
            ],
            responseFormat: ResponseFormat(type: "json_object"),
            temperature: 0.7
        )
        
        let headers = [
            "Authorization": "Bearer \(APIConfig.apiKey)",
            "Content-Type": "application/json"
        ]
        
        let bodyData = try JSONEncoder().encode(requestBody)
        
        let response: OpenAIResponse = try await NetworkService.shared.performRequest(
            url: url,
            method: "POST",
            headers: headers,
            body: bodyData
        )
        
        guard let responseContent = response.choices.first?.message.content else {
            throw NetworkError.decodingFailed(NSError(domain: "OpenAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No content"]))
        }
        
        struct GoalResponse: Codable {
            struct S: Codable {
                let timeframe: String
                let title: String
                let description: String
            }
            let steps: [S]
        }
        
        guard let data = responseContent.data(using: .utf8) else { throw NetworkError.invalidResponse }
        let parsed = try JSONDecoder().decode(GoalResponse.self, from: data)
        
        return GoalPlan(
            id: UUID(),
            goal: goal,
            steps: parsed.steps.map { GoalStep(id: UUID(), timeframe: $0.timeframe, title: $0.title, description: $0.description) }
        )
    }
    
    func generateButterflyTimeline(for action: String) async throws -> WowTimeline {
        guard let url = URL(string: baseURL) else { throw NetworkError.invalidURL }
        
        let systemPrompt = "You are a creative storyteller who simulates extreme, astonishing 'butterfly effects' from mundane actions."
        
        let userPrompt = """
        The user took this seemingly insignificant action today:
        "\(action)"

        Trace a chain reaction of causality over several years. The escalation should be rapid, highly imaginative, surprising, and end up having a massive (often hilarious, sci-fi, or spectacular) outcome.
        Provide 5 chronological steps.
        
        Step 1: Within hours or days.
        Step 2: Weeks to a month.
        Step 3: About a year later.
        Step 4: A few years later.
        Step 5 (Final): The ultimate, staggering, movie-like climax.

        Return JSON constraint:
        {
         "steps":[
          {"timeframe":"Later today","description":"...","isFinal":false},
          {"timeframe":"Next week","description":"...","isFinal":false},
          {"timeframe":"1 Year Later","description":"...","isFinal":false},
          {"timeframe":"3 Years Later","description":"...","isFinal":false},
          {"timeframe":"10 Years Later","description":"...","isFinal":true}
         ]
        }
        """
        
        let requestBody = OpenAIRequest(
            model: defaultModel,
            messages: [
                OpenAIMessage(role: "system", content: systemPrompt),
                OpenAIMessage(role: "user", content: userPrompt)
            ],
            responseFormat: ResponseFormat(type: "json_object"),
            temperature: 0.9 // High creativity
        )
        
        let headers = [
            "Authorization": "Bearer \(APIConfig.apiKey)",
            "Content-Type": "application/json"
        ]
        
        let bodyData = try JSONEncoder().encode(requestBody)
        
        let response: OpenAIResponse = try await NetworkService.shared.performRequest(
            url: url,
            method: "POST",
            headers: headers,
            body: bodyData
        )
        
        guard let responseContent = response.choices.first?.message.content else {
            throw NetworkError.decodingFailed(NSError(domain: "OpenAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No content"]))
        }
        
        struct WowResponse: Codable {
            struct W: Codable {
                let timeframe: String
                let description: String
                let isFinal: Bool
            }
            let steps: [W]
        }
        
        guard let data = responseContent.data(using: .utf8) else { throw NetworkError.invalidResponse }
        let parsed = try JSONDecoder().decode(WowResponse.self, from: data)
        
        return WowTimeline(
            id: UUID(),
            action: action,
            steps: parsed.steps.map { WowNode(id: UUID(), timeframe: $0.timeframe, description: $0.description, isFinal: $0.isFinal) }
        )
    }
}

