import Foundation

public protocol AnalyticsTracker: Sendable {
    func track(event: String)
    func track(error: Error)
}

@Observable
public final class MyViewModel {

    public struct ViewState {
        public var title: String
        public var isBusy: Bool

        public init(title: String, isBusy: Bool) {
            self.title = title
            self.isBusy = isBusy
        }
    }

    @ObservationIgnored
    let analyticsTracker: any AnalyticsTracker

    var viewState: ViewState

    public init(analyticsTracker: any AnalyticsTracker, viewState: ViewState) {
        self.analyticsTracker = analyticsTracker
        self.viewState = viewState
    }

    @MainActor
    func start() {
        Task {
            viewState.isBusy = true
            await someLongOperation()
            viewState.title = "Loaded!"
            viewState.isBusy = false
            analyticsTracker.track(event: "MyViewModelStarted")
        }
    }

    private func someLongOperation() async {
        try? await Task.sleep(for: .seconds(1))
    }
}
