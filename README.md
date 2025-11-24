# Scripts Collection 🚀

A collection of useful CLI-based tools and scripts for everyday tasks.

## 📁 Structure

```
.
├── bin/           # Executable CLI scripts
├── utils/         # Utility helper scripts
└── README.md      # This file
```

## 🛠️ Scripts

### bin/

- **backup.sh** - Create timestamped backups of files or directories
  ```bash
  ./bin/backup.sh /path/to/file [destination]
  ```

- **git-cleanup.sh** - Clean up merged Git branches (local and remote tracking)
  ```bash
  ./bin/git-cleanup.sh [--dry-run]
  ```

- **file-organizer.sh** - Organize files in a directory by their extensions
  ```bash
  ./bin/file-organizer.sh [directory]
  ```

- **port-check.sh** - Check what process is using a specific port
  ```bash
  ./bin/port-check.sh <port>
  ```

### utils/

- **colors.sh** - Utility functions for colored terminal output
  ```bash
  source utils/colors.sh
  print_success "Success message"
  print_error "Error message"
  ```

## 🚀 Usage

Make scripts executable:
```bash
chmod +x bin/*
```

Run a script:
```bash
./bin/script-name.sh
```

Or add the `bin` directory to your PATH:
```bash
export PATH="$PATH:$(pwd)/bin"
```

## 📝 Adding New Scripts

1. Create your script in the appropriate directory
2. Make it executable: `chmod +x your-script.sh`
3. Add a description header in the script
4. Update this README with usage information

## 🤝 Contributing

Feel free to add your own useful scripts!

## 📄 License

MIT License