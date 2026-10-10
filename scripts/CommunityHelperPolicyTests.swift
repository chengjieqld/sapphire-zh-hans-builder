import Foundation

@main
enum CommunityHelperPolicyTests {
    static func main() throws {
        let source = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        precondition(!CommunityHelperPolicy.allowsPrivilegedHelper,
                     "Ad-hoc community builds must not register the privileged helper")

        let onboarding = try String(contentsOf: source.appendingPathComponent("Sapphire/App/OnboardingView.swift"), encoding: .utf8)
        precondition(onboarding.contains("CommunityHelperPolicy.allowsPrivilegedHelper ? .helperInstallation : .privacyPolicy"),
                     "Onboarding must bypass helper installation in community builds")
        precondition(onboarding.components(separatedBy: "CommunityHelperPolicy.allowsPrivilegedHelper ? .batterySetup : .corePreferences").count == 3,
                     "Onboarding must bypass nonfunctional battery setup for both music paths")

        let manager = try String(contentsOf: source.appendingPathComponent("Sapphire/App/HelperManager.swift"), encoding: .utf8)
        for method in ["beginInstallation", "installIfNeeded", "resetOwnBackgroundActivity", "reactivateHelper", "registerHelper"] {
            let pattern = #"(?s)func \#(method)\([^\n]*\)\s*(?:async\s*)?(?:->\s*Bool\s*)?\{\s*guard CommunityHelperPolicy\.allowsPrivilegedHelper else \{ return(?: false)? \}"#
            precondition(manager.range(of: pattern, options: .regularExpression) != nil,
                         "\(method) must decline helper registration in community builds")
        }

        let presenter = try String(contentsOf: source.appendingPathComponent("Sapphire/Utilities/UserWindowSupport.swift"), encoding: .utf8)
        precondition(presenter.contains("guard CommunityHelperPolicy.allowsPrivilegedHelper else { return }"),
                     "Helper alerts must be suppressed when helper installation is unavailable")
        let xpc = try String(contentsOf: source.appendingPathComponent("Sapphire/App/XPCClient.swift"), encoding: .utf8)
        precondition(xpc.contains("guard CommunityHelperPolicy.allowsPrivilegedHelper else { return nil }"),
                     "XPC proxy must reject calls to an old installed helper")
        precondition(xpc.contains("guard CommunityHelperPolicy.allowsPrivilegedHelper else { return }"),
                     "XPC start must not open a privileged connection")

        let battery = try String(contentsOf: source.appendingPathComponent("Sapphire/Services/Battery/BatteryManager.swift"), encoding: .utf8)
        precondition(battery.contains("func getHelper() -> HelperProtocol? {\n        guard CommunityHelperPolicy.allowsPrivilegedHelper else { return nil }"),
                     "Battery manager must never use a residual helper")

        let settings = try String(contentsOf: source.appendingPathComponent("Sapphire/App Settings/SettingsPanes.swift"), encoding: .utf8)
        precondition(settings.contains("if CommunityHelperPolicy.allowsPrivilegedHelper {\n                    coreFeaturesSection"),
                     "Battery settings must hide controls that require the helper")
        let detail = try String(contentsOf: source.appendingPathComponent("Sapphire/Widgets/Battery/BatteryDetailView.swift"), encoding: .utf8)
        precondition(detail.contains(".allowsHitTesting(CommunityHelperPolicy.allowsPrivilegedHelper)"),
                     "Battery detail charge-limit drag must be disabled")
        print("PASS: community build skips privileged helper registration and alerts")
    }
}
