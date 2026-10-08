import SwiftUI

enum KaminTheme {
    static let black = Color(red: 0.11, green: 0.11, blue: 0.11)
    static let green = Color(red: 0.133, green: 0.231, blue: 0.157)
    static let yellow = Color(red: 1.0, green: 1.0, blue: 0.314)
    static let burgundy = Color(red: 0.45, green: 0.14, blue: 0.22)
    static let muted = Color(red: 0.72, green: 0.72, blue: 0.70)
    static let hairline = Color.white.opacity(0.14)
    static let surface = Color(red: 0.16, green: 0.16, blue: 0.155)

    static let displayTitle = Font.system(.largeTitle, design: .serif).weight(.regular)
    static let heroTitle = Font.system(size: 64, weight: .regular, design: .serif)
    static let sectionLabel = Font.system(size: 13, weight: .semibold, design: .default)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let meta = Font.system(size: 14, weight: .medium, design: .monospaced)
    static let pill = Font.system(size: 15, weight: .bold, design: .default)
}

struct GrainOverlay: View {
    var opacity: Double = 0.07

    var body: some View {
        Canvas { context, size in
            let cols = max(Int(size.width / 3), 1)
            let rows = max(Int(size.height / 3), 1)
            for row in 0..<rows {
                for col in 0..<cols {
                    let hash = (row * 73856093) ^ (col * 19349663)
                    if hash % 5 != 0 { continue }
                    let x = Double(col * 3) + Double(hash % 3)
                    let y = Double(row * 3) + Double((hash / 3) % 3)
                    let alpha = 0.18 + Double(abs(hash) % 40) / 100.0
                    let rect = CGRect(x: x, y: y, width: 1.1, height: 1.1)
                    context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(alpha)))
                }
            }
        }
        .opacity(opacity)
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

struct OrganicBlob: View {
    var color: Color
    var rotation: Double = 0

    var body: some View {
        OrganicBlobShape()
            .fill(color)
            .rotationEffect(.degrees(rotation))
    }
}

struct OrganicBlobShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: w * 0.18, y: h * 0.22))
        path.addCurve(
            to: CGPoint(x: w * 0.82, y: h * 0.12),
            control1: CGPoint(x: w * 0.35, y: h * -0.05),
            control2: CGPoint(x: w * 0.62, y: h * 0.02)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.95, y: h * 0.62),
            control1: CGPoint(x: w * 1.05, y: h * 0.25),
            control2: CGPoint(x: w * 1.02, y: h * 0.48)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.55, y: h * 0.95),
            control1: CGPoint(x: w * 0.88, y: h * 0.82),
            control2: CGPoint(x: w * 0.72, y: h * 1.02)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.08, y: h * 0.68),
            control1: CGPoint(x: w * 0.32, y: h * 0.88),
            control2: CGPoint(x: w * 0.12, y: h * 0.82)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.18, y: h * 0.22),
            control1: CGPoint(x: w * -0.02, y: h * 0.48),
            control2: CGPoint(x: w * 0.02, y: h * 0.32)
        )
        path.closeSubpath()
        return path
    }
}

struct HairlineDivider: View {
    var body: some View {
        Rectangle()
            .fill(KaminTheme.hairline)
            .frame(height: 1)
    }
}

struct KaminPillButton: View {
    let title: String
    var systemImage: String? = nil
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.body.weight(.bold))
                }
                Text(title.uppercased())
                    .font(KaminTheme.pill)
                    .tracking(0.8)
            }
            .foregroundStyle(enabled ? .black : .black.opacity(0.35))
            .padding(.horizontal, 22)
            .padding(.vertical, 14)
            .background(enabled ? KaminTheme.yellow : KaminTheme.yellow.opacity(0.35), in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

struct KaminOutlineButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(KaminTheme.pill)
                .tracking(0.8)
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .overlay(Capsule().stroke(Color.white.opacity(0.55), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct KaminCheckbox: View {
    let isDone: Bool
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .stroke(isDone ? accent : Color.white.opacity(0.35), lineWidth: 2)
                    .frame(width: 22, height: 22)
                if isDone {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(accent)
                        .frame(width: 22, height: 22)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.black)
                }
            }
            .scaleEffect(isDone ? 1.05 : 1)
            .animation(.spring(response: 0.32, dampingFraction: 0.55), value: isDone)
        }
        .buttonStyle(.plain)
    }
}

struct KaminSearchField: View {
    @Binding var text: String
    var prompt: String = "Search"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.body.weight(.medium))
                .foregroundStyle(KaminTheme.yellow.opacity(0.85))
            TextField(prompt, text: $text)
                .font(KaminTheme.body)
                .foregroundStyle(.white)
                .tint(KaminTheme.yellow)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(KaminTheme.muted)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(KaminTheme.surface)
        .overlay(Rectangle().stroke(KaminTheme.hairline, lineWidth: 1))
    }
}
