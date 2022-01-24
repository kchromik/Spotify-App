import SwiftUI

extension View {
    func `if`(_ condition: Bool, apply: (AnyView) -> (AnyView)) -> AnyView {
        if condition {
            return apply(AnyView(self))
        } else {
            return AnyView(self)
        }
    }
}
