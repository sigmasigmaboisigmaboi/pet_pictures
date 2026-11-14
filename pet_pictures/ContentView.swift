import SwiftUI
import PhotosUI

// 1. Datenmodell für die festen Kategorien
struct BackgroundPreset: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let emoji: String
    let color: Color
    let prompt: String
}

// 2. Die 5 fertigen Vorschläge
let defaultPresets: [BackgroundPreset] = [
    BackgroundPreset(title: "Strand", emoji: "🏖️", color: .cyan, prompt: "relaxing on a sunny tropical beach, palm trees"),
    BackgroundPreset(title: "Berge", emoji: "🏔️", color: .green, prompt: "standing on a scenic alpine mountain peak, sunlight"),
    BackgroundPreset(title: "Weltall", emoji: "🚀", color: .indigo, prompt: "cute astronaut in outer space, Earth in background"),
    BackgroundPreset(title: "Königlich", emoji: "👑", color: .orange, prompt: "sitting on a royal velvet throne, tiny golden crown"),
    BackgroundPreset(title: "New York", emoji: "🗽", color: .blue, prompt: "posing as a tourist in New York City, yellow cabs")
]

struct ContentView: View {
    // Zustände für Haustier-Foto
    @State private var petPhotoItem: PhotosPickerItem?
    @State private var petImage: Image?
    
    // Zustände für Hintergrund (entweder Preset ODER eigenes Foto)
    @State private var selectedPreset: BackgroundPreset? = defaultPresets.first
    @State private var bgPhotoItem: PhotosPickerItem?
    @State private var bgImage: Image?
    
    // Zustände für Verarbeitung & Ergebnis
    @State private var isProcessing = false
    @State private var resultImage: Image?
    @State private var resultSummary: String = ""
    
    // Prüft, ob alles bereit für den Zauber-Button ist
    private var isReadyToGenerate: Bool {
        petImage != nil && (selectedPreset != nil || bgImage != nil)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    
                    Text("Erstelle dein Haustier-Fotoalbum")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    
                    // Schritt 1: Haustier-Foto
                    VStack(alignment: .leading, spacing: 10) {
                        Text("1. Foto von deinem Haustier")
                            .font(.headline)
                        
                        PhotosPicker(selection: $petPhotoItem, matching: .images) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.orange.opacity(0.15))
                                    .frame(height: 140)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.orange, style: StrokeStyle(lineWidth: 2, dash: [6]))
                                    )
                                
                                if let petImage {
                                    petImage
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 140)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                } else {
                                    VStack(spacing: 8) {
                                        Image(systemName: "pawprint.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(.orange)
                                        Text("Haustier-Foto auswählen")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.orange)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Schritt 2: Feste Kategorien ODER eigenes Hintergrund-Foto
                    BackgroundSelectionSection(
                        selectedPreset: $selectedPreset,
                        bgPhotoItem: $bgPhotoItem,
                        bgImage: $bgImage
                    )
                    
                    // Schritt 3: Zauber-Button
                    Button(action: startMagic) {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .tint(.white)
                                    .padding(.trailing, 5)
                            } else {
                                Image(systemName: "wand.and.stars")
                            }
                            Text(isProcessing ? "KI zaubert..." : "Foto jetzt zaubern!")
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isReadyToGenerate ? Color.purple : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                    .disabled(!isReadyToGenerate || isProcessing)
                    
                    // Ergebnis-Anzeige (Platzhalter für KI-Ergebnis)
                    if let resultImage {
                        VStack(spacing: 12) {
                            Text("Dein Zauber-Ergebnis:")
                                .font(.headline)
                            
                            ZStack(alignment: .bottom) {
                                resultImage
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(16)
                                    .shadow(radius: 5)
                                
                                // Vorschau-Badge für den aktuellen Prototyp
                                Text(resultSummary)
                                    .font(.caption.bold())
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(10)
                                    .padding(10)
                            }
                            
                            // Wiederkehr-Button für schnelles Weiterprobieren
                            Button(action: tryAnotherScene) {
                                Label("Nochmal mit anderem Ort", systemImage: "arrow.triangle.2.circlepath")
                                    .font(.subheadline.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.purple.opacity(0.12))
                                    .foregroundColor(.purple)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.top)
                    }
                }
                .padding()
            }
            .navigationTitle("Haustier Zauber")
        }
        // Foto-Ladelogik Haustier
        .onChange(of: petPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImg = UIImage(data: data) {
                    petImage = Image(uiImage: uiImg)
                }
            }
        }
        // Foto-Ladelogik eigener Hintergrund
        .onChange(of: bgPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImg = UIImage(data: data) {
                    bgImage = Image(uiImage: uiImg)
                    selectedPreset = nil // Preset abwählen, da eigenes Foto gewählt wurde
                }
            }
        }
    }
    
    // Simulierter KI-Aufruf
    private func startMagic() {
        isProcessing = true
        let chosenScene = selectedPreset != nil
            ? "\(selectedPreset!.emoji) \(selectedPreset!.title)"
            : "🖼️ Eigenes Hintergrundfoto"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isProcessing = false
            resultImage = petImage
            resultSummary = "Vorschau: Haustier + \(chosenScene)"
        }
    }
    
    // Wählt direkt eine neue Zufallskategorie für den nächsten Versuch
    private func tryAnotherScene() {
        let otherPresets = defaultPresets.filter { $0 != selectedPreset }
        if let random = otherPresets.randomElement() {
            withAnimation(.spring()) {
                selectedPreset = random
                bgImage = nil
                bgPhotoItem = nil
                resultImage = nil
            }
        }
    }
}

// 3. UI-Ansicht für die Auswahl (Kategorien + eigener PhotosPicker)
struct BackgroundSelectionSection: View {
    @Binding var selectedPreset: BackgroundPreset?
    @Binding var bgPhotoItem: PhotosPickerItem?
    @Binding var bgImage: Image?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("2. Wohin geht die Reise?")
                    .font(.headline)
                
                Spacer()
                
                // Überraschungs-Button für schnellen Spieltrieb
                Button(action: pickRandomPreset) {
                    Label("Zufall", systemImage: "dice.fill")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.purple.opacity(0.15))
                        .foregroundColor(.purple)
                        .cornerRadius(12)
                }
            }
            
            // Horizontal scrollbare Ideen-Karten
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(defaultPresets) { preset in
                        let isSelected = selectedPreset == preset
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedPreset = preset
                                bgImage = nil
                                bgPhotoItem = nil
                            }
                        }) {
                            VStack(spacing: 8) {
                                Text(preset.emoji)
                                    .font(.system(size: 36))
                                
                                Text(preset.title)
                                    .font(.subheadline.bold())
                                    .foregroundColor(isSelected ? .white : .primary)
                            }
                            .frame(width: 95, height: 105)
                            .background(isSelected ? preset.color : preset.color.opacity(0.12))
                            .cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(isSelected ? preset.color : Color.clear, lineWidth: 3)
                            )
                            .scaleEffect(isSelected ? 1.04 : 1.0)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
            
            // Dezente Trennlinie zur eigenen Foto-Option
            HStack {
                Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.2))
                Text("ODER EIGENES FOTO").font(.caption).foregroundColor(.secondary)
                Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.2))
            }
            .padding(.vertical, 2)
            
            // Bestehender PhotosPicker für eigenes Hintergrundbild
            PhotosPicker(selection: $bgPhotoItem, matching: .images) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.blue.opacity(0.12))
                        .frame(height: bgImage != nil ? 140 : 65)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [6]))
                        )
                    
                    if let bgImage {
                        bgImage
                            .resizable()
                            .scaledToFill()
                            .frame(height: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        HStack(spacing: 10) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text("Eigenes Hintergrund-Foto wählen")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }
    
    private func pickRandomPreset() {
        let otherPresets = defaultPresets.filter { $0 != selectedPreset }
        if let random = otherPresets.randomElement() {
            withAnimation(.spring()) {
                selectedPreset = random
                bgImage = nil
                bgPhotoItem = nil
            }
        }
    }
}

#Preview {
    ContentView()
}
