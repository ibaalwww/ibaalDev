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
    @AppStorage("mock_balance") private var balanceUSD: String = "450.50"
    @AppStorage("mock_admin_name") private var adminName: String = "iBaaL Enterprise Partner"
    
    @State private var selectedPlanIndex: Int = 0
    @State private var customPriceUSD: String = "1.46"
    @State private var buyerUDID: String = ""
    @State private var buyerName: String = ""
    @State private var certPassword: String = "ibaalcert"
    
    @State private var isProcessing: Bool = false
    @State private var statusMessage: String = "Ready to dispatch..."
    @State private var isCompleted: Bool = false
    
    @State private var showSettingsModal: Bool = false
    @State private var tempBalance: String = ""
    @State private var tempAdminName: String = ""

    let planNames = ["Plan 3 Months", "Plan 5 Months", "Plan 12 Months"]
    let planPrices = ["1.46", "2.20", "4.50"]

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                    .onTapGesture {
                        hideKeyboard()
                    }
                
                ScrollView {
                    VStack(spacing: 18) {
                        
                        // Header Saldo & Admin (Tap untuk edit saldo & nama)
                        Button(action: {
                            hideKeyboard()
                            tempBalance = balanceUSD
                            tempAdminName = adminName
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
                                        .frame(width: 50, height: 50)
                                    Image(systemName: "person.fill.badge.shield.checkmark")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(adminName)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("API Status: Connected (Apple API)")
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
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                        .buttonStyle(PlainButtonStyle())
                        
                        // Form Simulasi Order
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("Apple Developer Order Panel")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.primary)
                                Spacer()
                                Button(action: { hideKeyboard() }) {
                                    Image(systemName: "keyboard.chevron.compact.down")
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Service Type / Plan")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Picker("Plan", selection: $selectedPlanIndex) {
                                    ForEach(0..<planNames.count, id: \.self) { index in
                                        Text(planNames[index]).tag(index)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .onChange(of: selectedPlanIndex) { newIndex in
                                    customPriceUSD = planPrices[newIndex]
                                }
                            }
                            
                            HStack(spacing: 15) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Purchase Price (USD)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    HStack {
                                        Text("$").foregroundColor(.secondary)
                                        TextField("1.46", text: $customPriceUSD)
                                            .keyboardType(.decimalPad)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Estimated Delivery")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("Instant delivery ⚡️")
                                        .font(.system(size: 14, weight: .medium))
                                        .padding(.vertical, 8)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Buyer Name / Nickname")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Contoh: Rkii / Buyer Toko", text: $buyerName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Device UDID (40 Characters)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Masukkan 40 digit UDID...", text: $buyerUDID)
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
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
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
                                            Text("Cost: $\(customPriceUSD)")
                                                .font(.system(size: 12, weight: .bold))
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
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationBarTitle("Apple Reseller Console", displayMode: .inline)
            .sheet(isPresented: $showSettingsModal) {
                NavigationView {
                    Form {
                        Section(header: Text("Custom Panel Display (Untuk Screenshot)")) {
                            TextField("Saldo USD (Contoh: 450.50)", text: $tempBalance)
                                .keyboardType(.decimalPad)
                            TextField("Nama / Brand Admin", text: $tempAdminName)
                        }
                    }
                    .navigationBarTitle("Customize Mockup", displayMode: .inline)
                    .navigationBarItems(
                        leading: Button("Batal") {
                            showSettingsModal = false
                        },
                        trailing: Button(action: {
                            balanceUSD = tempBalance
                            adminName = tempAdminName
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
