import SwiftUI
import Combine

// MARK: - Text Field Auto-Select Modifier
struct AutoSelectTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                if let textField = obj.object as? UITextField {
                    textField.selectAll(nil)
                }
            }
    }
}

// MARK: - Dismiss Keyboard on Tap Modifier
struct DismissKeyboardOnTapModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}

// MARK: - View Extensions
extension View {
    /// Auto-selects all text when a text field becomes first responder
    func autoSelectText() -> some View {
        modifier(AutoSelectTextFieldModifier())
    }
    
    /// Dismisses the keyboard when tapping outside of text fields
    func dismissKeyboardOnTap() -> some View {
        modifier(DismissKeyboardOnTapModifier())
    }
}

// MARK: - Number Input Field Component
struct NumberInputField: View {
    let label: String
    @Binding var value: Double
    let format: FloatingPointFormatStyle<Double>
    let keyboardType: UIKeyboardType
    let width: CGFloat
    let placeholder: String
    
    init(
        label: String,
        value: Binding<Double>,
        format: FloatingPointFormatStyle<Double> = .number,
        keyboardType: UIKeyboardType = .decimalPad,
        width: CGFloat = 80,
        placeholder: String = "0"
    ) {
        self.label = label
        self._value = value
        self.format = format
        self.keyboardType = keyboardType
        self.width = width
        self.placeholder = placeholder
    }
    
    var body: some View {
        TextField(placeholder, value: $value, format: format)
            .keyboardType(keyboardType)
            .multilineTextAlignment(.trailing)
            .frame(width: width)
            .autoSelectText()
    }
}

struct IntegerInputField: View {
    let label: String
    @Binding var value: Int
    let format: IntegerFormatStyle<Int>
    let keyboardType: UIKeyboardType
    let width: CGFloat
    let placeholder: String
    
    init(
        label: String,
        value: Binding<Int>,
        format: IntegerFormatStyle<Int> = .number,
        keyboardType: UIKeyboardType = .numberPad,
        width: CGFloat = 60,
        placeholder: String = "0"
    ) {
        self.label = label
        self._value = value
        self.format = format
        self.keyboardType = keyboardType
        self.width = width
        self.placeholder = placeholder
    }
    
    var body: some View {
        TextField(placeholder, value: $value, format: format)
            .keyboardType(keyboardType)
            .multilineTextAlignment(.trailing)
            .frame(width: width)
            .autoSelectText()
    }
}