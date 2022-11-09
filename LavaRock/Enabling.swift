//
//  Enabling.swift
//  LavaRock
//
//  Created by h on 2021-10-29.
//

struct Enabling {
	private init() {}
	
	static let sim_emptyLibrary = 10 == 1
	
	static let inAppPlayer = 10 == 1
	static let swiftUI__console = inAppPlayer && 10 == 1
	
	static let swiftUI__options = 10 == 1
	
	static let multicollection = 10 == 1
	static let multialbum = multicollection && 10 == 10
}

#if targetEnvironment(simulator)
struct Global {
	static var songID: SongID? = nil
}
#endif
