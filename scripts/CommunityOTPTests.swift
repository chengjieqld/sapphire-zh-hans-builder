import Foundation

@main
enum CommunityOTPTests {
    static func main() throws {
        let source = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        for message in ["Your verification code is 123456", "验证码：87654321", "Code 1234"] {
            precondition(VerificationCodeDetector.find(in: message) == nil,
                         "Community builds must not detect verification codes")
        }

        let manager = try String(contentsOf: source.appendingPathComponent("Sapphire/LiveActivities/LiveActivityManager.swift"), encoding: .utf8)
        precondition(manager.contains("guard CommunityOTPPolicy.isEnabled else { return nil }"),
                     "OTP live activity must be disabled even when old settings enable it")

        let notifications = try String(contentsOf: source.appendingPathComponent("Sapphire/Services/Miscellaneous/NotificationManager.swift"), encoding: .utf8)
        precondition(notifications.contains("if CommunityOTPPolicy.isEnabled && settings.onlyShowVerificationCodeNotifications"),
                     "Old OTP-only setting must not suppress ordinary notifications")

        let settings = try String(contentsOf: source.appendingPathComponent("Sapphire/App Settings/SettingsPanes.swift"), encoding: .utf8)
        precondition(settings.contains("if CommunityOTPPolicy.isEnabled {\n                    VStack(alignment: .leading, spacing: 0) {\n                        Text(\"Verification Codes\")"),
                     "Disabled verification-code controls must not appear in settings")
        print("PASS: community build disables verification-code detection and activity")
    }
}
