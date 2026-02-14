const { contextBridge, ipcRenderer } = require('electron');

// Expose protected methods to the renderer process
contextBridge.exposeInMainWorld('electronAPI', {
    // File dialogs
    openFiles: () => ipcRenderer.invoke('dialog:openFiles'),

    // PDF processing
    parsePDF: (filePath) => ipcRenderer.invoke('pdf:parse', filePath),

    // OCR processing
    processOCR: (filePath) => ipcRenderer.invoke('ocr:process', filePath),
    onOCRProgress: (callback) => {
        ipcRenderer.on('ocr:progress', (event, data) => callback(data));
    },

    // Local storage
    saveData: (key, data) => ipcRenderer.invoke('storage:save', key, data),
    loadData: (key) => ipcRenderer.invoke('storage:load', key),

    // App info
    getVersion: () => ipcRenderer.invoke('app:version'),

    // Window controls
    minimizeWindow: () => ipcRenderer.invoke('window:minimize'),
    maximizeWindow: () => ipcRenderer.invoke('window:maximize'),
    closeWindow: () => ipcRenderer.invoke('window:close'),

    // Platform info
    platform: process.platform,
});
