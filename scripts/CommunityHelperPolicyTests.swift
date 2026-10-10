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
        print("PASS: community build skips privileged helper registration and alerts")
    }
}
