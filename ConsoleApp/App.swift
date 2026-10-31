import SwiftUI
import UIKit

@main
struct AppleResellerConsoleApp: App {
    var body: some Scene {
        WindowGroup {
            AppleMockupView()
        }
    }
}

struct AppleMockupView: View {
    @AppStorage("mock_balance") private var balanceUSD: String = "900.00"
    @AppStorage("mock_admin_name") private var adminName: String = "iBaaL Enterprise Partner"
    
    // Harga modal disimpan di settingan Admin
    @AppStorage("mock_price_3m") private var price3M: String = "1.46"
    @AppStorage("mock_price_5m") private var price5M: String = "2.20"
    @AppStorage("mock_price_12m") private var price12M: String = "4.50"
    
    @State private var selectedPlanIndex: Int = 0
    @State private var buyerUDID: String = ""
    @State private var buyerName: String = ""
    @State private var certPassword: String = "ibaalcert"
    
    @State private var isProcessing: Bool = false
    @State private var statusMessage: String = "Ready to dispatch..."
    @State private var isCompleted: Bool = false
    
    @State private var showSettingsModal: Bool = false
    @State private var tempBalance: String = ""
    @State private var tempAdminName: String = ""
    @State private var tempPrice3M: String = ""
    @State private var tempPrice5M: String = ""
    @State private var tempPrice12M: String = ""

    let planShortNames = ["3 Months", "5 Months", "12 Months"]
    let planFullNames = ["SALE Plan 3 Months", "SALE Plan 5 Months", "SALE Plan 12 Months"]

    var currentPlanPrice: String {
        switch selectedPlanIndex {
        case 0: return price3M
        case 1: return price5M
        default: return price12M
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 18) {
                    
                    // Header Saldo & Admin (Tap untuk buka settingan Admin)
                    Button(action: {
                        hideKeyboard()
                        tempBalance = balanceUSD
                        tempAdminName = adminName
                        tempPrice3M = price3M
                        tempPrice5M = price5M
                        tempPrice12M = price12M
                        showSettingsModal = true
                    }) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 52, height: 52)
                                Image(systemName: "person.fill.badge.shield.checkmark")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(adminName)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("API Status: 🟢 Connected (Apple API)")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Text("Balance: $\(balanceUSD)")
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
                        
                        // Harga Modal Otomatis (Diatur dari Settingan Admin)
                        HStack(spacing: 15) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Purchase Price (USD)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                HStack(spacing: 6) {
                                    Text("$\(currentPlanPrice)")
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
                            .background(buyerUDID.count < 10 ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isProcessing || buyerUDID.count < 10)
                        .padding(.top, 4)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Live Transaction Logs / Progress
                    if isProcessing || isCompleted {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Live Transaction Logs")
                                    .font(.headline)
                                Spacer()
                                Circle()
                                    .fill(isCompleted ? Color.green : Color.orange)
                                    .frame(width: 10, height: 10)
                                Text(isCompleted ? "Success" : "In Progress")
                                    .font(.caption)
                                    .foregroundColor(isCompleted ? .green : .orange)
                            }
                            
                            Divider()
                            
                            Text(statusMessage)
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundColor(.primary)
                            
                            if isCompleted {
                                VStack(spacing: 10) {
                                    HStack {
                                        Label("Warranty: 90 Days Active", systemImage: "checkmark.shield.fill")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                        Spacer()
                                        Text("Deducted: -$\(currentPlanPrice)")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.secondary)
                                    }
                                    
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
                                }
                                .padding(.top, 6)
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
                        Section(header: Text("Profil & Saldo Admin")) {
                            HStack {
                                Text("Nama Panel")
                                Spacer()
                                TextField("Nama Admin", text: $tempAdminName)
                                    .multilineTextAlignment(.trailing)
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
                            balanceUSD = tempBalance
                            adminName = tempAdminName
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
        statusMessage = "[0.2s] Connecting to Apple Provisioning Portal..."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            statusMessage = "[1.2s] Validating UDID: \(buyerUDID.prefix(10))..."
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                statusMessage = "[2.5s] Generating CSR & Signing with Enterprise Key..."
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                    let targetBuyer = buyerName.isEmpty ? "Customer" : buyerName
                    statusMessage = "[3.5s] ✅ Success! Certificate compiled & ready for \(targetBuyer)."
                    isProcessing = false
                    isCompleted = true
                }
            }
        }
    }
}
