# Floor daemon
**Floord** is a lightweight background daemon written in Rust that automatically manages and organizes incoming files.

## File Organization

**Floord** automatically organizes incoming files based on their file extensions, sorting them into the appropriate system directories according to their file type.

It uses the operating system's standard directories whenever available:

- **Documents**: .pdf, .docx, .txt, .odt, etc.
- **Music**: .mp3, .wav, .flac, .ogg, etc.
- **Videos**: .mp4, .mkv, .avi, .mov, etc.
- **Pictures**: .jpg, .jpeg, .png, .gif, .webp, etc.

**Unknown files**: If a file has an unsupported or unrecognized extension, Floord automatically creates an Unknown folder inside the designated organization directory (if it doesn't already exist) and moves the file there.

## File Cleaning

**Floord** can help keep your default folders clean by identifying files that haven't been accessed or modified for a specified period of time.

You can configure which directories Floord should scan, as well as specify paths to exclude from the cleaning process.

Depending on your configuration, Floord can group outdated files for easier management or automatically delete them.

# Installation

### Linux
Execute:
```bash
curl -fsSL https://raw.githubusercontent.com/polete-bermejo/floord/main/installers/install.sh | sh
```

### Windows
Execute:
```powershell
irm https://raw.githubusercontent.com/polete-bermejo/floord/main/installers/install.ps1 | iex
```

# Uninstall
This stops and removes the startup task or daemon, the Floord process, the binary and the configuration folder.

## Linux
Execute:
```bash
curl -fsSL https://raw.githubusercontent.com/polete-bermejo/floord/main/uninstallers/uninstall.sh | sh
```

## Windows
Execute:
```powershell
irm https://raw.githubusercontent.com/polete-bermejo/floord/main/uninstallers/uninstall.ps1 | iex
```

## Service Guide
To see the available commands and options, run:
```bash
floord --help
```

> [!NOTE]
> A graphical interface for Floord is currently under development!
> Check out floord-gui and feel free to contribute if you'd like to help with the project.