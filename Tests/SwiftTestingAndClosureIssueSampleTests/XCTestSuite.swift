import XCTest
@testable import SwiftTestingAndClosureIssueSample

final class SwiftTestingAndClosureIssueSampleTests: XCTestCase {

    struct Environment {
        let analyticsTracker = MockAnalyticsTracker()

        func makeSUT() -> MyViewModel {
            MyViewModel(analyticsTracker: analyticsTracker, viewState: .init(title: "", isBusy: false))
        }
    }

    @MainActor
    func testExample() async {
        let env = Environment()
        let sut = env.makeSUT()
        env.analyticsTracker.trackEventMock.returns()
        let expectation = expectation(description: "Async operation")
        env.analyticsTracker.trackEventMock.whenCalled { _ in
            expectation.fulfill()
        }
        sut.start()
        await fulfillment(of: [expectation])
        XCTAssertTrue(env.analyticsTracker.trackEventMock.calledOnce)
        XCTAssertEqual(sut.viewState.title, "Loaded!")
    }
}
