import SwiftUI
import Combine
import FirebaseFirestore

// MARK: - Theme Colors
struct AppTheme {
    static let gradientBlue = Color(red: 29/255, green: 44/255, blue: 247/255)
    static let gradientPurple = Color(red: 124/255, green: 36/255, blue: 240/255)
    static let gradientPink = Color(red: 242/255, green: 78/255, blue: 110/255)
    static let textPrimary = Color.white.opacity(0.96)
    static let textSecondary = Color.white.opacity(0.66)
    static let accentGreen = Color(red: 39/255, green: 192/255, blue: 82/255)
    static let accentYellow = Color(red: 255/255, green: 195/255, blue: 59/255)
    static let accentOrange = Color(red: 255/255, green: 149/255, blue: 0/255)
    static let accentRed = Color(red: 255/255, green: 77/255, blue: 79/255)
    static let cardSurface = Color.white.opacity(0.08)
    static let cardBorder = Color.white.opacity(0.18)
    static let darkOverlay = Color.black.opacity(0.45)

    struct Priority {
        let textColor: Color
        let backgroundColor: Color
    }

    static let priorityLow = Priority(
        textColor: Color(red: 39/255, green: 192/255, blue: 82/255),
        backgroundColor: Color(red: 39/255, green: 192/255, blue: 82/255).opacity(0.18)
    )
    static let priorityMedium = Priority(
        textColor: Color(red: 255/255, green: 214/255, blue: 51/255),
        backgroundColor: Color(red: 255/255, green: 214/255, blue: 51/255).opacity(0.22)
    )
    static let priorityHigh = Priority(
        textColor: Color(red: 255/255, green: 149/255, blue: 0/255),
        backgroundColor: Color(red: 255/255, green: 149/255, blue: 0/255).opacity(0.22)
    )
    static let priorityUrgent = Priority(
        textColor: Color(red: 255/255, green: 59/255, blue: 48/255),
        backgroundColor: Color(red: 255/255, green: 59/255, blue: 48/255).opacity(0.22)
    )

    static var mainGradient: LinearGradient {
        LinearGradient(colors: [gradientBlue, gradientPurple, gradientPink], startPoint: .bottomLeading, endPoint: .topTrailing)
    }
    static var buttonGradient: LinearGradient { mainGradient }

    static func priorityColors(for priority: String) -> Priority {
        if priority.contains("🔴") || priority.lowercased().contains("urgente") { return priorityUrgent }
        else if priority.contains("🟠") || priority.lowercased().contains("élevée") { return priorityHigh }
        else if priority.contains("🟡") || priority.lowercased().contains("moyenne") { return priorityMedium }
        else { return priorityLow }
    }
}

struct CardStyle: ViewModifier {
    var isCompleted: Bool = false
    func body(content: Content) -> some View {
        content.background(
            RoundedRectangle(cornerRadius: 24, style: .continuous).fill(AppTheme.cardSurface)
                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(AppTheme.cardBorder, lineWidth: 1))
                .shadow(color: Color.black.opacity(0.20), radius: 26, x: 0, y: 8)
        ).opacity(isCompleted ? 0.7 : 1.0).scaleEffect(isCompleted ? 0.98 : 1.0)
    }
}

struct PriorityChipStyle: ViewModifier {
    let priority: String
    func body(content: Content) -> some View {
        let colors = AppTheme.priorityColors(for: priority)
        return content.font(.caption).fontWeight(.semibold).foregroundColor(colors.textColor)
            .padding(.horizontal, 10).padding(.vertical, 5).background(Capsule().fill(colors.backgroundColor))
    }
}

struct GlassSurface: ViewModifier {
    func body(content: Content) -> some View {
        content.background(
            RoundedRectangle(cornerRadius: 20, style: .continuous).fill(AppTheme.cardSurface)
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(AppTheme.cardBorder, lineWidth: 0.5))
        )
    }
}

extension View {
    func cardStyle(isCompleted: Bool = false) -> some View { modifier(CardStyle(isCompleted: isCompleted)) }
    func priorityChip(priority: String) -> some View { modifier(PriorityChipStyle(priority: priority)) }
    func glassSurface() -> some View { modifier(GlassSurface()) }
}

struct HapticManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

extension Animation {
    static var appSpring: Animation { .spring(response: 0.4, dampingFraction: 0.75, blendDuration: 0) }
    static var appSpringFast: Animation { .spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0) }
    static var appSpringBouncy: Animation { .spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0) }
}

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    @State private var showingAddTest = false
    @State private var editingTest: ProductTest?
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            // Background gradient with dark overlay
            AppTheme.mainGradient
                .ignoresSafeArea()

            AppTheme.darkOverlay
                .ignoresSafeArea()

            TabView(selection: $selectedTab) {
                pendingTestsView
                    .tabItem {
                        Label("À Faire", systemImage: "list.bullet")
                    }
                    .tag(0)

                completedTestsView
                    .tabItem {
                        Label("Terminés", systemImage: "checkmark.circle.fill")
                    }
                    .tag(1)
            }
            .accentColor(AppTheme.accentOrange)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            dataManager.loadTests()
        }
    }

    private var pendingTestsView: some View {
        NavigationView {
            ZStack {
                // Background gradient directly in this view
                AppTheme.mainGradient
                    .ignoresSafeArea()

                AppTheme.darkOverlay
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        urgentTestWidget
                            .padding(.top, 8)

                        LazyVStack(spacing: 12) {
                        ForEach(dataManager.pendingTests, id: \.id) { test in
                            if let index = dataManager.tests.firstIndex(where: { $0.id == test.id }) {
                                TestRowView(test: $dataManager.tests[index]) {
                                    dataManager.saveTests()
                                }
                                .onTapGesture {
                                    HapticManager.impact(.light)
                                    editingTest = dataManager.tests[index]
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        HapticManager.notification(.warning)
                                        withAnimation(.appSpring) {
                                            dataManager.tests.remove(at: index)
                                            dataManager.saveTests()
                                        }
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                                .contextMenu {
                                    Button {
                                        HapticManager.selection()
                                        editingTest = dataManager.tests[index]
                                    } label: {
                                        Label("Modifier", systemImage: "pencil")
                                    }

                                    Button {
                                        HapticManager.notification(.success)
                                        withAnimation(.appSpring) {
                                            dataManager.tests[index].isCompleted.toggle()
                                            dataManager.saveTests()
                                        }
                                    } label: {
                                        Label("Marquer terminé", systemImage: "checkmark.circle")
                                    }

                                    Button(role: .destructive) {
                                        HapticManager.notification(.warning)
                                        withAnimation(.appSpring) {
                                            dataManager.tests.remove(at: index)
                                            dataManager.saveTests()
                                        }
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
            }
            .navigationTitle("À Faire")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        HapticManager.impact(.light)
                        do {
                            try FirebaseManager.shared.signOut()
                            HapticManager.notification(.success)
                        } catch {
                            HapticManager.notification(.error)
                        }
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        HapticManager.impact(.light)
                        showingAddTest = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(AppTheme.buttonGradient)
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
            }
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showingAddTest) {
                AddTestView { newTest in
                    withAnimation(.appSpring) {
                        HapticManager.notification(.success)
                        dataManager.tests.append(newTest)
                        dataManager.saveTests()
                    }
                }
            }
            .sheet(item: $editingTest) { test in
                if let index = dataManager.tests.firstIndex(where: { $0.id == test.id }) {
                    EditTestView(test: $dataManager.tests[index]) {
                        dataManager.saveTests()
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    @ViewBuilder
    private var urgentTestWidget: some View {
        if let urgent = dataManager.mostUrgentTest {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                                .font(.caption)

                            Text("TEST URGENT")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                                .textCase(.uppercase)
                        }

                        Text(urgent.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: 6) {
                            Text(urgent.brand)
                                .font(.footnote)
                                .foregroundColor(AppTheme.textSecondary)

                            Text("•")
                                .font(.caption2)
                                .foregroundColor(AppTheme.textSecondary)

                            Text(urgent.priority.dropFirst(2))
                                .priorityChip(priority: urgent.priority)
                        }
                    }

                    Spacer()

                    VStack(spacing: 6) {
                        Text("\(dataManager.pendingTests.count)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text("À FAIRE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .cardStyle()

                HStack(spacing: 8) {
                    Image(systemName: "icloud")
                        .font(.caption2)
                        .foregroundColor(.blue)

                    Text(dataManager.iCloudStatus)
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
            .padding(.horizontal, 16)
        }
    }

    private var completedTestsView: some View {
        NavigationView {
            ZStack {
                // Background gradient directly in this view
                AppTheme.mainGradient
                    .ignoresSafeArea()

                AppTheme.darkOverlay
                    .ignoresSafeArea()

                ScrollView {
                    if dataManager.completedTests.isEmpty {
                    VStack(spacing: 32) {
                        Spacer()

                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 80))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, .green.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )

                            VStack(spacing: 8) {
                                Text("Aucun test terminé")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppTheme.textPrimary)

                                Text("Les tests marqués comme terminés apparaîtront ici")
                                    .font(.body)
                                    .foregroundColor(AppTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 400)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(dataManager.completedTests, id: \.id) { test in
                            if let index = dataManager.tests.firstIndex(where: { $0.id == test.id }) {
                                TestRowView(test: $dataManager.tests[index]) {
                                    dataManager.saveTests()
                                }
                                .onTapGesture {
                                    HapticManager.impact(.light)
                                    editingTest = dataManager.tests[index]
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        HapticManager.notification(.warning)
                                        withAnimation(.appSpring) {
                                            dataManager.tests.remove(at: index)
                                            dataManager.saveTests()
                                        }
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                                .contextMenu {
                                    Button {
                                        HapticManager.selection()
                                        editingTest = dataManager.tests[index]
                                    } label: {
                                        Label("Modifier", systemImage: "pencil")
                                    }

                                    Button {
                                        HapticManager.impact(.medium)
                                        withAnimation(.appSpring) {
                                            dataManager.tests[index].isCompleted.toggle()
                                            dataManager.saveTests()
                                        }
                                    } label: {
                                        Label("Marquer à faire", systemImage: "arrow.uturn.backward")
                                    }

                                    Button(role: .destructive) {
                                        HapticManager.notification(.warning)
                                        withAnimation(.appSpring) {
                                            dataManager.tests.remove(at: index)
                                            dataManager.saveTests()
                                        }
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
                }
            }
            .navigationTitle("Terminés")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ProductTest: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var brand: String
    var category: String
    var isCompleted: Bool = false
    var priority: String = "🟡 Moyenne"
    var notes: String = ""
    var dueDate: Date?
    var createdDate: Date = Date()
    var photoData: Data?
    var hasPhoto: Bool { photoData != nil }

    enum CodingKeys: String, CodingKey {
        case id, name, brand, category, isCompleted, priority, notes, dueDate, createdDate, photoData
    }
}

struct TestRowView: View {
    @Binding var test: ProductTest
    let onUpdate: () -> Void
    @State private var showConfetti = false

    var priorityColors: AppTheme.Priority {
        AppTheme.priorityColors(for: test.priority)
    }

    var body: some View {
        HStack(spacing: 16) {
            Button {
                HapticManager.impact(.medium)

                if !test.isCompleted {
                    // Show confetti first
                    showConfetti = true

                    // Delay the completion toggle to show the animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        withAnimation(.appSpringBouncy) {
                            test.isCompleted = true
                            onUpdate()
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                            showConfetti = false
                        }
                    }
                } else {
                    // Unchecking is immediate
                    withAnimation(.appSpringBouncy) {
                        test.isCompleted = false
                        onUpdate()
                    }
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(test.isCompleted ? AppTheme.accentGreen : Color.white.opacity(0.3), lineWidth: 2.5)
                        .frame(width: 26, height: 26)

                    if test.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppTheme.accentGreen)
                            .scaleEffect(test.isCompleted ? 1.0 : 0.5)
                            .animation(.appSpringBouncy, value: test.isCompleted)
                    }
                }
                .overlay(
                    Group {
                        if showConfetti {
                            ConfettiView()
                        }
                    }
                )
            }
            .buttonStyle(.plain)

            ZStack {
                if let photoData = test.photoData,
                   let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(priorityColors.textColor.opacity(0.6), lineWidth: 2.5)
                        )
                } else {
                    Text(String(test.category.dropFirst(2).prefix(2)))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.3))
                                .overlay(
                                    Circle()
                                        .stroke(priorityColors.textColor.opacity(0.6), lineWidth: 2.5)
                                )
                        )
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(test.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(test.isCompleted ? AppTheme.textSecondary : AppTheme.textPrimary)
                        .strikethrough(test.isCompleted)
                        .lineLimit(2)

                    Spacer()

                    Text(test.priority.dropFirst(2))
                        .priorityChip(priority: test.priority)
                }

                HStack(spacing: 8) {
                    Text(test.brand)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.textSecondary)

                    Text("•")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)

                    Text(test.category.dropFirst(2))
                        .font(.subheadline)
                        .foregroundColor(AppTheme.accentOrange)
                        .fontWeight(.medium)

                    Spacer()
                }

                if !test.notes.isEmpty {
                    Text(test.notes)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 22)
        .padding(.horizontal, 20)
        .cardStyle(isCompleted: test.isCompleted)
        .animation(.appSpring, value: test.isCompleted)
    }
}

class DataManager: ObservableObject {
    @Published var tests: [ProductTest] = []
    @Published var iCloudStatus = "☁️ Firebase"

    private let firebaseManager = FirebaseManager.shared
    private var listener: ListenerRegistration?

    init() {
        setupFirestoreListener()
    }

    private func setupFirestoreListener() {
        guard let collection = firebaseManager.getUserTestsCollection() else {
            loadDefaultTests()
            return
        }

        // Écouter les changements en temps réel
        listener = collection.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Erreur Firestore: \(error.localizedDescription)")
                self.iCloudStatus = "⚠️ Erreur sync"
                return
            }

            guard let documents = snapshot?.documents else {
                self.loadDefaultTests()
                return
            }

            DispatchQueue.main.async {
                if documents.isEmpty {
                    self.loadDefaultTests()
                } else {
                    self.tests = documents.compactMap { doc -> ProductTest? in
                        guard let data = try? JSONSerialization.data(withJSONObject: doc.data()),
                              var test = try? JSONDecoder().decode(ProductTest.self, from: data) else {
                            return nil
                        }
                        test.id = doc.documentID
                        return test
                    }
                    self.iCloudStatus = "☁️ Synchronisé"
                }
            }
        }
    }

    private func loadDefaultTests() {
        guard tests.isEmpty else { return }

        tests = [
            ProductTest(name: "iPhone 15 Pro", brand: "Apple", category: "📱 Smartphone", priority: "🔴 Urgente", notes: "Test camera et performance"),
            ProductTest(name: "Roomba j7+", brand: "iRobot", category: "🤖 Aspirateur Robot", priority: "🟡 Moyenne", notes: "Test navigation intelligente"),
            ProductTest(name: "MacBook Air M2", brand: "Apple", category: "💻 Ordinateur", priority: "🔴 Urgente", notes: "Test autonomie et vitesse"),
            ProductTest(name: "Anker PowerCore", brand: "Anker", category: "🔋 Batterie", priority: "🟢 Faible", notes: "Test capacité de charge"),
            ProductTest(name: "Worx Landroid", brand: "Worx", category: "🌱 Tondeuse Robot", priority: "🟡 Moyenne", notes: "Test précision de coupe")
        ]

        // Sauvegarder dans Firestore
        for test in tests {
            Task {
                await addTest(test)
            }
        }
    }

    var pendingTests: [ProductTest] {
        tests.filter { !$0.isCompleted }
    }

    var completedTests: [ProductTest] {
        tests.filter { $0.isCompleted }
    }

    var mostUrgentTest: ProductTest? {
        pendingTests.first { $0.priority.contains("🔴") } ??
        pendingTests.first { $0.priority.contains("🟠") } ??
        pendingTests.first { $0.priority.contains("🟡") } ??
        pendingTests.first
    }

    func loadTests() {
        // Les tests sont chargés automatiquement via le listener
    }

    func saveTests() {
        // Deprecated - utiliser updateTest() à la place
    }

    func addTest(_ test: ProductTest) async {
        guard let collection = firebaseManager.getUserTestsCollection() else { return }

        do {
            let data = try JSONEncoder().encode(test)
            let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            try await collection.document(test.id).setData(dict)
            iCloudStatus = "☁️ Synchronisé"
        } catch {
            print("Erreur ajout: \(error.localizedDescription)")
            iCloudStatus = "⚠️ Erreur sync"
        }
    }

    func updateTest(_ test: ProductTest) async {
        guard let collection = firebaseManager.getUserTestsCollection() else { return }

        do {
            let data = try JSONEncoder().encode(test)
            let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            try await collection.document(test.id).setData(dict, merge: true)
            iCloudStatus = "☁️ Synchronisé"
        } catch {
            print("Erreur update: \(error.localizedDescription)")
            iCloudStatus = "⚠️ Erreur sync"
        }
    }

    func deleteTest(_ test: ProductTest) async {
        guard let collection = firebaseManager.getUserTestsCollection() else { return }

        do {
            try await collection.document(test.id).delete()
            iCloudStatus = "☁️ Synchronisé"
        } catch {
            print("Erreur suppression: \(error.localizedDescription)")
            iCloudStatus = "⚠️ Erreur sync"
        }
    }

    deinit {
        listener?.remove()
    }
}

struct EditTestView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var test: ProductTest
    let onSave: () -> Void

    @State private var name: String
    @State private var brand: String
    @State private var selectedCategory: String
    @State private var selectedPriority: String
    @State private var notes: String
    @State private var photoData: Data?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var isLoadingWebImage = false

    let categories = [
        "📱 Smartphone", "🤖 Aspirateur Robot", "🔋 Batterie", "💻 Ordinateur",
        "🌱 Tondeuse Robot", "📱 Tablette", "⌚ Montre Connectée", "🎧 Casque Audio"
    ]

    let priorities = ["🟢 Faible", "🟡 Moyenne", "🟠 Élevée", "🔴 Urgente"]

    init(test: Binding<ProductTest>, onSave: @escaping () -> Void) {
        self._test = test
        self.onSave = onSave
        self._name = State(initialValue: test.wrappedValue.name)
        self._brand = State(initialValue: test.wrappedValue.brand)
        self._selectedCategory = State(initialValue: test.wrappedValue.category)
        self._selectedPriority = State(initialValue: test.wrappedValue.priority)
        self._notes = State(initialValue: test.wrappedValue.notes)
        self._photoData = State(initialValue: test.wrappedValue.photoData)
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.mainGradient.ignoresSafeArea()
                AppTheme.darkOverlay.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        informationSection
                        photoSection
                        categorySection
                        prioritySection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Modifier")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    saveButton
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(photoData: $photoData, sourceType: showingCamera ? .camera : .photoLibrary)
        }
        .onChange(of: showingCamera) { _, isShowing in
            if isShowing {
                showingImagePicker = true
                showingCamera = false
            }
        }
    }

    private var informationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Informations")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)

            VStack(spacing: 12) {
                TextField("Nom du produit", text: $name)
                    .customTextFieldStyle()

                TextField("Marque", text: $brand)
                    .customTextFieldStyle()

                TextField("Notes (optionnel)", text: $notes, axis: .vertical)
                    .customTextFieldStyle()
                    .lineLimit(3...5)
            }
        }
        .padding(20)
        .glassSurface()
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Photo du produit")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)

            if let photoData = photoData,
               let uiImage = UIImage(data: photoData) {
                photoPreview(uiImage: uiImage)
            } else {
                photoButtons
            }
        }
        .padding(20)
        .glassSurface()
    }

    private func photoPreview(uiImage: UIImage) -> some View {
        HStack(spacing: 16) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppTheme.cardBorder, lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 8) {
                Text("Photo ajoutée")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.accentGreen)

                Button("Changer") {
                    HapticManager.selection()
                    showingImagePicker = true
                }
                .foregroundColor(AppTheme.accentOrange)
            }
            Spacer()
        }
    }

    private var photoButtons: some View {
        HStack(spacing: 16) {
            photoButton(icon: "camera.fill", title: "Caméra", color: Color(red: 10/255, green: 132/255, blue: 255/255)) {
                HapticManager.impact(.light)
                showingCamera = true
            }

            photoButton(icon: "photo.fill", title: "Galerie", color: Color(red: 48/255, green: 209/255, blue: 88/255)) {
                HapticManager.impact(.light)
                showingImagePicker = true
            }

            Group {
                if isLoadingWebImage {
                    VStack(spacing: 8) {
                        ProgressView().frame(width: 56, height: 56)
                        Text("Web").font(.caption).fontWeight(.medium).foregroundColor(AppTheme.textSecondary)
                    }
                } else {
                    photoButton(icon: "globe", title: "Web", color: Color(red: 172/255, green: 142/255, blue: 104/255)) {
                        HapticManager.impact(.light)
                        searchWebImage()
                    }
                    .disabled(name.isEmpty)
                }
            }
            Spacer()
        }
    }

    private func photoButton(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(color))
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .buttonStyle(.plain)
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Catégorie")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            HapticManager.selection()
                            withAnimation(.appSpringFast) {
                                selectedCategory = category
                            }
                        }) {
                            Text(category)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(selectedCategory == category ? .white : AppTheme.textSecondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(selectedCategory == category ? AppTheme.accentOrange : Color.white.opacity(0.1))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(20)
        .glassSurface()
    }

    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Priorité")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)

            HStack(spacing: 12) {
                ForEach(priorities, id: \.self) { priority in
                    priorityButton(priority)
                }
            }
        }
        .padding(20)
        .glassSurface()
    }

    private func priorityButton(_ priority: String) -> some View {
        let isSelected = selectedPriority == priority
        let colors = AppTheme.priorityColors(for: priority)

        return Button(action: {
            HapticManager.selection()
            withAnimation(.appSpringFast) {
                selectedPriority = priority
            }
        }) {
            VStack(spacing: 6) {
                Text(priority.prefix(2)).font(.title2)
                Text(priority.dropFirst(2))
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? colors.backgroundColor : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? colors.textColor.opacity(0.5) : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var cancelButton: some View {
        Button("Annuler") {
            HapticManager.selection()
            presentationMode.wrappedValue.dismiss()
        }
        .foregroundColor(Color(red: 142/255, green: 142/255, blue: 147/255))
    }

    private var saveButton: some View {
        Button(action: saveTest) {
            Text("Enregistrer")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if name.isEmpty || brand.isEmpty {
                            Capsule().fill(Color.gray.opacity(0.5))
                        } else {
                            Capsule().fill(AppTheme.buttonGradient)
                        }
                    }
                )
        }
        .disabled(name.isEmpty || brand.isEmpty)
    }

    private func saveTest() {
        HapticManager.notification(.success)
        test.name = name
        test.brand = brand
        test.category = selectedCategory
        test.priority = selectedPriority
        test.notes = notes
        test.photoData = photoData
        onSave()
        presentationMode.wrappedValue.dismiss()
    }

    private func searchWebImage() {
        guard !name.isEmpty else { return }

        isLoadingWebImage = true

        let searchQuery = "\(name) \(brand) product image"
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let imageSearchURL = "https://source.unsplash.com/400x400/?\(encodedQuery)"

        guard let url = URL(string: imageSearchURL) else {
            isLoadingWebImage = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoadingWebImage = false

                if let data = data,
                   let image = UIImage(data: data),
                   let jpegData = image.jpegData(compressionQuality: 0.8) {
                    self.photoData = jpegData
                } else {
                    self.createPlaceholderImage()
                }
            }
        }.resume()
    }

    private func createPlaceholderImage() {
        let size = CGSize(width: 200, height: 200)
        UIGraphicsBeginImageContext(size)

        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.systemBlue.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor.white
        ]

        let text = String(selectedCategory.dropFirst(2).prefix(2))
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )

        text.draw(in: textRect, withAttributes: attributes)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if let image = image,
           let data = image.jpegData(compressionQuality: 0.8) {
            self.photoData = data
        }
    }
}

struct AddTestView: View {
    @Environment(\.presentationMode) var presentationMode
    let onSave: (ProductTest) -> Void

    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var selectedCategory: String = "📱 Smartphone"
    @State private var selectedPriority: String = "🟡 Moyenne"
    @State private var notes: String = ""
    @State private var photoData: Data?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingWebSearch = false
    @State private var isLoadingWebImage = false

    let categories = [
        "📱 Smartphone", "🤖 Aspirateur Robot", "🔋 Batterie", "💻 Ordinateur",
        "🌱 Tondeuse Robot", "📱 Tablette", "⌚ Montre Connectée", "🎧 Casque Audio"
    ]

    let priorities = ["🟢 Faible", "🟡 Moyenne", "🟠 Élevée", "🔴 Urgente"]

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.mainGradient.ignoresSafeArea()
                AppTheme.darkOverlay.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        informationSection
                        photoSection
                        categorySection
                        prioritySection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Nouveau Test")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(photoData: $photoData, sourceType: showingCamera ? .camera : .photoLibrary)
        }
        .onChange(of: showingCamera) { _, isShowing in
            if isShowing {
                showingImagePicker = true
                showingCamera = false
            }
        }
    }

    private var informationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Informations")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)

            VStack(spacing: 12) {
                TextField("Nom du produit", text: $name)
                    .customTextFieldStyle()

                TextField("Marque", text: $brand)
                    .customTextFieldStyle()

                TextField("Notes (optionnel)", text: $notes, axis: .vertical)
                    .customTextFieldStyle()
                    .lineLimit(3...5)
            }
        }
        .padding(20)
        .glassSurface()
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Photo du produit")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)

            if let photoData = photoData,
               let uiImage = UIImage(data: photoData) {
                photoPreview(uiImage: uiImage)
            } else {
                photoButtons
            }
        }
        .padding(20)
        .glassSurface()
    }

    private func photoPreview(uiImage: UIImage) -> some View {
        HStack(spacing: 16) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppTheme.cardBorder, lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 8) {
                Text("Photo ajoutée")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.accentGreen)

                Button("Changer") {
                    HapticManager.selection()
                    showingImagePicker = true
                }
                .foregroundColor(AppTheme.accentOrange)
            }
            Spacer()
        }
    }

    private var photoButtons: some View {
        HStack(spacing: 16) {
            photoButton(icon: "camera.fill", title: "Caméra", color: Color(red: 10/255, green: 132/255, blue: 255/255)) {
                HapticManager.impact(.light)
                showingCamera = true
            }

            photoButton(icon: "photo.fill", title: "Galerie", color: Color(red: 48/255, green: 209/255, blue: 88/255)) {
                HapticManager.impact(.light)
                showingImagePicker = true
            }

            Group {
                if isLoadingWebImage {
                    VStack(spacing: 8) {
                        ProgressView().frame(width: 56, height: 56)
                        Text("Web").font(.caption).fontWeight(.medium).foregroundColor(AppTheme.textSecondary)
                    }
                } else {
                    photoButton(icon: "globe", title: "Web", color: Color(red: 172/255, green: 142/255, blue: 104/255)) {
                        HapticManager.impact(.light)
                        searchWebImage()
                    }
                    .disabled(name.isEmpty)
                }
            }
            Spacer()
        }
    }

    private func photoButton(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(color))
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .buttonStyle(.plain)
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Catégorie")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            HapticManager.selection()
                            withAnimation(.appSpringFast) {
                                selectedCategory = category
                            }
                        }) {
                            Text(category)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(selectedCategory == category ? .white : AppTheme.textSecondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(selectedCategory == category ? AppTheme.accentOrange : Color.white.opacity(0.1))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(20)
        .glassSurface()
    }

    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Priorité")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)

            HStack(spacing: 12) {
                ForEach(priorities, id: \.self) { priority in
                    priorityButton(priority)
                }
            }
        }
        .padding(20)
        .glassSurface()
    }

    private func priorityButton(_ priority: String) -> some View {
        let isSelected = selectedPriority == priority
        let colors = AppTheme.priorityColors(for: priority)

        return Button(action: {
            HapticManager.selection()
            withAnimation(.appSpringFast) {
                selectedPriority = priority
            }
        }) {
            VStack(spacing: 6) {
                Text(priority.prefix(2)).font(.title2)
                Text(priority.dropFirst(2))
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? colors.backgroundColor : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? colors.textColor.opacity(0.5) : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var cancelButton: some View {
        Button("Annuler") {
            HapticManager.selection()
            presentationMode.wrappedValue.dismiss()
        }
        .foregroundColor(Color(red: 142/255, green: 142/255, blue: 147/255))
    }

    private var addButton: some View {
        Button(action: saveTest) {
            Text("Ajouter")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if name.isEmpty || brand.isEmpty {
                            Capsule().fill(Color.gray.opacity(0.5))
                        } else {
                            Capsule().fill(AppTheme.buttonGradient)
                        }
                    }
                )
        }
        .disabled(name.isEmpty || brand.isEmpty)
    }

    private func saveTest() {
        HapticManager.notification(.success)
        var newTest = ProductTest(
            name: name,
            brand: brand,
            category: selectedCategory,
            priority: selectedPriority,
            notes: notes
        )
        newTest.photoData = photoData
        onSave(newTest)
        presentationMode.wrappedValue.dismiss()
    }

    private func searchWebImage() {
        guard !name.isEmpty else { return }

        isLoadingWebImage = true

        let searchQuery = "\(name) \(brand) product image"
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        // Using a simple approach to get a product image from the web
        // In a real app, you'd use a proper image search API
        let imageSearchURL = "https://source.unsplash.com/400x400/?\(encodedQuery)"

        guard let url = URL(string: imageSearchURL) else {
            isLoadingWebImage = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoadingWebImage = false

                if let data = data,
                   let image = UIImage(data: data),
                   let jpegData = image.jpegData(compressionQuality: 0.8) {
                    self.photoData = jpegData
                } else {
                    // Fallback: create a placeholder image
                    self.createPlaceholderImage()
                }
            }
        }.resume()
    }

    private func createPlaceholderImage() {
        let size = CGSize(width: 200, height: 200)
        UIGraphicsBeginImageContext(size)

        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.systemBlue.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor.white
        ]

        let text = String(selectedCategory.dropFirst(2).prefix(2))
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )

        text.draw(in: textRect, withAttributes: attributes)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if let image = image,
           let data = image.jpegData(compressionQuality: 0.8) {
            self.photoData = data
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var photoData: Data?
    let sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage,
               let data = image.jpegData(compressionQuality: 0.8) {
                parent.photoData = data
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// Custom TextField Style
// Custom modifier pour styliser les TextFields
extension View {
    func customTextFieldStyle() -> some View {
        self
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 44/255, green: 44/255, blue: 46/255))
            )
            .foregroundColor(AppTheme.textPrimary)
    }
}

struct ConfettiView: View {
    @State private var animate = false
    let particles: [(color: Color, xOffset: CGFloat, yOffset: CGFloat)] = {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        return (0..<15).map { _ in
            (
                color: colors.randomElement() ?? .blue,
                xOffset: CGFloat.random(in: -60...60),
                yOffset: CGFloat.random(in: -60...60)
            )
        }
    }()

    var body: some View {
        ZStack {
            ForEach(0..<15, id: \.self) { index in
                Circle()
                    .fill(particles[index].color)
                    .frame(width: 8, height: 8)
                    .offset(
                        x: animate ? particles[index].xOffset : 0,
                        y: animate ? particles[index].yOffset : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .scaleEffect(animate ? 2 : 0.5)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                animate = true
            }
        }
    }
}

#Preview {
    ContentView()
}