import Testing
@testable import SwiftTestingAndClosureIssueSample

@Suite
struct SwiftyTests {

    struct Environment {
        let analyticsTracker = MockAnalyticsTracker()

        func makeSUT() -> MyViewModel {
            MyViewModel(analyticsTracker: analyticsTracker, viewState: .init(title: "", isBusy: false))
        }
    }

    @Test("The issue")
    func testExample() async {
        await withKnownIssue {
            let env = Environment()
            let sut = env.makeSUT()
            env.analyticsTracker.trackEventMock.returns()

            await confirmation { @MainActor confirmed in
                env.analyticsTracker.trackEventMock.whenCalled { _ in
                    confirmed() // if I put a breakpoint here, it gets into it, but doesn't increment the counter
                }
                sut.start()
            }

            #expect(env.analyticsTracker.trackEventMock.calledOnce)
            // Can't uncomment the line below,
            // because then I get "Sending 'sut' risks causing data races" on line 25 `sut.start()`
            //        #expect(sut.viewState.title == "Loaded!")
        }
    }

    @Test("Simpler mocks are used here")
    func testSimplifiedMockExample() async {
        await withKnownIssue {
            let analyticsTracker = SimplifiedMockAnalyticsTracker()
            let sut =  MyViewModel(analyticsTracker: analyticsTracker, viewState: .init(title: "", isBusy: false))

            await confirmation { @MainActor confirmed in
                analyticsTracker.whenTrackCalled = {
                    confirmed() // if I put a breakpoint here, it gets into it, but doesn't increment the counter
                }
                sut.start()
            }

            #expect(analyticsTracker.trackCallsCount == 1)
        }
    }

    @Test
    func start_shouldCallAnalyticsOnce() async {
        let env = Environment()
        let sut = env.makeSUT()
        env.analyticsTracker.trackEventMock.returns()

        await expectation(
            fulfilmentCallback: env.analyticsTracker.trackEventMock.whenCalled,
            sutCall: sut.start
        )

        #expect(env.analyticsTracker.trackEventMock.calledOnce)
        #expect(sut.viewState.title == "Loaded!")
    }

    @Test
    func sendStart_shouldCallAnalyticsOnce() async {
        let env = Environment()
        let sut = env.makeSUT()
        env.analyticsTracker.trackEventMock.returns()

        await expectation(
            fulfilmentCallback: env.analyticsTracker.trackEventMock.whenCalled,
            sutCall: sut.send,
            sutInput: .start
        )

        #expect(env.analyticsTracker.trackEventMock.calledOnce)
        #expect(sut.viewState.title == "Loaded!")
    }
}

func expectation<Condition, SutInput: Sendable>(
    fulfilmentCallback: (@escaping (Condition) -> Void) -> Void,
    sutCall: @escaping @isolated(any) (SutInput) -> Void,
    sutInput: SutInput
) async {
    let stream = AsyncStream { continuation in
        fulfilmentCallback { _ in
            continuation.yield()
        }
    }
    await sutCall(sutInput)
    var iterator = stream.makeAsyncIterator()
    await iterator.next()
}

func expectation<Condition>(
    fulfilmentCallback: (@escaping (Condition) -> Void) -> Void,
    sutCall: @escaping @isolated(any) () -> Void
) async {
    let stream = AsyncStream { continuation in
        fulfilmentCallback { _ in
            continuation.yield()
        }
    }
    await sutCall()
    var iterator = stream.makeAsyncIterator()
    await iterator.next()
}

