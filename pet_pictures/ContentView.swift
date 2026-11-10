import SwiftUI
import PhotosUI

struct ContentView: View {
    // Zustände für die ausgewählten Fotos
    @State private var petPhotoItem: PhotosPickerItem?
    @State private var petImage: Image?
    
    @State private var bgPhotoItem: PhotosPickerItem?
    @State private var bgImage: Image?
    
    @State private var isProcessing = false
    @State private var resultImage: Image?
    
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
                    
                    // Schritt 2: Hintergrund- / Familienfoto
                    VStack(alignment: .leading, spacing: 10) {
                        Text("2. Wunsch-Hintergrund (z. B. Strand)")
                            .font(.headline)
                        
                        PhotosPicker(selection: $bgPhotoItem, matching: .images) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.blue.opacity(0.15))
                                    .frame(height: 140)
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
                                    VStack(spacing: 8) {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.largeTitle)
                                            .foregroundColor(.blue)
                                        Text("Hintergrund-Foto auswählen")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                    
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
                        .background(petImage != nil && bgImage != nil ? Color.purple : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                    .disabled(petImage == nil || bgImage == nil || isProcessing)
                    
                    // Ergebnis-Anzeige (Platzhalter für KI-Ergebnis)
                    if let resultImage {
                        VStack(spacing: 12) {
                            Text("Dein Zauber-Ergebnis:")
                                .font(.headline)
                            
                            resultImage
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(16)
                                .shadow(radius: 5)
                        }
                        .padding(.top)
                    }
                }
                .padding()
            }
            .navigationTitle("Haustier Zauber")
        }
        // Foto-Ladelogik
        .onChange(of: petPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImg = UIImage(data: data) {
                    petImage = Image(uiImage: uiImg)
                }
            }
        }
        .onChange(of: bgPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImg = UIImage(data: data) {
                    bgImage = Image(uiImage: uiImg)
                }
            }
        }
    }
    
    // Simulierter KI-Aufruf
    private func startMagic() {
        isProcessing = true
        // Hier binden wir später die echte KI-API an!
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            isProcessing = false
            // Vorübergehendes Ergebnis zur Demonstration
            resultImage = petImage
        }
    }
}

#Preview {
    ContentView()
}
