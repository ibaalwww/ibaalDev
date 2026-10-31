import SwiftUI
import UIKit
import PhotosUI

@main
struct AppleResellerConsoleApp: App {
    var body: some Scene {
        WindowGroup {
            AppleMockupView()
        }
    }
}

// Struktur Data untuk Riwayat Order
struct OrderHistoryItem: Identifiable, Codable {
    let id: String
    let dateStr: String
    let buyerName: String
    let udid: String
    let planName: String
    let price: String
    let serialNumber: String
    let expiryDate: String
}

struct AppleMockupView: View {
    @AppStorage("mock_balance") private var balanceUSD: Double = 900.00
    @AppStorage("mock_admin_name") private var adminName: String = "iBaaL Enterprise Partner"
    @AppStorage("mock_team_id") private var teamID: String = "9K48LM2P1Q"
    
    // Harga modal disimpan di settingan Admin
    @AppStorage("mock_price_3m") private var price3M: String = "1.46"
    @AppStorage("mock_price_5m") private var price5M: String = "2.20"
    @AppStorage("mock_price_12m") private var price12M: String = "4.50"
    
    // Menyimpan riwayat order dalam bentuk JSON di AppStorage
    @AppStorage("mock_history_json") private var historyDataJSON: String = "[]"
    
    @State private var selectedPlanIndex: Int = 0
    @State private var buyerUDID: String = ""
    @State private var buyerName: String = ""
    @State private var certPassword: String = "ibaalcert"
    
    @State private var isProcessing: Bool = false
    @State private var logMessages: [String] = ["System initialized. Ready to dispatch..."]
    @State private var isCompleted: Bool = false
    
    // Metadata Hasil Generate Terakhir
    @State private var lastSerialNumber: String = ""
    @State private var lastExpiryDate: String = ""
    @State private var lastOrderId: String = ""
    
    @State private var showSettingsModal: Bool = false
    @State private var tempBalance: String = ""
    @State private var tempAdminName: String = ""
    @State private var tempTeamID: String = ""
    @State private var tempPrice3M: String = ""
    @State private var tempPrice5M: String = ""
    @State private var tempPrice12M: String = ""
    
    // State untuk Picker Foto Profil
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var profileImageData: Data? = nil

    let planShortNames = ["3 Months", "5 Months", "12 Months"]
    let planFullNames = ["SALE Plan 3 Months", "SALE Plan 5 Months", "SALE Plan 12 Months"]
    let planMonthsCount = [3, 5, 12]

    var currentPlanPriceDouble: Double {
        let str = switch selectedPlanIndex {
        case 0: price3M
        case 1: price5M
        default: price12M
        }
        return Double(str) ?? 1.46
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 18) {
                    
                    // Header Saldo & Admin (Tap untuk buka settingan Admin & Ganti Foto)
                    Button(action: {
                        hideKeyboard()
                        tempBalance = String(format: "%.2f", balanceUSD)
                        tempAdminName = adminName
                        tempTeamID = teamID
                        tempPrice3M = price3M
                        tempPrice5M = price5M
                        tempPrice12M = price12M
                        showSettingsModal = true
                    }) {
                        HStack(spacing: 14) {
                            ZStack {
                                if let profileImageData, let uiImage = UIImage(data: profileImageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 54, height: 54)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 54, height: 54)
                                    Image(systemName: "person.fill.badge.shield.checkmark")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }
                                
                                // Badge edit kecil di pojok foto
                                Circle()
                                    .fill(Color.black.opacity(0.6))
                                    .frame(width: 18, height: 18)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 9))
                                            .foregroundColor(.white)
                                    )
                                    .offset(x: 18, y: 18)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(adminName)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Team ID: \(teamID) 🟢")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Text(String(format: "Balance: $%.2f", balanceUSD))
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.gray)
                                .font(.title3)
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .buttonStyle(PlainButtonStyle())
                    
                    // Form Simulasi Order
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Apple Developer Order Panel")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Service Type / Plan")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(planFullNames[selectedPlanIndex])
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            Picker("Plan", selection: $selectedPlanIndex) {
                                ForEach(0..<planShortNames.count, id: \.self) { index in
                                    Text(planShortNames[index]).tag(index)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        // Harga Modal Otomatis
                        HStack(spacing: 15) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Purchase Price (USD)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                HStack(spacing: 6) {
                                    Text(String(format: "$%.2f", currentPlanPriceDouble))
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.green)
                                    Text("USD")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.tertiarySystemGroupedBackground))
                                .cornerRadius(8)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Estimated Delivery")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                HStack {
                                    Text("Instant delivery ⚡️")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .padding(.vertical, 9)
                                .padding(.horizontal, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.tertiarySystemGroupedBackground))
                                .cornerRadius(8)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Buyer Name / Nickname")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Input Buyer Name...", text: $buyerName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Device UDID")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Input UDID...", text: $buyerUDID)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.system(.subheadline, design: .monospaced))
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Certificate Password")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("ibaalcert", text: $certPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        Button(action: {
                            hideKeyboard()
                            startSimulatedOrder()
                        }) {
                            HStack {
                                Spacer()
                                if isProcessing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .padding(.trailing, 8)
                                    Text("Processing with Apple...")
                                        .font(.system(size: 15, weight: .bold))
                                } else {
                                    Image(systemName: "cloud.fill")
                                    Text("Submit Order to Server")
                                        .font(.system(size: 15, weight: .bold))
                                }
                                Spacer()
                            }
                            .padding(14)
                            .background(buyerUDID.count < 6 ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isProcessing || buyerUDID.count < 6)
                        .padding(.top, 4)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Live Terminal Logs & Cert Metadata
                    if isProcessing || isCompleted {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Live Server Terminal")
                                    .font(.headline)
                                Spacer()
                                Circle()
                                    .fill(isCompleted ? Color.green : Color.orange)
                                    .frame(width: 10, height: 10)
                                Text(isCompleted ? "Success" : "Running")
                                    .font(.caption)
                                    .foregroundColor(isCompleted ? .green : .orange)
                            }
                            
                            Divider()
                            
                            // Kotak Terminal Hitam
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(logMessages, id: \.self) { msg in
                                    Text(msg)
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundColor(msg.contains("✅") ? .green : (msg.contains("⚠️") ? .orange : .white))
                                }
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black)
                            .cornerRadius(8)
                            
                            // Cert Metadata Detail (Muncul Pas Sukses)
                            if isCompleted {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("📋 Cert Metadata Result")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.primary)
                                    
                                    Group {
                                        HStack {
                                            Text("Order ID:").foregroundColor(.secondary)
                                            Spacer()
                                            Text(lastOrderId).bold()
                                        }
                                        HStack {
                                            Text("Serial Number:").foregroundColor(.secondary)
                                            Spacer()
                                            Text(lastSerialNumber).font(.system(size: 11, design: .monospaced)).bold()
                                        }
                                        HStack {
                                            Text("Expires On:").foregroundColor(.secondary)
                                            Spacer()
                                            Text(lastExpiryDate).bold().foregroundColor(.blue)
                                        }
                                        HStack {
                                            Text("Balance Deducted:").foregroundColor(.secondary)
                                            Spacer()
                                            Text(String(format: "-$%.2f", currentPlanPriceDouble)).bold().foregroundColor(.red)
                                        }
                                    }
                                    .font(.caption)
                                    
                                    Button(action: {}) {
                                        HStack {
                                            Image(systemName: "arrow.down.doc.fill")
                                            Text("Download .p12 & .mobileprovision")
                                                .font(.system(size: 14, weight: .bold))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(10)
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                    }
                                    .padding(.top, 4)
                                }
                                .padding(12)
                                .background(Color(.tertiarySystemGroupedBackground))
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    
                    // Riwayat Order Terakhir
                    let historyList = loadHistory()
                    if !historyList.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Recent Issued Certificates")
                                    .font(.headline)
                                Spacer()
                                Button("Clear") {
                                    historyDataJSON = "[]"
                                }
                                .font(.caption)
                                .foregroundColor(.red)
                            }
                            
                            ForEach(historyList.prefix(5)) { item in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(item.buyerName.isEmpty ? "Unnamed Buyer" : item.buyerName)
                                            .font(.subheadline)
                                            .bold()
                                        Spacer()
                                        Text("$\(item.price)")
                                            .font(.caption)
                                            .bold()
                                            .foregroundColor(.green)
                                    }
                                    HStack {
                                        Text("UDID: \(item.udid.prefix(12))...")
                                            .font(.system(size: 10, design: .monospaced))
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text(item.planName)
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.15))
                                            .foregroundColor(.blue)
                                            .cornerRadius(4)
                                    }
                                    Text("Expired: \(item.expiryDate)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding(10)
                                .background(Color(.tertiarySystemGroupedBackground))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .onTapGesture {
                hideKeyboard()
            }
            .navigationBarTitle("Apple Reseller Console", displayMode: .inline)
            .sheet(isPresented: $showSettingsModal) {
                NavigationView {
                    Form {
                        Section(header: Text("Foto Profil Admin")) {
                            HStack {
                                Text("Ganti Foto")
                                Spacer()
                                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                    Text("Pilih dari Galeri")
                                        .font(.subheadline)
                                }
                            }
                        }
                        .onChange(of: selectedPhotoItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    profileImageData = data
                                }
                            }
                        }
                        
                        Section(header: Text("Profil & Saldo Admin")) {
                            HStack {
                                Text("Nama Panel")
                                Spacer()
                                TextField("Nama Admin", text: $tempAdminName)
                                    .multilineTextAlignment(.trailing)
                            }
                            HStack {
                                Text("Apple Team ID")
                                Spacer()
                                TextField("Team ID", text: $tempTeamID)
                                    .multilineTextAlignment(.trailing)
                                    .font(.system(.body, design: .monospaced))
                            }
                            HStack {
                                Text("Saldo ($ USD)")
                                Spacer()
                                TextField("900.00", text: $tempBalance)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        
                        Section(header: Text("Setting Harga Modal Plan (USD)")) {
                            HStack {
                                Text("Plan 3 Months ($)")
                                Spacer()
                                TextField("1.46", text: $tempPrice3M)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                            }
                            HStack {
                                Text("Plan 5 Months ($)")
                                Spacer()
                                TextField("2.20", text: $tempPrice5M)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                            }
                            HStack {
                                Text("Plan 12 Months ($)")
                                Spacer()
                                TextField("4.50", text: $tempPrice12M)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    }
                    .navigationBarTitle("Admin Settings", displayMode: .inline)
                    .navigationBarItems(
                        leading: Button("Batal") {
                            showSettingsModal = false
                        },
                        trailing: Button(action: {
                            if let newBal = Double(tempBalance) {
                                balanceUSD = newBal
                            }
                            adminName = tempAdminName
                            teamID = tempTeamID
                            price3M = tempPrice3M
                            price5M = tempPrice5M
                            price12M = tempPrice12M
                            showSettingsModal = false
                        }) {
                            Text("Simpan")
                                .font(.system(size: 16, weight: .bold))
                        }
                    )
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func startSimulatedOrder() {
        isProcessing = true
        isCompleted = false
        
        let timeNow = currentTimeString()
        logMessages = ["[\(timeNow)] Connecting to Apple Developer Portal API..."]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let t2 = currentTimeString()
            logMessages.append("[\(t2)] Validating UDID: \(buyerUDID.prefix(12))... OK")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                let t3 = currentTimeString()
                logMessages.append("[\(t3)] Generating CSR & signing via Team ID \(teamID)...")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                    let t4 = currentTimeString()
                    
                    // Potong Saldo Otomatis
                    let cost = currentPlanPriceDouble
                    if balanceUSD >= cost {
                        balanceUSD -= cost
                    } else {
                        balanceUSD = 0.0
                    }
                    
                    // Generate Metadata Hasil
                    lastOrderId = "#ORD-\(Int.random(in: 10000..~99999))"
                    lastSerialNumber = generateHexSerial()
                    lastExpiryDate = calculateExpiryDate(months: planMonthsCount[selectedPlanIndex])
                    
                    logMessages.append("[\(t4)] ✅ Success! Cert Bundle compiled.")
                    
                    // Simpan ke Riwayat
                    saveHistory(item: OrderHistoryItem(
                        id: UUID().uuidString,
                        dateStr: t4,
                        buyerName: buyerName,
                        udid: buyerUDID,
                        planName: planShortNames[selectedPlanIndex],
                        price: String(format: "%.2f", cost),
                        serialNumber: lastSerialNumber,
                        expiryDate: lastExpiryDate
                    ))
                    
                    isProcessing = false
                    isCompleted = true
                }
            }
        }
    }
    
    func currentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    func generateHexSerial() -> String {
        let letters = "0123456789ABCDEF"
        return (0..<16).map { _ in String(letters.randomElement()!) }.joined()
    }
    
    func calculateExpiryDate(months: Int) -> String {
        let calendar = Calendar.current
        if let targetDate = calendar.date(byAdding: .month, value: months, to: Date()) {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            return formatter.string(from: targetDate)
        }
        return "3 Months Later"
    }
    
    func saveHistory(item: OrderHistoryItem) {
        var currentList = loadHistory()
        currentList.insert(item, at: 0)
        if let encoded = try? JSONEncoder().encode(currentList) {
            historyDataJSON = String(data: encoded, encoding: .utf8) ?? "[]"
        }
    }
    
    func loadHistory() -> [OrderHistoryItem] {
        guard let data = historyDataJSON.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([OrderHistoryItem].self, from: data)) ?? []
    }
}
