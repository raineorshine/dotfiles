// Add or remove a macOS text replacement through keyboardservicesd, the same
// path System Settings > Keyboard > Text Replacements uses, so the change is
// stored, pushed to iCloud, and picked up by running apps immediately.
// Built on demand by the `textreplace` function in .zshrc.
//   ksreplace add FROM TO
//   ksreplace rm FROM TO
import Foundation

let args = CommandLine.arguments
guard args.count == 4, args[1] == "add" || args[1] == "rm" else {
  FileHandle.standardError.write("usage: ksreplace add|rm FROM TO\n".data(using: .utf8)!)
  exit(1)
}
guard Bundle(path: "/System/Library/PrivateFrameworks/KeyboardServices.framework")?.load() == true,
      let storeClass = NSClassFromString("_KSTextReplacementClientStore") as? NSObject.Type,
      let entryClass = NSClassFromString("_KSTextReplacementEntry") as? NSObject.Type else {
  FileHandle.standardError.write("ksreplace: could not load KeyboardServices.framework\n".data(using: .utf8)!)
  exit(2)
}

let store = storeClass.init()
let entry = entryClass.init()
entry.setValue(args[2], forKey: "shortcut")
entry.setValue(args[3], forKey: "phrase")
entry.setValue(Date(), forKey: "timestamp")
let add: NSArray = args[1] == "add" ? [entry] : []
let remove: NSArray = args[1] == "rm" ? [entry] : []

// -[_KSTextReplacementClientStore addEntries:removeEntries:withCompletionHandler:]
typealias Completion = @convention(block) (AnyObject?) -> Void
typealias AddRemove = @convention(c) (AnyObject, Selector, NSArray, NSArray, Completion) -> Void
let selector = NSSelectorFromString("addEntries:removeEntries:withCompletionHandler:")
let done = DispatchSemaphore(value: 0)
var result: AnyObject?
let completion: Completion = { result = $0; done.signal() }
unsafeBitCast(store.method(for: selector), to: AddRemove.self)(store, selector, add, remove, completion)

if done.wait(timeout: .now() + 15) == .timedOut {
  FileHandle.standardError.write("ksreplace: keyboardservicesd did not reply\n".data(using: .utf8)!)
  exit(3)
}
// The daemon replies with an NSError whose code is 0 on success.
if let error = result as? NSError, error.code != 0 {
  FileHandle.standardError.write("ksreplace: \(error.localizedDescription)\n".data(using: .utf8)!)
  exit(1)
}
