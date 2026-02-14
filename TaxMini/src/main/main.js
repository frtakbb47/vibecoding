const { app, BrowserWindow, ipcMain, dialog } = require('electron');
const path = require('path');
const fs = require('fs');
const pdfParse = require('pdf-parse');

// Tesseract for OCR (scanned PDFs)
let Tesseract;
try {
    Tesseract = require('tesseract.js');
} catch (e) {
    console.log('Tesseract.js not available, OCR disabled');
}

let mainWindow;

const isDev = process.env.NODE_ENV !== 'production' || !app.isPackaged;

// ============================================
// SINGLE INSTANCE LOCK - Prevent multiple windows
// ============================================
const gotTheLock = app.requestSingleInstanceLock();

if (!gotTheLock) {
    // Another instance is already running, quit this one
    app.quit();
} else {
    // Someone tried to run a second instance, focus our window instead
    app.on('second-instance', () => {
        if (mainWindow) {
            if (mainWindow.isMinimized()) mainWindow.restore();
            mainWindow.focus();
        }
    });

    function createWindow() {
        // Prevent creating multiple windows
        if (mainWindow && !mainWindow.isDestroyed()) {
            mainWindow.focus();
            return;
        }

        mainWindow = new BrowserWindow({
            width: 1400,
            height: 900,
            minWidth: 1200,
            minHeight: 700,
            backgroundColor: '#09090b',
            titleBarStyle: process.platform === 'darwin' ? 'hiddenInset' : 'default',
            frame: false, // Frameless for custom title bar
            webPreferences: {
                nodeIntegration: false,
                contextIsolation: true,
                preload: path.join(__dirname, 'preload.js'),
            },
        });

        // Clean up reference when window is closed
        mainWindow.on('closed', () => {
            mainWindow = null;
        });

        if (isDev) {
            mainWindow.loadURL('http://localhost:5173');
            mainWindow.webContents.openDevTools();
        } else {
            mainWindow.loadFile(path.join(__dirname, '../../dist/index.html'));
        }
    }

    app.whenReady().then(createWindow);

    app.on('window-all-closed', () => {
        if (process.platform !== 'darwin') {
            app.quit();
        }
    });

    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) {
            createWindow();
        }
    });
}

// ============================================
// IPC HANDLERS - Window Controls
// ============================================

ipcMain.handle('window:minimize', () => {
    mainWindow?.minimize();
});

ipcMain.handle('window:maximize', () => {
    if (mainWindow?.isMaximized()) {
        mainWindow.unmaximize();
    } else {
        mainWindow?.maximize();
    }
});

ipcMain.handle('window:close', () => {
    mainWindow?.close();
});

// ============================================
// IPC HANDLERS - PDF Processing
// ============================================

// Open file dialog
ipcMain.handle('dialog:openFiles', async () => {
    const result = await dialog.showOpenDialog(mainWindow, {
        properties: ['openFile', 'multiSelections'],
        filters: [
            { name: 'PDF Documents', extensions: ['pdf'] },
            { name: 'Images', extensions: ['png', 'jpg', 'jpeg'] },
        ],
    });
    return result.filePaths;
});

// Parse PDF and extract text
ipcMain.handle('pdf:parse', async (event, filePath) => {
    try {
        const dataBuffer = fs.readFileSync(filePath);
        const data = await pdfParse(dataBuffer);

        // Check if we got meaningful text
        const text = data.text.trim();

        if (text.length < 50) {
            // Likely a scanned PDF, try OCR
            return {
                success: true,
                text: text,
                isScanned: true,
                needsOCR: true,
                pages: data.numpages,
                fileName: path.basename(filePath),
            };
        }

        return {
            success: true,
            text: text,
            isScanned: false,
            needsOCR: false,
            pages: data.numpages,
            fileName: path.basename(filePath),
        };
    } catch (error) {
        return {
            success: false,
            error: error.message,
            fileName: path.basename(filePath),
        };
    }
});

// OCR for scanned documents
ipcMain.handle('ocr:process', async (event, filePath) => {
    if (!Tesseract) {
        return {
            success: false,
            error: 'OCR not available. Please install tesseract.js',
        };
    }

    try {
        // Send progress updates
        const worker = await Tesseract.createWorker('deu+eng', 1, {
            logger: (m) => {
                if (m.status === 'recognizing text') {
                    event.sender.send('ocr:progress', {
                        progress: m.progress,
                        status: 'Processing...',
                    });
                }
            },
        });

        const { data: { text } } = await worker.recognize(filePath);
        await worker.terminate();

        return {
            success: true,
            text: text.trim(),
            fileName: path.basename(filePath),
        };
    } catch (error) {
        return {
            success: false,
            error: error.message,
            fileName: path.basename(filePath),
        };
    }
});

// Save session data locally
ipcMain.handle('storage:save', async (event, key, data) => {
    try {
        const userDataPath = app.getPath('userData');
        const filePath = path.join(userDataPath, `${key}.json`);
        fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
        return { success: true };
    } catch (error) {
        return { success: false, error: error.message };
    }
});

// Load session data
ipcMain.handle('storage:load', async (event, key) => {
    try {
        const userDataPath = app.getPath('userData');
        const filePath = path.join(userDataPath, `${key}.json`);
        if (fs.existsSync(filePath)) {
            const data = JSON.parse(fs.readFileSync(filePath, 'utf-8'));
            return { success: true, data };
        }
        return { success: true, data: null };
    } catch (error) {
        return { success: false, error: error.message };
    }
});

// Get app version
ipcMain.handle('app:version', () => {
    return app.getVersion();
});
