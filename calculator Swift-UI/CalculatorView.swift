import SwiftUI

struct CalculatorView: View {
    @State private var value: String = "0"
    var body: some View {
        VStack(alignment: .center, ) {
            Spacer()
            HStack {
                Spacer()
                Text(value)
                    .font(
                        .system(
                            size: value.count > 20 ? 50 : 70,
                            weight: .medium
                        )
                    )
                    .minimumScaleFactor(0.5)  // ensures text shrinks smoothly if needed
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal)
            }

            // Row 1
            HStack {
                CalculatorButton(title: "⏎") { change(title: "⏎") }
                CalculatorButton(title: "AC") { change(title: "AC") }
                CalculatorButton(title: "%") { change(title: "%") }
                CalculatorButton(title: "÷", backgroundColor: .orange) { change(title: "÷") }
            }

            // Row 2
            HStack {
                CalculatorButton(title: "7") { change(title: "7") }
                CalculatorButton(title: "8") { change(title: "8") }
                CalculatorButton(title: "9") { change(title: "9") }
                CalculatorButton(title: "x", backgroundColor: .orange) { change(title: "x") }
            }

            // Row 3
            HStack {
                CalculatorButton(title: "4") { change(title: "4") }
                CalculatorButton(title: "5") { change(title: "5") }
                CalculatorButton(title: "6") { change(title: "6") }
                CalculatorButton(title: "-", backgroundColor: .orange) { change(title: "-") }
            }

            // Row 4
            HStack {
                CalculatorButton(title: "1") { change(title: "1") }
                CalculatorButton(title: "2") { change(title: "2") }
                CalculatorButton(title: "3") { change(title: "3") }
                CalculatorButton(title: "+", backgroundColor: .orange) { change(title: "+") }
            }

            // Row 5
            HStack {
                CalculatorButton(title: "+/-") { change(title: "+/-") }
                CalculatorButton(title: "0") { change(title: "0") }
                CalculatorButton(title: ".") { change(title: ".") }
                CalculatorButton(title: "=", backgroundColor: .orange) { change(title: "=") }
            }
        }
    }

    func change(title: String) {
        let operators = ["+", "-", "x", "÷", "%"]

        // Clear all
        if title == "AC" {
            value = "0"
            return
        }

        // Backspace
        if title == "⏎" {
            value = String(value.dropLast())
            if value.isEmpty { value = "0" }
            return
        }

        // Operator replacement
        if let last = value.last,
           operators.contains(String(last)) && operators.contains(title) {
            value.removeLast()
            value += title
            return
        }

        // Sign toggle
        if title == "+/-" {
            value = value.hasPrefix("-") ? String(value.dropFirst()) : "-" + value
            return
        }

        // Equal
        if title == "=" {
            executeCalculation()
            return
        }

        // Prevent leading zero
        if value == "0" && !operators.contains(title) && title != "." {
            value = ""
        }

        // Numbers
        if ("0"..."9").contains(title) {
            value += title
            return
        }

        // Operators
        if operators.contains(title) {
            let lastChar = String(value.last ?? " ")
            if !operators.contains(lastChar) {
                value += title
            }
            return
        }

        // Decimal
        if title == "." {
            let lastChar = String(value.last ?? " ")
            if lastChar != "." {
                value += "."
            }
            return
        }
    }

    func executeCalculation() {
        var expression = value
            .replacingOccurrences(of: "x", with: "*")
            .replacingOccurrences(of: "÷", with: "/")

        // Handle modulus manually (e.g. 5%2)
        if expression.contains("%") {
            let parts = expression.split(separator: "%")
            if parts.count == 2,
               let lhs = Double(parts[0]),
               let rhs = Double(parts[1]) {
                value = String(lhs.truncatingRemainder(dividingBy: rhs))
                return
            }
        }

        // Handle percentage (like 50%)
        if expression.hasSuffix("%") {
            expression.removeLast()
            if let num = Double(expression) {
                value = String(num / 100)
                return
            }
        }

        // Default NSExpression evaluation
        let exp = NSExpression(format: expression)
        if let result = exp.expressionValue(with: nil, context: nil) as? Double {
            value = String(format: "%g", result)
        }
    }


    func isOperator(_ char: String) -> Bool {
        ["+", "-", "x", "÷", "%"].contains(char)
    }

}

#Preview {
    CalculatorView()
}

struct CalculatorButton: View {
    var title: String
    var backgroundColor: Color = Color(.darkGray)
    var foregroundColor: Color = .white
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 40, weight: .medium))
                .foregroundColor(foregroundColor)
                .frame(width: 90, height: 90)
                .background(backgroundColor)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
        }
    }
}
