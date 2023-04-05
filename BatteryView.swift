import SwiftUI

struct TopLeftTitle: View {
    var title: String

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .padding(.top, 5)
                    .padding(.leading, 5)
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct BatteryView: View {
    @State private var batteryLevel: Float = 0.0
    @State private var batteryState: WKInterfaceDeviceBatteryState = .unknown
    @State private var updateTimer: Timer? = nil
    
    private func updateBatteryInfo() {
        let device = WKInterfaceDevice.current()
        device.isBatteryMonitoringEnabled = true
        batteryLevel = device.batteryLevel
        batteryState = device.batteryState
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 25, height: 14)
                            .foregroundColor(.gray)
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: CGFloat(batteryLevel) * 23, height: 12)
                            .foregroundColor(batteryLevel <= 0.2 ? .red : .green)
                        if batteryState == .charging {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    Text("\(Int(batteryLevel * 100))%")
                }
            }
            TopLeftTitle(title: "Battery: \(Int(batteryLevel * 100))%")
        }
        .onAppear {
            updateBatteryInfo()
            
            // Update battery info every 5 minutes
            updateTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
                updateBatteryInfo()
            }
        }
        .onDisappear {
            // Invalidate the timer when the view disappears
            updateTimer?.invalidate()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(rawValue: "batteryLevelChanged"))) { _ in
            updateBatteryInfo()
        }
    }
}
