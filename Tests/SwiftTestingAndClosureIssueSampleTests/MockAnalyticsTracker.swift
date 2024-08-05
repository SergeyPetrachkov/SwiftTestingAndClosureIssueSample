import SwiftTestingAndClosureIssueSample

public final class MockAnalyticsTracker: AnalyticsTracker, @unchecked Sendable {

    public init() {}

    public let trackEventMock = MockFunc<String, Void>()
    public func track(event: String) {
        trackEventMock.callAndReturn(event)
    }

    public let trackErrorMock = MockFunc<any Error, Void>()
    public func track(error: any Error) {
        trackErrorMock.callAndReturn(error)
    }
}


public final class SimplifiedMockAnalyticsTracker: AnalyticsTracker, @unchecked Sendable {

    public init() {}

    var trackCallsCount: Int = 0
    var whenTrackCalled: (() -> Void)?
    public func track(event: String) {
        trackCallsCount += 1
        whenTrackCalled?()
    }


    public func track(error: any Error) {
        // just ignore for the sake of Demo
    }
}
