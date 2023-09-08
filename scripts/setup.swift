import Foundation

@discardableResult 
func shell(_ command: String) -> Int32 {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = ["bash", "-c", command]
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

print("Running script from: \(FileManager.default.currentDirectoryPath)")

shell("brew install fastlane")
shell("brew install sonar-scanner")

print("Done with setup!")
print("See the README file for more information")
