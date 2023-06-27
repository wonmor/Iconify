import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var isDropTargeted = false
    @State private var iconFileURL: URL?
    
    var body: some View {
        VStack {
            Text("Iconify")
                .font(.largeTitle)
                .padding(.top, 50)
            
            Spacer()
            
            if let iconFileURL = iconFileURL {
                Image(nsImage: NSImage(byReferencing: iconFileURL))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 100))
                    .padding()
            }
            
            Spacer()
            
            VStack {
                if iconFileURL != nil {
                    Text("Drop another file to replace")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                }
                
                Text("Drag and Drop your icon file here")
                    .font(.subheadline)
                    .foregroundColor(isDropTargeted ? .white : .gray)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 20)
                    .background(isDropTargeted ? Color.blue : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 2)
                            .foregroundColor(isDropTargeted ? .blue : .gray)
                    )
                    .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { items in
                        guard let item = items.first else { return false }
                        item.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (urlData, error) in
                            guard error == nil, let urlData = urlData as? Data, let url = URL(dataRepresentation: urlData, relativeTo: nil) else { return }
                            DispatchQueue.main.async {
                                self.iconFileURL = url
                                executeIconifyCommands(iconFileURL: url)
                            }
                        }
                        return true
                    }

            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func executeIconifyCommands(iconFileURL: URL) {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let iconsetDirectory = documentDirectory.appendingPathComponent("MyIcon.iconset")
        
        do {
            try fileManager.createDirectory(at: iconsetDirectory, withIntermediateDirectories: true, attributes: nil)
            
            let icon1024URL = iconFileURL
            let icon16URL = iconsetDirectory.appendingPathComponent("icon_16x16.png")
            let icon16x2URL = iconsetDirectory.appendingPathComponent("icon_16x16@2x.png")
            let icon32URL = iconsetDirectory.appendingPathComponent("icon_32x32.png")
            let icon32x2URL = iconsetDirectory.appendingPathComponent("icon_32x32@2x.png")
            let icon128URL = iconsetDirectory.appendingPathComponent("icon_128x128.png")
            let icon128x2URL = iconsetDirectory.appendingPathComponent("icon_128x128@2x.png")
            let icon256URL = iconsetDirectory.appendingPathComponent("icon_256x256.png")
            let icon256x2URL = iconsetDirectory.appendingPathComponent("icon_256x256@2x.png")
            let icon512URL = iconsetDirectory.appendingPathComponent("icon_512x512.png")
            let icon512x2URL = iconsetDirectory.appendingPathComponent("icon_512x512@2x.png")
            
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/sips")
            
            // sips commands
            task.arguments = ["-z", "16", "16", icon1024URL.path, "--out", icon16URL.path]
            try task.run()
            task.arguments = ["-z", "32", "32", icon1024URL.path, "--out", icon16x2URL.path]
            try task.run()
            task.arguments = ["-z", "32", "32", icon1024URL.path, "--out", icon32URL.path]
            try task.run()
            task.arguments = ["-z", "64", "64", icon1024URL.path, "--out", icon32x2URL.path]
            try task.run()
            task.arguments = ["-z", "128", "128", icon1024URL.path, "--out", icon128URL.path]
            try task.run()
            task.arguments = ["-z", "256", "256", icon1024URL.path, "--out", icon128x2URL.path]
            try task.run()
            task.arguments = ["-z", "256", "256", icon1024URL.path, "--out", icon256URL.path]
            try task.run()
            task.arguments = ["-z", "512", "512", icon1024URL.path, "--out", icon256x2URL.path]
            try task.run()
            task.arguments = ["-z", "512", "512", icon1024URL.path, "--out", icon512URL.path]
            try task.run()
            
            // cp command
            try fileManager.copyItem(at: icon1024URL, to: icon512x2URL)
            
            // iconutil command
            task.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
            task.arguments = ["-c", "icns", iconsetDirectory.path]
            try task.run()
            
            // Remove iconset directory
            try fileManager.removeItem(at: iconsetDirectory)
            
            print("Iconify commands executed successfully!")
        } catch {
            print("Error executing iconify commands: \(error.localizedDescription)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
