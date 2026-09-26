import SwiftUI

struct ContentView: View {
    @AppStorage("dshURL") private var savedURL: String = ""
    @State private var input: String = ""
    @State private var target: URL? = nil

    var body: some View {
        Group {
            if let url = target {
                WebScreen(url: url, onChangeAddress: {
                    input = savedURL
                    target = nil
                })
            } else {
                connectScreen
            }
        }
        .onAppear {
            if input.isEmpty { input = savedURL }
            if target == nil && !savedURL.isEmpty { connect(savedURL) }
        }
    }

    private var connectScreen: some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: "bolt.horizontal.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text("连接 DSH").font(.title2).bold()
            Text("填电脑上 DSH 的地址（局域网、内网穿透或中转地址都行）")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            TextField("http://192.168.1.9:19387", text: $input)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.URL)
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 24)
            Button {
                connect(input)
            } label: {
                Text("连接").bold().frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 24)
            Spacer()
        }
    }

    private func connect(_ raw: String) {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return }
        if !s.contains("://") { s = "http://" + s }
        guard let u = URL(string: s), u.host != nil else { return }
        savedURL = s
        target = u
    }
}
