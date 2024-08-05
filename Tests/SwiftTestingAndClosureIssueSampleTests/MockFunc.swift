import Foundation

public final class MockFunc<Input, Output> {

	// MARK: - Properties
	private var didCall: (Input) -> Void = { _ in }
	public private(set) var invocations: [Input] = []
	public private(set) var result: (Input) -> Output
	public var output: Output {
		result(input)
	}

    var count: Int {
        invocations.count
    }

    var called: Bool {
        !invocations.isEmpty
    }
    var calledOnce: Bool {
        count == 1
    }
    var input: Input {
        invocations[count - 1]
    }

	public init(function: StaticString = #function, line: Int = #line) {
		result = { _ in fatalError("You must provide a result handler before using MockFunc instantiated at line: \(line) of \(function)") }
	}

    public func returns() where Output == Void {
        result = { _ in () }
    }

	public func callAndReturn(_ input: Input) -> Output {
		call(with: input)
		return output
	}

    public func whenCalled(closure: @escaping (Input) -> Void) {
		didCall = closure
	}

	private func call(with input: Input) {
		invocations.append(input)
		didCall(input)
	}
}
