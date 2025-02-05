// 2021-04-27

final class Weak<Referencee: AnyObject> {
	weak var referencee: Referencee? = nil
	init(_ referencee: Referencee) { self.referencee = referencee }
}

extension String {
	static func randomLowercaseLetter() -> Self {
		let character = "abcdefghijklmnopqrstuvwxyz".randomElement()!
		return String(character)
	}
	
	// Don’t sort `String`s by `<`. That puts all capital letters before all lowercase letters, meaning “Z” comes before “a”.
	func precedesInFinder(_ other: Self) -> Bool {
		let comparisonResult = localizedStandardCompare(other) // The comparison method that the Finder uses
		switch comparisonResult {
			case .orderedAscending:
				return true
			case .orderedSame:
				return true
			case .orderedDescending:
				return false
		}
	}
}

extension Sequence {
	func compacted<WrappedType>() -> [WrappedType]
	where Element == Optional<WrappedType>
	{
		return compactMap { $0 }
	}
	
	func compactedAndFormattedAsNarrowList() -> String
	where Element == String?
	{
		return self
			.compacted()
			.formatted(.list(type: .and, width: .narrow))
	}
}

extension Array where Element == Int {
	// Whether the integers are increasing and contiguous.
	func isConsecutive() -> Bool {
		return allNeighborsSatisfy { $0 + 1 == $1 }
	}
}

extension Array {
	func inAnyOtherOrder() -> Self
	where Element: Equatable
	{
		guard count >= 2 else { return self }
		var result: Self
		repeat {
			result = shuffled()
		} while result == self
		return result
	}
	
	func differenceInferringMoves(
		toMatch newArray: [Element],
		by areEquivalent: (_ oldItem: Element, _ newItem: Element) -> Bool
	) -> CollectionDifference<Element>
	where Element: Hashable
	{
		return newArray.difference(from: self) { oldItem, newItem in
			areEquivalent(oldItem, newItem)
		}.inferringMoves()
	}
	
	func sortedMaintainingOrderWhen(
		shouldMaintainOrder: (Element, Element) -> Bool,
		areInOrder: (Element, Element) -> Bool
	) -> Self {
		let sortedTuples = enumerated().sorted {
			if shouldMaintainOrder($0.element, $1.element) {
				return $0.offset < $1.offset
			} else {
				return areInOrder($0.element, $1.element)
			}
		}
		return sortedTuples.map { $0.element }
	}
	
	func allNeighborsSatisfy(
		_ predicate: (_ eachElement: Element, _ nextElement: Element) -> Bool
	) -> Bool {
		let rest = dropFirst() // Empty subsequence if self is empty
		return allNeighborsSatisfy(first: first, rest: rest, predicate: predicate)
		
		func allNeighborsSatisfy(
			first: Element?,
			rest: ArraySlice<Element>,
			predicate: (_ eachElement: Element, _ nextElement: Element) -> Bool
		) -> Bool {
			guard let first = first, let second = rest.first else {
				// We’ve reached the end.
				return true
			}
			guard predicate(first, second) else {
				// Test case.
				return false // Short-circuit.
			}
			let newRest = rest.dropFirst()
			return allNeighborsSatisfy(first: second, rest: newRest, predicate: predicate)
		}
	}
}
