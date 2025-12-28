@testable import AppDock
import XCTest

final class MenuStateTests: XCTestCase {
    private let menuPageKey = SettingsDefaults.menuPageKey

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: menuPageKey)
        super.tearDown()
    }

    func testMenuStateLoadsFromDefaults() {
        UserDefaults.standard.set(MenuPage.recents.rawValue, forKey: menuPageKey)
        let state = MenuState()
        XCTAssertEqual(state.menuPage, .recents)
    }

    func testMenuStatePersistsChanges() {
        let state = MenuState()
        state.menuPage = .favorites
        let stored = UserDefaults.standard.string(forKey: menuPageKey)
        XCTAssertEqual(stored, MenuPage.favorites.rawValue)
    }
}
