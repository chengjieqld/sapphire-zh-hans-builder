import Foundation

@main
struct FirebaseConfigurationPolicyTests {
    static func main() throws {
        guard CommandLine.arguments.count == 2 else {
            fatalError("Pass the public GoogleService-Info.plist path")
        }

        let publicStub = URL(fileURLWithPath: CommandLine.arguments[1])
        precondition(
            !FirebaseConfigurationPolicy.canConfigureFirebase(optionsAt: publicStub),
            "The public Firebase placeholder must not be configured"
        )

        let temporary = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".plist")
        defer { try? FileManager.default.removeItem(at: temporary) }

        let validOptions: [String: String] = [
            "API_KEY": "test-api-key",
            "GOOGLE_APP_ID": "1:123456789:ios:abcdef",
        ]
        let data = try PropertyListSerialization.data(
            fromPropertyList: validOptions,
            format: .xml,
            options: 0
        )
        try data.write(to: temporary)
        precondition(
            FirebaseConfigurationPolicy.canConfigureFirebase(optionsAt: temporary),
            "A non-placeholder Firebase configuration must remain usable"
        )

        precondition(
            !FirebaseConfigurationPolicy.canConfigureFirebase(optionsAt: nil),
            "A missing Firebase configuration must not be configured"
        )

        print("PASS: public Firebase placeholder is skipped; valid options remain usable")
    }
}
