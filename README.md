# Library Management System

A comprehensive Library Management System written in x86 Assembly language. This system provides a complete solution for managing a library's book inventory, user borrowing, and administrative functions.

## Features

- **Multi-User Roles**: Support for Administrators, Librarians, and Guests with role-appropriate permissions
- **Book Management**: Add, search, display, issue, return, and delete books
- **Borrowing System**: Track book borrowing with issue dates and due dates
- **Fine Calculation**: Category-based fine rates for overdue books
- **Statistical Reporting**: Real-time statistics on book inventory and usage
- **Data Persistence**: Save and load library data to/from files
- **User-Friendly Interface**: Color-coded terminal UI with intuitive navigation

## System Requirements

- Linux-based operating system
- NASM (Netwide Assembler)
- x86 processor architecture

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Sunnahboy/Library-Management-System.git
   cd Library-Management-System
   ```

2. Compile the program:
   ```bash
   make
   ```

3. Run the program:
   ```bash
   ./library_system
   ```

## Usage

### Login Credentials

- **Administrator**:
  - Username: `admin`
  - Password: `admin123`

- **Librarian**:
  - Username: `librarian`
  - Password: `lib123`

- **Guest**:
  - No credentials required

### Menu Navigation

- Navigate through menus by entering the corresponding option number or letter
- Return to previous menus by typing 'back' at most prompts
- Exit the program by selecting the 'X' option from the main menu

### Book Operations

- **Adding Books**: Enter book details including ID, title, author, category, and quantity
- **Searching**: Search by book ID, title, or author
- **Issuing/Returning**: Process book checkouts and returns with date tracking
- **Calculating Fines**: Determine fines for overdue books based on category rates

## Project Structure

- **main.asm**: Main program entry point and menu system
- **book_*.asm**: Book operation modules (add, search, display, issue, return)
- **utility.asm**: Core utility functions for I/O, validation, and data processing
- **data.asm**: Initialized data section with strings and constants
- **bss.asm**: Uninitialized data structures
- **file_io.asm**: File operations for data persistence
- **statistics.asm**: Statistical calculations and reporting

## Makefile Options

- `make`: Build the executable
- `make debug`: Build with debugging symbols
- `make clean`: Remove object files and executable
- `make run`: Build and run the program
- `make install`: Install the program to /usr/local/bin
- `make uninstall`: Remove the installed program
- `make backup`: Create a backup of source files
- `make help`: Show all available make targets


### For complete comprehensive documentation  check here: https://docs.google.com/document/d/1cVzvWKBj2Te0J_eSTxYCdKJxfqdygi905hb-St-5FDM/edit?usp=sharing

## License

[MIT License ]

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Acknowledgments

- [This was part of @ASia pacific Univesity course]