import ComposableArchitecture
import SwiftUI

public struct WriteMessageView: View {
    private let store: Store<WriteMessageState, WriteMessageAction>
    
    public init(store: Store<WriteMessageState, WriteMessageAction>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) {
            viewStore in
            
            VStack {
                HStack {
                    Text("Sent by:")
                        .foregroundColor(.secondary)
                    TextField("", text: viewStore.binding(\.$sentBy))
                }
                Divider()
                TextEditor(text: viewStore.binding(\.$message))
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { }) {
                        Image(systemName: "paperplane")
                    }
                    .disabled(viewStore.sendDisabled)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { viewStore.send(.cancel) }) {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}
