# TaxMini 🇩🇪

**Privacy-First AI Sidecar for German Tax Returns**

TaxMini is a free, open-source desktop application that helps you prepare your German tax return (Einkommensteuererklärung) without ever uploading your documents to the cloud. Your data stays on YOUR computer.

![TaxMini Screenshot](./docs/screenshot.png)

## ✨ Features

- **100% Private**: All document processing happens locally on your machine
- **No API Keys Required**: Uses a "human-in-the-loop" workflow with Gemini
- **Guided Wizard**: Step-by-step questions to understand your tax situation
- **OCR Support**: Can read scanned documents using Tesseract.js
- **Smart Prompts**: Generates sophisticated prompts for accurate AI analysis
- **Visual Summary**: Beautiful visualization of your tax refund estimate

## 🎯 Who is this for?

- **Students** with part-time jobs or internships
- **Expats** who just moved to Germany and are confused by the tax system
- **Anyone** with a simple employment income (Anlage N)

*Note: Currently does NOT support self-employment income (Freiberufler/Gewerbetreibende)*

## 🚀 How It Works

1. **Answer Questions**: The wizard asks about your situation (employment, home office, deductions)
2. **Upload Documents**: Drag & drop your Lohnsteuerbescheinigung and receipts
3. **Copy Prompt**: TaxMini generates a detailed prompt with your extracted data
4. **Use Gemini**: Paste the prompt in [gemini.google.com](https://gemini.google.com) and get a JSON response
5. **See Results**: Paste the response back to see your estimated refund!

## 💡 Why "Human-in-the-Loop"?

Instead of requiring an API key (which costs money and raises privacy concerns), TaxMini lets you use your own Gemini account. This means:

- **Free**: Google offers Gemini free for students (and everyone)
- **Private**: The AI never sees your raw documents - only the text you choose to share
- **Transparent**: You see exactly what data is sent to the AI

## 📦 Installation

### Option 1: Download Release
Download the latest release for your platform:
- Windows: `TaxMini-Setup.exe`
- macOS: `TaxMini.dmg`

### Option 2: Build from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/taxmini.git
cd taxmini

# Install dependencies
npm install

# Run in development mode
npm run dev

# Build for production
npm run build:win   # Windows
npm run build:mac   # macOS
```

## 🛠 Development

### Prerequisites
- Node.js 18+
- npm or yarn

### Project Structure

```
taxmini/
├── src/
│   ├── main/               # Electron main process
│   │   ├── main.js         # Main process entry point
│   │   └── preload.js      # Preload script for IPC
│   └── renderer/           # React frontend
│       ├── components/     # React components
│       │   ├── Wizard.jsx        # Setup wizard
│       │   ├── Workspace.jsx     # Main workspace
│       │   ├── DropZone.jsx      # File upload
│       │   ├── PromptPanel.jsx   # Prompt copy/paste
│       │   └── ResultsPanel.jsx  # Tax summary
│       ├── utils/
│       │   └── promptBuilder.js  # Mega prompt generator
│       └── App.jsx         # Main React app
├── build/                  # App icons and resources
├── package.json            # Dependencies and build config
├── vite.config.js          # Vite configuration
└── tailwind.config.js      # Tailwind CSS configuration
```

### Key Technologies
- **Electron**: Cross-platform desktop framework
- **React**: UI library
- **Vite**: Fast build tool
- **Tailwind CSS**: Utility-first styling
- **pdf-parse**: PDF text extraction
- **Tesseract.js**: OCR for scanned documents
- **electron-builder**: App packaging

### Commands

```bash
npm run dev          # Start dev server + Electron
npm run build        # Build for current platform
npm run build:win    # Build Windows installer
npm run build:mac    # Build macOS DMG (Mac only)
```

### Building for macOS

macOS builds require a Mac. Windows cannot create .dmg files or code-sign for Apple.

**On a Mac:**
```bash
git clone https://github.com/yourusername/taxmini.git
cd taxmini
npm install
npm run build:mac
```

The .dmg will appear in the `release/` folder. Note: Without code signing, macOS will show a security warning. Users can right-click → Open to bypass.

## 📋 Required Documents

For a basic employee tax return, you typically need:

| Document | German Name | Required |
|----------|-------------|----------|
| Tax certificate from employer | Lohnsteuerbescheinigung | ✅ Yes |
| Tax ID | Steueridentifikationsnummer | ✅ Yes |
| Receipts for work expenses | Belege für Werbungskosten | Optional |
| Insurance certificates | Versicherungsnachweise | Optional |

## ⚠️ Disclaimer

**TaxMini is NOT a substitute for professional tax advice.**

This tool provides estimates only. For official tax filing:
- Use [ELSTER](https://www.elster.de) (official German tax portal)
- Consult a Steuerberater (tax advisor) for complex cases

The developers are not liable for any errors in tax calculations.

## 🤝 Contributing & Usage

**This is a vibe-coded project!** 🎸

Feel free to clone, fork, modify, and use this however you want. I built this for fun and to help people with their German taxes.

- **Tax law updates**: I update the official tax figures (Grundfreibetrag, Homeoffice-Pauschale, etc.) when the German government releases new statements
- **No guarantees**: Some buttons/features might be work-in-progress - this is a hobby project
- **PRs welcome**: If you fix something or add something cool, feel free to submit a PR, but no pressure

```bash
# Just clone it and go
git clone https://github.com/yourusername/taxmini.git
cd taxmini
npm install
npm run dev
```

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- Built with [Electron](https://www.electronjs.org/)
- UI powered by [React](https://react.dev/) + [Tailwind CSS](https://tailwindcss.com/)
- PDF parsing by [pdf-parse](https://www.npmjs.com/package/pdf-parse)
- OCR by [Tesseract.js](https://tesseract.projectnaptha.com/)

---

Made with ❤️ for the German tax season
