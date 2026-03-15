import Foundation
import SwiftUI

struct QuizQuestion {
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

struct MentalModel: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let iconName: String
    let imageName: String
    let content: String
    let gradientColors: [Color]
    let quiz: [QuizQuestion]
}

struct LibraryData {
    static let models: [MentalModel] = [
        MentalModel(
            title: "Inversion",
            subtitle: "Think backward to avoid failure.",
            iconName: "arrow.uturn.backward.circle.fill",
            imageName: "library_inversion",
            content: """
            **What is Inversion?**
            Instead of thinking about what you need to do to achieve a goal, inversion asks you to think about what you need to do to guarantee failure—and then avoid doing those things.
            
            **How to use it:**
            If you want to be a great manager, don't ask "How do I become a great manager?" Ask "What would make me a terrible manager?" The answers (micromanaging, not listening, playing favorites) immediately give you a roadmap of what to avoid.
            """,
            gradientColors: [Color(hex: "FF6B35"), Color(hex: "F7C59F")],
            quiz: [
                QuizQuestion(question: "What is the primary goal of Inversion?", options: ["Finding the fastest way to succeed", "Thinking about what guarantees failure to avoid it", "Copying successful people", "Working harder than everyone else"], correctIndex: 1, explanation: "Inversion is the practice of thinking about what you want to avoid (failure) rather than what you want to achieve (success)."),
                QuizQuestion(question: "If you want to be a great manager using Inversion, what should you ask yourself?", options: ["How do I become a great manager?", "What would make me a terrible manager?", "Who is the best manager in the world?", "How can I make my team like me more?"], correctIndex: 1, explanation: "By asking what makes a terrible manager, you identify behaviors to avoid, such as micromanaging or playing favorites."),
                QuizQuestion(question: "Which of these is NOT a result of using Inversion?", options: ["Avoiding obvious mistakes", "Identifying pitfalls early", "Guaranteeing immediate success", "Gaining a new perspective on a problem"], correctIndex: 2, explanation: "Inversion helps you avoid failure, but it does not guarantee immediate success.")
            ]
        ),
        MentalModel(
            title: "Second-Order Thinking",
            subtitle: "Consider the consequences of the consequences.",
            iconName: "target",
            imageName: "library_second_order",
            content: """
            **What is Second-Order Thinking?**
            First-order thinking is fast and easy. It happens when we look for something that only solves the immediate problem without considering the consequences. "I'm hungry, let's eat chocolate." Second-order thinking is farther-reaching. "If I eat chocolate now, I'll crash in an hour."
            
            **How to use it:**
            Before making a decision, ask yourself: "And then what?" Map out not just the immediate result, but the long-term ripple effects of that choice.
            """,
            gradientColors: [Color(hex: "4A90D9"), Color(hex: "7EC8E3")],
            quiz: [
                QuizQuestion(question: "What is the main difference between first-order and second-order thinking?", options: ["First-order is slow, second-order is fast", "First-order considers immediate results, second-order considers long-term ripple effects", "First-order is always wrong, second-order is always right", "First-order is used by experts, second-order is used by beginners"], correctIndex: 1, explanation: "First-order thinking looks for quick fixes, while second-order thinking asks 'And then what?' to consider future consequences."),
                QuizQuestion(question: "Which question is a hallmark of Second-Order Thinking?", options: ["Why did this happen?", "Who is to blame?", "And then what?", "How fast can we fix this?"], correctIndex: 2, explanation: "Asking 'And then what?' forces you to think beyond the immediate consequence of an action."),
                QuizQuestion(question: "Why is second-order thinking often difficult?", options: ["It requires more time and cognitive effort", "It usually leads to the wrong answer", "It is only useful in mathematics", "It requires a team of people"], correctIndex: 0, explanation: "Second-order thinking maps out long-term ripple effects, which takes more mental energy than simple, fast first-order thinking.")
            ]
        ),
        MentalModel(
            title: "Regret Minimization",
            subtitle: "Project yourself to age 80.",
            iconName: "hourglass.circle.fill",
            imageName: "library_regret",
            content: """
            **What is Regret Minimization?**
            Popularized by Jeff Bezos when deciding to start Amazon, this framework involves projecting yourself to age 80, looking back on your life, and asking whether you will regret not having taken the action.
            
            **How to use it:**
            When faced with a difficult, risky choice (like quitting a stable job to start a company), ask: "When I am 80, will I regret trying and failing? Will I regret never having tried?" Usually, we regret the things we didn't do more than the things we tried and failed at.
            """,
            gradientColors: [Color(hex: "7B5EA7"), Color(hex: "C4A6F0")],
            quiz: [
                QuizQuestion(question: "What is the core premise of Regret Minimization?", options: ["Always choose the safest option", "Project yourself to age 80 and choose the action you'd regret least not taking", "Minimize financial losses", "Avoid doing anything that makes you uncomfortable"], correctIndex: 1, explanation: "The framework asks you to look back on your life from age 80 and determine what you would regret missing out on the most."),
                QuizQuestion(question: "Which entrepreneur famously used this framework to start their company?", options: ["Elon Musk", "Steve Jobs", "Jeff Bezos", "Bill Gates"], correctIndex: 2, explanation: "Jeff Bezos used the Regret Minimization Framework when deciding to leave his stable job to start Amazon."),
                QuizQuestion(question: "According to this framework, what do people typically regret more later in life?", options: ["The things they tried and failed at", "The things they never tried", "Losing money", "Making enemies"], correctIndex: 1, explanation: "Research and this framework suggest we regret inactions (things we didn't do) far more than actions (things we tried and failed at).")
            ]
        ),
        MentalModel(
            title: "The Butterfly Effect",
            subtitle: "Small changes, massive consequences.",
            iconName: "leaf.fill",
            imageName: "library_butterfly",
            content: """
            **What is the Butterfly Effect?**
            A concept from chaos theory suggesting that a small change in one state of a deterministic nonlinear system can result in large differences in a later state. The metaphor: a butterfly flapping its wings in Brazil can set off a tornado in Texas.
            
            **How to use it:**
            Recognize the profound impact of tiny daily habits. Reading 10 pages a day seems insignificant, but compounds over years into massive knowledge advantages.
            """,
            gradientColors: [Color(hex: "00C9A7"), Color(hex: "B7F4D8")],
            quiz: [
                QuizQuestion(question: "What does the Butterfly Effect illustrate?", options: ["Butterflies cause tornadoes", "Small changes in initial conditions can lead to vastly different outcomes", "Large changes always have small consequences", "Predicting the future is easy"], correctIndex: 1, explanation: "It's a concept from chaos theory showing how tiny, seemingly insignificant changes can compound into massive differences over time."),
                QuizQuestion(question: "Which field of study did the Butterfly Effect originate from?", options: ["Psychology", "Economics", "Chaos Theory / Meteorology", "Biology"], correctIndex: 2, explanation: "Edward Lorenz coined the term while studying weather models, noting how a tiny rounding error caused a completely different forecast."),
                QuizQuestion(question: "How can you apply the Butterfly Effect to personal growth?", options: ["By making massive changes all at once", "By ignoring small habits", "By recognizing the compounding power of tiny, consistent daily actions", "By trying to predict the exact future"], correctIndex: 2, explanation: "A small action, like reading a few pages daily, compounds into massive knowledge over a lifetime.")
            ]
        ),
        MentalModel(
            title: "Dichotomy of Control",
            subtitle: "Focus only on what you can change.",
            iconName: "scale.3d",
            imageName: "library_control",
            content: """
            **What is the Dichotomy of Control?**
            A core principle of Stoic philosophy. It states that some things are up to us, and some things are not. Suffering arises when we try to control the things that are not up to us.
            
            **How to use it:**
            Separate your concerns into two buckets: things you control (your effort, your attitude, your choices) and things you don't (the economy, other people's opinions, past events). Relentlessly focus your energy only on the first bucket.
            """,
            gradientColors: [Color(hex: "3A3A3A"), Color(hex: "8B8B8B")],
            quiz: [
                QuizQuestion(question: "The Dichotomy of Control is a core principle of which philosophy?", options: ["Existentialism", "Nihilism", "Stoicism", "Utilitarianism"], correctIndex: 2, explanation: "Stoicism teaches that we should focus our energy only on things within our control."),
                QuizQuestion(question: "Which of the following is considered 'within your control' according to this model?", options: ["The economy", "Other people's opinions", "Your effort and attitude", "The weather"], correctIndex: 2, explanation: "You can only control your own actions, choices, and reactions. External factors are outside your control."),
                QuizQuestion(question: "What is the primary benefit of applying the Dichotomy of Control?", options: ["You gain control over other people", "It eliminates unnecessary suffering and anxiety about uncontrollable events", "It guarantees financial success", "It makes you physically stronger"], correctIndex: 1, explanation: "By letting go of what you can't control, you free up mental energy and reduce stress.")
            ]
        ),
        MentalModel(
            title: "Ockham's Razor",
            subtitle: "The simplest explanation is usually the best.",
            iconName: "scissors",
            imageName: "library_ockham",
            content: """
            **What is Ockham's Razor?**
            A problem-solving principle that says "entities should not be multiplied beyond necessity." In other words, when you have two competing theories that make exactly the same predictions, the simpler one is usually better.
            
            **How to use it:**
            When trying to figure out why a colleague hasn't replied to your email, the simple explanation (they are busy) is infinitely more likely than the complex one (they are secretly plotting against you with the CEO). Choose the simple path.
            """,
            gradientColors: [Color(hex: "E84118"), Color(hex: "FBC531")],
            quiz: [
                QuizQuestion(question: "What is the core rule of Ockham's Razor?", options: ["Always choose the most complex explanation", "The simplest explanation is usually the correct one", "Never trust first impressions", "Shave off parts of a problem until it disappears"], correctIndex: 1, explanation: "When presented with multiple explanations that fit the facts, the one requiring the fewest assumptions is usually best."),
                QuizQuestion(question: "If a colleague is late to a meeting, how would you apply Ockham's Razor?", options: ["Assume they secretly hate you", "Assume they are plotting with the boss", "Assume they hit traffic or lost track of time", "Assume they quit the company"], correctIndex: 2, explanation: "Traffic or losing track of time requires the fewest assumptions and is the most likely simple explanation."),
                QuizQuestion(question: "What does 'entities should not be multiplied beyond necessity' mean?", options: ["Don't hire too many people", "Don't add unnecessary assumptions to a theory", "Always use multiplication instead of addition", "Keep your circle of friends small"], correctIndex: 1, explanation: "It means you shouldn't complicate an explanation with extra moving parts if a simpler one works.")
            ]
        ),
        MentalModel(
            title: "Circle of Competence",
            subtitle: "Know what you know. Know what you don't.",
            iconName: "dot.circle.viewfinder",
            imageName: "library_circle",
            content: """
            **What is the Circle of Competence?**
            A mental model championed by Warren Buffett and Charlie Munger. It directs you to understand the boundaries of your own knowledge. Inside the circle are things you deeply understand. Outside the circle are things you do not.
            
            **How to use it:**
            You don't need to be an expert in everything. You only need to know exactly where the perimeter of your expertise ends. Make your big decisions strictly within your circle, and when operating outside it, hire or listen to true experts.
            """,
            gradientColors: [Color(hex: "192A56"), Color(hex: "273C75")],
            quiz: [
                QuizQuestion(question: "What does the 'Circle of Competence' represent?", options: ["The people you trust most", "The geographical area where your business operates", "The topics and skills you deeply understand", "The amount of money you can safely invest"], correctIndex: 2, explanation: "Your circle of competence contains the subjects you actually have deep, practical knowledge about."),
                QuizQuestion(question: "According to Warren Buffett, what is the most important thing about the Circle of Competence?", options: ["How big it is", "Knowing where the perimeter is", "Constantly forcing yourself outside of it", "Keeping it a secret"], correctIndex: 1, explanation: "The size of the circle isn't as important as knowing exactly where its boundaries are so you don't confidently make mistakes in areas you don't understand."),
                QuizQuestion(question: "What should you do when faced with a decision outside your circle?", options: ["Guess and hope for the best", "Ignore the decision", "Consult true experts or pass on the decision", "Pretend you know the answer"], correctIndex: 2, explanation: "When operating outside your competence, the rational move is to rely on those whose circle actually covers that domain.")
            ]
        ),
        MentalModel(
            title: "Hanlon's Razor",
            subtitle: "Never attribute to malice what is adequately explained by stupidity.",
            iconName: "brain.head.profile",
            imageName: "library_hanlon",
            content: """
            **What is Hanlon's Razor?**
            A philosophical razor that suggests a way of eliminating unlikely explanations for human behavior. It tells us that people make mistakes far more often than they intentionally try to hurt us.
            
            **How to use it:**
            If someone cuts you off in traffic, they probably aren't targeting you specifically; they are just careless or distracted. Using Hanlon's Razor saves you an enormous amount of stress and prevents you from assuming everyone is out to get you.
            """,
            gradientColors: [Color(hex: "8E44AD"), Color(hex: "9B59B6")],
            quiz: [
                QuizQuestion(question: "What is the main idea behind Hanlon's Razor?", options: ["Everyone is out to get you", "Never attribute to malice what is adequately explained by stupidity or carelessness", "Always assume the worst in people", "People are inherently evil"], correctIndex: 1, explanation: "Most negative actions by others are due to innocent mistakes, ignorance, or carelessness, not malicious intent."),
                QuizQuestion(question: "How does Hanlon's Razor improve your life?", options: ["It teaches you how to shave", "It helps you win arguments", "It reduces unnecessary anger and paranoia in daily interactions", "It makes you smarter than everyone else"], correctIndex: 2, explanation: "By assuming incompetence instead of malice, you let go of anger and avoid taking things personally."),
                QuizQuestion(question: "If an email sounds accidentally rude, applying Hanlon's Razor means:", options: ["Replying with an equally rude email", "Assuming they wrote it in a hurry and didn't mean to be rude", "Forwarding it to HR", "Confronting them in person"], correctIndex: 1, explanation: "Assuming they were busy or distracted is a simpler explanation than assuming they orchestrated a personal attack against you.")
            ]
        ),
        MentalModel(
            title: "Pareto Principle",
            subtitle: "The 80/20 Rule of outcomes.",
            iconName: "chart.pie.fill",
            imageName: "library_pareto",
            content: """
            **What is the Pareto Principle?**
            Often called the 80/20 rule, it states that roughly 80% of consequences come from 20% of the causes. 
            
            **How to use it:**
            Identify the critical 20% of your efforts that produce the majority of your results. Whether it's the 20% of clients bringing in 80% of revenue, or the 20% of habits causing 80% of your happiness, double down on what works and cut out the rest.
            """,
            gradientColors: [Color(hex: "00B4DB"), Color(hex: "0083B0")],
            quiz: [
                QuizQuestion(question: "What is the general ratio of the Pareto Principle?", options: ["50/50", "90/10", "80/20", "99/1"], correctIndex: 2, explanation: "It is widely known as the 80/20 rule, though the exact numbers can vary."),
                QuizQuestion(question: "How would you apply the Pareto Principle to a messy to-do list?", options: ["Do all the easy tasks first", "Identify the 20% of tasks that will yield 80% of the value and do those first", "Delegate everything", "Work 80 hours a week"], correctIndex: 1, explanation: "Focusing on the high-leverage 20% maximizes your output while minimizing wasted effort."),
                QuizQuestion(question: "Where does the 80/20 rule apply?", options: ["Only in economics", "Only in software engineering", "It is a universal principle found in business, nature, and personal habits", "Only in mathematics"], correctIndex: 2, explanation: "The Pareto distribution is found in almost every aspect of life, from wealth distribution to pea pods in a garden.")
            ]
        ),
        MentalModel(
            title: "Confirmation Bias",
            subtitle: "Seeing what you want to see.",
            iconName: "eye.trianglebadge.exclamationmark",
            imageName: "library_bias",
            content: """
            **What is Confirmation Bias?**
            The tendency to search for, interpret, favor, and recall information in a way that confirms or supports one's prior beliefs or values.
            
            **How to use it:**
            Protect yourself by actively seeking out disconfirming evidence. If you believe a stock is a great buy, intentionally search for the strongest arguments on why you shouldn't buy it before making a decision.
            """,
            gradientColors: [Color(hex: "FF416C"), Color(hex: "FF4B2B")],
            quiz: [
                QuizQuestion(question: "What is Confirmation Bias?", options: ["Always confirming your appointments", "Seeking information that supports what you already believe", "Changing your mind constantly", "Believing the last thing you heard"], correctIndex: 1, explanation: "It is the psychological tendency to favor information that agrees with our existing beliefs while ignoring contradictory evidence."),
                QuizQuestion(question: "What is the best way to combat Confirmation Bias?", options: ["Only reading news that agrees with you", "Trusting your gut feeling", "Actively seeking out opposing viewpoints and disconfirming evidence", "Asking your friends what they think"], correctIndex: 2, explanation: "Deliberately looking for evidence that proves you wrong is the most effective way to break out of the bias loop."),
                QuizQuestion(question: "Why is Confirmation Bias dangerous in decision making?", options: ["It makes decisions too slow", "It causes you to ignore critical warning signs", "It makes you too open-minded", "It costs money to confirm facts"], correctIndex: 1, explanation: "Because you filter out negative information, you may make reckless decisions based on an incomplete, overly optimistic view.")
            ]
        ),
        MentalModel(
            title: "First Principles Thinking",
            subtitle: "Boiling things down to absolute truths.",
            iconName: "building.columns.fill",
            imageName: "library_first_principles",
            content: """
            **What is First Principles Thinking?**
            The act of breaking a complex problem down to its most basic, foundational truths that cannot be deduced any further, and then building up from there. This escapes "thinking by analogy" (doing what others do).
            
            **How to use it:**
            When told "batteries will always be expensive," Elon Musk broke batteries down to their raw materials (cobalt, nickel, aluminum) and realized the base materials were cheap. He built cheaper batteries from the ground up rather than copying existing methods.
            """,
            gradientColors: [Color(hex: "ED213A"), Color(hex: "93291E")],
            quiz: [
                QuizQuestion(question: "What is the core of First Principles Thinking?", options: ["Doing what everyone else does", "Starting with assumptions", "Breaking a problem down to fundamental truths and building up from there", "Asking the smartest person in the room"], correctIndex: 2, explanation: "It involves stripping away all assumptions until you are left only with undeniable facts, and reasoning upward."),
                QuizQuestion(question: "What is the opposite of First Principles Thinking?", options: ["Thinking by analogy", "Mathematical reasoning", "Physics", "Critical thinking"], correctIndex: 0, explanation: "Thinking by analogy means doing things based on how they've been done before, rather than figuring out what is actually possible."),
                QuizQuestion(question: "Which of these is an example of First Principles Thinking?", options: ["Building a website because your competitor has one", "Calculating the raw cost of materials to see if a product can be made cheaper", "Buying a stock because a pundit said it's good", "Following a recipe exactly"], correctIndex: 1, explanation: "Looking at raw materials directly bypasses industry assumptions about how much a product 'should' cost.")
            ]
        ),
        MentalModel(
            title: "Survivorship Bias",
            subtitle: "Ignoring the unseen failures.",
            iconName: "airplane",
            imageName: "library_survivor",
            content: """
            **What is Survivorship Bias?**
            The logical error of concentrating on the people or things that made it past some selection process and overlooking those that did not.
            
            **How to use it:**
            Don't just study successful billionaires who dropped out of college. For every Steve Jobs, there are thousands of dropouts who failed, but they don't get book deals. You must study both the successes and the failures to find the truth.
            """,
            gradientColors: [Color(hex: "11998E"), Color(hex: "38EF7D")],
            quiz: [
                QuizQuestion(question: "What is Survivorship Bias?", options: ["Focusing only on the survivors/successes and ignoring the invisible failures", "Learning survival skills", "The belief that you will survive anything", "A bias against older companies"], correctIndex: 0, explanation: "It's a distortion of reality caused by only looking at the 'winners' because they are visible, while the 'losers' are mostly hidden."),
                QuizQuestion(question: "During WWII, engineers wanted to armor planes where returning planes had bullet holes. Why was this wrong?", options: ["The armor was too heavy", "The planes didn't need armor", "They ignored the planes that DIDN'T return, which were hit in other, fatal areas", "Bullet holes make the plane faster"], correctIndex: 2, explanation: "Abraham Wald pointed out that the planes showing bullet holes survived. The ones hit in the engine didn't survive to be counted. They needed to armor the pristine areas, not the damaged ones."),
                QuizQuestion(question: "How does Survivorship Bias affect business advice?", options: ["It makes advice too negative", "It causes people to emulate risky behavior because they only see the few lucky winners", "It makes people study failures too much", "It has no effect"], correctIndex: 1, explanation: "People copy the habits of successful outliers without realizing thousands of others did the exact same things and failed.")
            ]
        ),
        MentalModel(
            title: "Sunk Cost Fallacy",
            subtitle: "Don't throw good money after bad.",
            iconName: "trash.slash.fill",
            imageName: "library_sunk_cost",
            content: """
            **What is the Sunk Cost Fallacy?**
            The phenomenon whereby a person is reluctant to abandon a strategy or course of action because they have invested heavily in it, even when it is clear that abandonment would be more beneficial.
            
            **How to use it:**
            The money, time, or emotion you already spent is gone. It cannot be recovered. Make your decisions based solely on future costs and future benefits, entirely ignoring what you've already 'sunk' into the project.
            """,
            gradientColors: [Color(hex: "F7971E"), Color(hex: "FFD200")],
            quiz: [
                QuizQuestion(question: "What is the Sunk Cost Fallacy?", options: ["Refusing to quit because you've already invested heavily in it", "Investing in sunken ships", "Giving up too early", "Worrying about future costs"], correctIndex: 0, explanation: "It's the irrational behavior of continuing a doomed endeavor simply because of the resources already spent."),
                QuizQuestion(question: "If you buy a non-refundable movie ticket and realize the movie is terrible 20 minutes in, what is the rational choice?", options: ["Stay because you paid for it", "Leave, because the money is gone either way and staying wastes your time too", "Stay and complain loudly", "Buy a second ticket"], correctIndex: 1, explanation: "The cost of the ticket is 'sunk.' Leaving prevents you from also wasting your time (an additional cost)."),
                QuizQuestion(question: "How should you evaluate decisions to avoid this fallacy?", options: ["Based entirely on past investments", "Based on emotion", "Based solely on future costs and future benefits", "Based on what others think"], correctIndex: 2, explanation: "Rational decision-making ignores past, irretrievable 'sunk' costs and looks only forward.")
            ]
        )
    ]
}
