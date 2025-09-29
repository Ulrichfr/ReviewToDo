import SwiftUI
import Combine
import CloudKit

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    @State private var showingAddTest = false
    @State private var selectedTab = 0

    var pendingTests: [ProductTest] {
        dataManager.tests.filter { !$0.isCompleted }
    }

    var completedTests: [ProductTest] {
        dataManager.tests.filter { $0.isCompleted }
    }

    var mostUrgentTest: ProductTest? {
        pendingTests.first { $0.priority.contains("🔴") } ??
        pendingTests.first { $0.priority.contains("🟠") } ??
        pendingTests.first { $0.priority.contains("🟡") } ??
        pendingTests.first
    }

    var body: some View {
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
        .preferredColorScheme(.dark)
        .accentColor(.orange)
        .onAppear {
            dataManager.loadTests()
        }
    }

    private var pendingTestsView: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    urgentTestWidget
                        .padding(.top, 8)

                    LazyVStack(spacing: 12) {
                        ForEach(dataManager.tests.indices.filter { !dataManager.tests[$0].isCompleted }, id: \.self) { index in
                            TestRowView(test: $dataManager.tests[index]) {
                                dataManager.saveTests()
                            }
                            .contextMenu {
                                Button {
                                    withAnimation(.spring()) {
                                        dataManager.tests[index].isCompleted.toggle()
                                        dataManager.saveTests()
                                    }
                                } label: {
                                    Label("Marquer terminé", systemImage: "checkmark.circle")
                                }

                                Button(role: .destructive) {
                                    withAnimation(.easeInOut) {
                                        dataManager.tests.remove(at: index)
                                        dataManager.saveTests()
                                    }
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("À Faire")
            .navigationBarTitleDisplayMode(.large)
            .navigationSubtitle(dataManager.iCloudStatus)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTest = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color.orange)
                                    .shadow(color: .orange.opacity(0.4), radius: 6, x: 0, y: 3)
                            )
                    }
                }
            }
            .sheet(isPresented: $showingAddTest) {
                AddTestView { newTest in
                    withAnimation(.spring()) {
                        dataManager.tests.append(newTest)
                        dataManager.saveTests()
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var completedTestsView: some View {
        NavigationView {
            ScrollView {
                if completedTests.isEmpty {
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
                                    .foregroundColor(.primary)

                                Text("Les tests marqués comme terminés apparaîtront ici")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 400)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(dataManager.tests.indices.filter { dataManager.tests[$0].isCompleted }, id: \.self) { index in
                            TestRowView(test: $dataManager.tests[index]) {
                                dataManager.saveTests()
                            }
                            .contextMenu {
                                Button {
                                    withAnimation(.spring()) {
                                        dataManager.tests[index].isCompleted.toggle()
                                        dataManager.saveTests()
                                    }
                                } label: {
                                    Label("Marquer à faire", systemImage: "arrow.uturn.backward")
                                }

                                Button(role: .destructive) {
                                    withAnimation(.easeInOut) {
                                        dataManager.tests.remove(at: index)
                                        dataManager.saveTests()
                                    }
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Terminés")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    @ViewBuilder
    private var urgentTestWidget: some View {
        if let urgent = mostUrgentTest {
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
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: 6) {
                            Text(urgent.brand)
                                .font(.footnote)
                                .foregroundColor(.secondary)

                            Text("•")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            Text(urgent.priority)
                                .font(.footnote)
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                        }
                    }

                    Spacer()

                    VStack(spacing: 6) {
                        Text("\(pendingTests.count)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text("RESTANTS")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1.5)
                            .shadow(color: Color.orange.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemGray6))
                        .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
                )
                .padding(.horizontal, 16)
            }
        }
    }
}

struct ProductTest: Codable, Identifiable {
    let id = UUID()
    var name: String
    var brand: String
    var category: String
    var isCompleted: Bool = false
    var priority: String = "🟡 Moyenne"

    enum CodingKeys: String, CodingKey {
        case name, brand, category, isCompleted, priority
    }
}

struct TestRowView: View {
    @Binding var test: ProductTest
    let onUpdate: () -> Void

    var priorityColor: Color {
        if test.priority.contains("🔴") { return .red }
        if test.priority.contains("🟠") { return .orange }
        if test.priority.contains("🟡") { return .yellow }
        return .green
    }

    var body: some View {
        HStack(spacing: 16) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    test.isCompleted.toggle()
                    onUpdate()
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(test.isCompleted ? .green : .gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if test.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.green)
                            .scaleEffect(test.isCompleted ? 1.0 : 0.5)
                            .animation(.spring(response: 0.3), value: test.isCompleted)
                    }
                }
            }
            .buttonStyle(.plain)

            Text(String(test.category.prefix(2)))
                .font(.title2)
                .fontWeight(.bold)
                .frame(width: 52, height: 52)
                .background(
                    Circle()
                        .fill(priorityColor.opacity(0.15))
                        .stroke(priorityColor.opacity(0.5), lineWidth: 2)
                        .shadow(color: priorityColor.opacity(0.2), radius: 4, x: 0, y: 2)
                )

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(test.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(test.isCompleted ? .secondary : .primary)
                        .strikethrough(test.isCompleted)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Text(test.priority.dropFirst(2))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(priorityColor)
                                .shadow(color: priorityColor.opacity(0.3), radius: 3, x: 0, y: 1)
                        )
                }

                HStack(spacing: 8) {
                    Text(test.brand)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(test.category.dropFirst(3))
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .fontWeight(.medium)

                    Spacer()
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
                .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .opacity(test.isCompleted ? 0.7 : 1.0)
        .scaleEffect(test.isCompleted ? 0.98 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: test.isCompleted)
    }
}

struct AddTestView: View {
    @Environment(\.presentationMode) var presentationMode
    let onSave: (ProductTest) -> Void

    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var selectedCategory: String = "📱 Smartphone"
    @State private var selectedPriority: String = "🟡 Moyenne"

    let categories = [
        "📱 Smartphone", "🤖 Aspirateur Robot", "🔋 Batterie", "💻 Ordinateur",
        "🌱 Tondeuse Robot", "📱 Tablette", "⌚ Montre Connectée", "🎧 Casque Audio",
        "🔊 Enceinte", "📷 Appareil Photo", "🎮 Gaming", "🏠 Électroménager"
    ]

    let priorities = ["🟢 Faible", "🟡 Moyenne", "🟠 Élevée", "🔴 Urgente"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Nom du produit")
                                .font(.headline)
                                .foregroundColor(.primary)

                            TextField("Ex: iPhone 16 Pro", text: $name)
                                .textFieldStyle(.roundedBorder)
                                .font(.body)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Marque")
                                .font(.headline)
                                .foregroundColor(.primary)

                            TextField("Ex: Apple", text: $brand)
                                .textFieldStyle(.roundedBorder)
                                .font(.body)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Catégorie")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Picker("Catégorie", selection: $selectedCategory) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            .pickerStyle(.menu)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                                    .stroke(Color(.separator), lineWidth: 0.5)
                            )
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Priorité")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Picker("Priorité", selection: $selectedPriority) {
                                ForEach(priorities, id: \.self) { priority in
                                    Text(priority).tag(priority)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                            .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
                    )

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Suggestions rapides")
                            .font(.headline)
                            .foregroundColor(.primary)

                        VStack(spacing: 12) {
                            suggestionButton(
                                title: "iPhone 16 Pro",
                                subtitle: "Apple • Smartphone",
                                icon: "📱",
                                action: {
                                    name = "iPhone 16 Pro"
                                    brand = "Apple"
                                    selectedCategory = "📱 Smartphone"
                                    selectedPriority = "🔴 Urgente"
                                }
                            )

                            suggestionButton(
                                title: "AirPods Pro 2",
                                subtitle: "Apple • Casque Audio",
                                icon: "🎧",
                                action: {
                                    name = "AirPods Pro 2"
                                    brand = "Apple"
                                    selectedCategory = "🎧 Casque Audio"
                                    selectedPriority = "🟡 Moyenne"
                                }
                            )

                            suggestionButton(
                                title: "Tesla Model Y",
                                subtitle: "Tesla • Automobile",
                                icon: "🚗",
                                action: {
                                    name = "Tesla Model Y"
                                    brand = "Tesla"
                                    selectedCategory = "🚗 Automobile"
                                    selectedPriority = "🔴 Urgente"
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
            }
            .navigationTitle("Nouveau Test")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.secondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ajouter") {
                        let newTest = ProductTest(
                            name: name,
                            brand: brand,
                            category: selectedCategory,
                            priority: selectedPriority
                        )
                        onSave(newTest)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty || brand.isEmpty)
                    .fontWeight(.semibold)
                    .foregroundColor(name.isEmpty || brand.isEmpty ? .secondary : .orange)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func suggestionButton(title: String, subtitle: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(icon)
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

class DataManager: ObservableObject {
    @Published var tests: [ProductTest] = []
    private var container: CKContainer?
    private var database: CKDatabase?
    @Published var iCloudStatus = "Initialisation..."

    init() {
        loadDefaultTests()
        initializeCloudKit()
    }

    private func initializeCloudKit() {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2.0) {
            // Safely check if CloudKit is available
            guard FileManager.default.ubiquityIdentityToken != nil else {
                DispatchQueue.main.async {
                    self.iCloudStatus = "⚠️ iCloud non connecté"
                }
                return
            }

            // Try to initialize CloudKit safely
            DispatchQueue.main.async {
                self.iCloudStatus = "🔄 Initialisation CloudKit..."

                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.0) {
                    self.attemptCloudKitInitialization()
                }
            }
        }
    }

    private func attemptCloudKitInitialization() {
        let container: CKContainer
        let database: CKDatabase

        do {
            container = CKContainer.default()
            database = container.privateCloudDatabase

            DispatchQueue.main.async {
                self.container = container
                self.database = database
                self.checkiCloudStatus()
            }
        } catch {
            DispatchQueue.main.async {
                self.iCloudStatus = "❌ CloudKit indisponible"
                print("CloudKit error: \(error)")
            }
        }
    }

    private func loadDefaultTests() {
        tests = [
            ProductTest(name: "iPhone 15 Pro", brand: "Apple", category: "📱 Smartphone", priority: "🔴 Urgente"),
            ProductTest(name: "Roomba j7+", brand: "iRobot", category: "🤖 Aspirateur Robot", priority: "🟡 Moyenne"),
            ProductTest(name: "MacBook Air M2", brand: "Apple", category: "💻 Ordinateur", priority: "🔴 Urgente"),
            ProductTest(name: "Anker PowerCore", brand: "Anker", category: "🔋 Batterie", priority: "🟢 Faible"),
            ProductTest(name: "Worx Landroid", brand: "Worx", category: "🌱 Tondeuse Robot", priority: "🟡 Moyenne")
        ]
    }

    private func checkiCloudStatus() {
        guard let container = container else {
            iCloudStatus = "❌ CloudKit non initialisé"
            return
        }

        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self?.iCloudStatus = "☁️ iCloud connecté"
                    self?.loadFromiCloud()
                case .noAccount:
                    self?.iCloudStatus = "⚠️ Pas de compte iCloud"
                case .restricted:
                    self?.iCloudStatus = "⚠️ iCloud restreint"
                case .couldNotDetermine:
                    self?.iCloudStatus = "⚠️ Statut iCloud inconnu"
                case .temporarilyUnavailable:
                    self?.iCloudStatus = "⚠️ iCloud temporairement indisponible"
                @unknown default:
                    self?.iCloudStatus = "⚠️ Erreur iCloud"
                }
            }
        }
    }

    func loadTests() {
        // Charger depuis UserDefaults d'abord (cache local)
        if let data = UserDefaults.standard.data(forKey: "ReviewToDoTests"),
           let decodedTests = try? JSONDecoder().decode([ProductTest].self, from: data) {
            tests = decodedTests
        }

        // Puis synchroniser avec iCloud
        loadFromiCloud()
    }

    func saveTests() {
        // Sauvegarder localement (cache rapide)
        if let encoded = try? JSONEncoder().encode(tests) {
            UserDefaults.standard.set(encoded, forKey: "ReviewToDoTests")
        }

        // Sauvegarder sur iCloud
        saveToiCloud()
    }

    private func loadFromiCloud() {
        guard let database = database else {
            iCloudStatus = "❌ Base de données iCloud non disponible"
            return
        }

        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "ProductTest", predicate: predicate)

        database.perform(query, inZoneWith: nil) { [weak self] records, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Erreur chargement iCloud: \(error.localizedDescription)")
                    self?.iCloudStatus = "❌ Erreur de synchronisation"
                    return
                }

                if let records = records, !records.isEmpty {
                    let cloudTests = records.compactMap { record -> ProductTest? in
                        guard let name = record["name"] as? String,
                              let brand = record["brand"] as? String,
                              let category = record["category"] as? String else { return nil }

                        let isCompleted = record["isCompleted"] as? Bool ?? false
                        let priority = record["priority"] as? String ?? "🟡 Moyenne"

                        return ProductTest(name: name, brand: brand, category: category,
                                         isCompleted: isCompleted, priority: priority)
                    }

                    // Mettre à jour seulement si on a des données différentes
                    if !cloudTests.isEmpty {
                        self?.tests = cloudTests
                        self?.iCloudStatus = "☁️ Synchronisé avec iCloud"

                        // Mettre à jour le cache local
                        if let encoded = try? JSONEncoder().encode(cloudTests) {
                            UserDefaults.standard.set(encoded, forKey: "ReviewToDoTests")
                        }
                    }
                } else {
                    self?.iCloudStatus = "☁️ iCloud vide - première synchronisation"
                    // Si iCloud est vide, sauvegarder les données locales
                    self?.saveToiCloud()
                }
            }
        }
    }

    private func saveToiCloud() {
        guard let database = database else {
            iCloudStatus = "❌ Base de données iCloud non disponible"
            return
        }

        // Supprimer tous les anciens enregistrements
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "ProductTest", predicate: predicate)

        database.perform(query, inZoneWith: nil) { [weak self] records, error in
            if let records = records {
                let deleteOperations = records.map { record in
                    CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [record.recordID])
                }
                deleteOperations.forEach { self?.database?.add($0) }
            }

            // Ajouter les nouveaux enregistrements
            DispatchQueue.main.async {
                self?.saveNewRecordsToiCloud()
            }
        }
    }

    private func saveNewRecordsToiCloud() {
        let records = tests.map { test -> CKRecord in
            let record = CKRecord(recordType: "ProductTest")
            record["name"] = test.name
            record["brand"] = test.brand
            record["category"] = test.category
            record["isCompleted"] = test.isCompleted
            record["priority"] = test.priority
            return record
        }

        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        operation.modifyRecordsCompletionBlock = { [weak self] savedRecords, deletedRecords, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Erreur sauvegarde iCloud: \(error.localizedDescription)")
                    self?.iCloudStatus = "❌ Erreur de sauvegarde"
                } else {
                    self?.iCloudStatus = "☁️ Sauvegardé sur iCloud"
                }
            }
        }

        database?.add(operation)
    }
}

#Preview {
    ContentView()
}