################################################################################
# Makefile for Library Management System
# Features:
# - Improved dependency tracking for all source files
# - Debug build option with debugging symbols
# - Better error handling and validation
# - Additional useful targets (install, uninstall, backup)
################################################################################

# Define variables
ASM := nasm
ASMFLAGS := -f elf
LD := ld
LDFLAGS := -m elf_i386
EXECUTABLE := library_system

# Add debug options if debugging is enabled
ifdef DEBUG
    ASMFLAGS += -g -F dwarf
    LDFLAGS += -g
endif

# Define directories
PREFIX := /usr/local/bin
BACKUP_DIR := ./backup

# All assembly files
ASM_FILES := main.asm constants.asm data.asm bss.asm utility.asm \
             book_add.asm book_search.asm book_display.asm \
             book_issue.asm book_return.asm fines.asm statistics.asm \
             delete_book.asm borrow_request.asm borrowed_books.asm file_io.asm

# Object file (only one since we compile everything into main)
OBJECTS := main.o

# Build date for versioning
BUILD_DATE := $(shell date +"%Y%m%d")

# Declare phony targets (targets that don't represent files)
.PHONY: all clean run debug install uninstall backup help

# Default target
all: $(EXECUTABLE)

# Debug build
debug:
	@echo "Building with debug symbols..."
	$(MAKE) DEBUG=1 all

# Link object files to create executable
$(EXECUTABLE): $(OBJECTS)
	@echo "Linking $@..."
	$(LD) $(LDFLAGS) -o $@ $^
	@echo "Build completed successfully!"
	@echo "Run with: ./$(EXECUTABLE)"

# Compile assembly files to object file
# The dependency on all ASM_FILES ensures recompilation when any source changes
main.o: $(ASM_FILES)
	@echo "Compiling $@..."
	$(ASM) $(ASMFLAGS) -o $@ main.asm

# Clean up generated files
clean:
	@echo "Cleaning up..."
	rm -f $(OBJECTS) $(EXECUTABLE)
	@echo "Clean completed."

# Run the program
run: $(EXECUTABLE)
	@echo "Running $(EXECUTABLE)..."
	./$(EXECUTABLE)

# Install the executable
install: $(EXECUTABLE)
	@echo "Installing to $(PREFIX)..."
	install -D $(EXECUTABLE) $(PREFIX)/$(EXECUTABLE)
	@echo "Installation completed."

# Uninstall the executable
uninstall:
	@echo "Uninstalling from $(PREFIX)..."
	rm -f $(PREFIX)/$(EXECUTABLE)
	@echo "Uninstallation completed."

# Create a backup of source files
backup:
	@echo "Creating backup..."
	@mkdir -p $(BACKUP_DIR)
	@tar -czf $(BACKUP_DIR)/$(EXECUTABLE)_$(BUILD_DATE).tar.gz $(ASM_FILES) Makefile
	@echo "Backup created at $(BACKUP_DIR)/$(EXECUTABLE)_$(BUILD_DATE).tar.gz"

# Show help information
help:
	@echo "Library Management System - Make targets:"
	@echo "  make          - Build the executable"
	@echo "  make debug    - Build with debugging symbols"
	@echo "  make clean    - Remove object files and executable"
	@echo "  make run      - Build and run the program"
	@echo "  make install  - Install the program to $(PREFIX)"
	@echo "  make uninstall- Remove the installed program"
	@echo "  make backup   - Create a backup of all source files"
	@echo "  make help     - Show this help message"
