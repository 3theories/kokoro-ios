//
//  Kokoro-tts-lib (Aria local patch)
//
//  Upstream `kokoro-ios` references `BenchmarkTimer` for in-engine
//  profiling but the symbol was never actually defined in either
//  the KokoroSwift sources or `MLXUtilsLibrary` (the main-branch
//  README mentions it, no Swift file ships it). Building against
//  upstream main therefore fails at link time.
//
//  Aria carries this minimal no-op shim locally so the engine
//  compiles. Profiling output is silently dropped; if we ever want
//  real timing data we can swap in a real implementation, but
//  voice mode doesn't need it.
//
//  Local-only patch.
//
import Foundation

enum BenchmarkTimer {
    static func reset() {}
    static func startTimer(_: String) {}
    static func stopTimer(_: String) {}
    static func getTimeInSec(_: String) -> Double? { nil }
}
