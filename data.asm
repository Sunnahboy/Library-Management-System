; =============================================================================
; Data Section for Library Management System
; =============================================================================
;
; This file contains all initialized data for the Library Management System.
; Data is organized by functional categories for better maintainability:
; - System constants and file paths
; - Color codes and UI elements
; - Login and authentication data
; - Book management strings and messages
; - Menu and prompt texts
; - Error messages
;
; All strings are null terminated for proper string handling.
; =============================================================================

section .data

; -----------------------------------------------------------------------------
; System Constants and File Paths
; -----------------------------------------------------------------------------
default_data_file    db "library_data.csv", 0
database_filename    db "library_data.dat", 0
file_header          db "LIBMANSYS", 0
file_header_len      equ 9


; Common formatting elements
colon_space          db ": ", 0

; -----------------------------------------------------------------------------
; ANSI Color Codes and UI Elements
; -----------------------------------------------------------------------------
; Color codes for text formatting
COLOR_RESET          db 27, "[0m", 0      ; Reset to default
COLOR_RED            db 27, "[31m", 0     ; Red (errors, warnings)
COLOR_GREEN          db 27, "[32m", 0     ; Green (success, available)
COLOR_YELLOW         db 27, "[33m", 0     ; Yellow (caution, partial)
COLOR_BLUE           db 27, "[34m", 0     ; Blue (information)
COLOR_MAGENTA        db 27, "[35m", 0     ; Magenta (categories)
COLOR_CYAN           db 27, "[36m", 0     ; Cyan (prompts)
COLOR_WHITE          db 27, "[37m", 0     ; White (normal text)
COLOR_BOLD           db 27, "[1m", 0      ; Bold text
COLOR_UNDERLINE      db 27, "[4m", 0      ; Underlined text

; UI elements for tables and frames
table_header_border  db "+--------+--------------------------------+----------------------+----------+-------------+", 0
table_header_row     db "| ID     | Title                          | Author              | Available | Category    |", 0
table_separator_pipe db "| ", 0
table_pipe           db "|", 0
UI_HORIZONTAL_LINE   db "+------------------------------------------------------------------------+", LF, 0
UI_EMPTY_LINE        db "|                                                                        |", LF, 0
UI_TITLE_FORMAT      db "|                      %s                      |", LF, 0

; Clear screen sequence (without NULL terminator for direct syscall use)
clear_seq            db 27, "[H", 27, "[2J"  ; ANSI escape sequence: ESC[H ESC[2J
clear_seq_len        equ $ - clear_seq

; -----------------------------------------------------------------------------
; Login and Authentication Data
; -----------------------------------------------------------------------------
; Login strings and prompts
login_title          db "LIBRARY MANAGEMENT SYSTEM LOGIN", 0
username_prompt      db "Username: ", 0
password_prompt      db "Password: ", 0
login_success        db "Login successful!", LF, 0
login_error          db "Invalid username or password. Try again.", LF, 0

; User credentials
admin_username       db "admin", 0
admin_password       db "admin123", 0
librarian_username   db "librarian", 0
librarian_password   db "lib123", 0

; Role display messages
admin_role_msg       db "Logged in as: Administrator", LF, 0
librarian_role_msg   db "Logged in as: Librarian", LF, 0
guest_role_msg       db "Logged in as: Guest", LF, 0

; -----------------------------------------------------------------------------
; Book Management Strings and Messages
; -----------------------------------------------------------------------------
; Book operation titles
add_book_title       db "ADD NEW BOOK", 0
search_title         db "SEARCH BOOK", 0
issue_title          db "ISSUE BOOK", 0
return_title         db "RETURN BOOK", 0
delete_title         db "DELETE BOOK", 0
fine_title           db "CALCULATE FINE", 0
borrow_title         db "BOOK BORROWING REQUEST", 0
view_borrowed_title  db "VIEW BORROWED BOOKS", 0
save_title           db "SAVE LIBRARY DATA", 0
load_title           db "LOAD LIBRARY DATA", 0
stats_title          db "LIBRARY STATISTICS", 0

; Book input prompts
prompt_book_id       db "Enter Book ID (max 5 digits): ", 0
prompt_book_title    db "Enter Book Title (max 50 chars): ", 0
prompt_book_author   db "Enter Author Name (max 30 chars): ", 0
prompt_book_quantity db "Enter Quantity (total copies of this book): ", 0
prompt_book_category db "Select Category:", LF
                     db "1. Fiction", LF
                     db "2. Non-fiction", LF
                     db "3. Reference", LF
                     db "4. Textbook", LF
                     db "5. Magazine", LF
                     db "Enter choice (1-5): ", 0

; Book category names
category_fiction     db "Fiction", 0
category_nonfiction  db "Non-fiction", 0
category_reference   db "Reference", 0
category_textbook    db "Textbook", 0
category_magazine    db "Magazine", 0
unknown_category     db "Unknown", 0

; Category pointers array
category_names       dd category_fiction, category_nonfiction, category_reference, category_textbook, category_magazine, unknown_category

; Book operation prompts
search_prompt        db "Enter Book ID to search: ", 0
issue_prompt         db "Enter Book ID to issue: ", 0
return_prompt        db "Enter Book ID to return: ", 0
delete_prompt        db "Enter Book ID to delete: ", 0
delete_confirm       db "Are you sure you want to delete this book? (Y/N): ", 0
borrower_prompt      db "Enter Borrower ID: ", 0
fine_prompt          db "Enter Book ID: ", 0
days_prompt          db "Enter days overdue: ", 0
prompt_issue_date    db "Enter issue date (DD/MM/YYYY): ", 0
prompt_due_date      db "Enter due date (DD/MM/YYYY): ", 0
days_overdue         db "Days overdue: ", 0
approve_prompt       db "Approve this request? (Y/N): ", 0

; Fine rate display messages
fine_rate_fiction    db "Fine rate (Fiction): $0.50 per day", LF, 0
fine_rate_nonfiction db "Fine rate (Non-fiction): $0.40 per day", LF, 0
fine_rate_reference  db "Fine rate (Reference): $0.75 per day", LF, 0
fine_rate_textbook   db "Fine rate (Textbook): $0.60 per day", LF, 0
fine_rate_magazine   db "Fine rate (Magazine): $0.30 per day", LF, 0
fine_result          db "Total fine: $", 0

; -----------------------------------------------------------------------------
; Status and Result Messages
; -----------------------------------------------------------------------------
; Success messages
book_added_msg       db "Book added successfully!", LF, 0
book_found_msg       db "Book found!", LF, 0
issue_success_msg    db "Book issued successfully!", LF, 0
return_success_msg   db "Book returned successfully!", LF, 0
delete_success       db "Book deleted successfully!", LF, 0
save_success         db "Library data saved successfully!", LF, 0
load_success         db "Library data loaded successfully!", LF, 0
auto_approve_message db "Request automatically approved based on borrower history.", LF, 0

; Failure and warning messages
book_exists_msg      db "Book with this ID already exists!", LF, 0
book_not_found_msg   db "Book not found in the library.", LF, 0
issue_fail_msg       db "Cannot issue book. No copies available!", LF, 0
return_fail_msg      db "Cannot return book. No copies issued!", LF, 0
delete_abort         db "Deletion aborted.", LF, 0
delete_issued_error  db "Error: Cannot delete book with issued copies!", LF, 0
deny_message         db "Request denied.", LF, 0
history_warning      db "Warning: Borrower has poor borrowing history!", LF, 0
no_borrowed_books    db "No books are currently borrowed.", LF, 0
borrowed_books_header db "Currently Borrowed Books:", LF, 0

; File operation error messages
file_error_msg       db "Error: Could not open file!", LF, 0
write_error_msg      db "Error: Could not write to file!", LF, 0
read_error_msg       db "Error: Could not read from file!", LF, 0
format_error_msg     db "Error: Invalid file format!", LF, 0

; -----------------------------------------------------------------------------
; Input Validation Error Messages
; -----------------------------------------------------------------------------
error_invalid_id     db "Error: Invalid book ID. Please use digits only.", LF, 0
error_invalid_quantity db "Error: Invalid quantity. Please enter a number.", LF, 0
error_empty_title    db "Error: Book title cannot be empty.", LF, 0
error_empty_author   db "Error: Author name cannot be empty.", LF, 0
error_negative_quantity db "Error: Quantity must be a positive number.", LF, 0
error_invalid_category db "Error: Invalid category choice. Please enter 1-5.", LF, 0
invalid_choice       db "Invalid choice. Please try again.", LF, 0
unauthorized_msg     db "You don't have permission to access this feature.", LF, 0
error_date_format     db "Error: Invalid date format. Please use DD/MM/YYYY format.", LF, 0


; -----------------------------------------------------------------------------
; Statistics Display Strings
; -----------------------------------------------------------------------------
stats_total_books    db "Total books in library: ", 0
stats_books_issued   db "Total books currently issued: ", 0
stats_books_available db "Total books available: ", 0
stats_category_header db "Books by category:", LF, 0
stats_category_format db "  %s: %d", LF, 0

; -----------------------------------------------------------------------------
; Common UI Messages and Prompts
; -----------------------------------------------------------------------------
press_any_key        db "Press ENTER to continue...", LF, 0
goodbye_msg          db "Thank you for using the Library Management System. Goodbye!", LF, 0
book_display_format  db "ID: %s | Title: %s | Author: %s | Available: %d | Category: %s", LF, 0

; -----------------------------------------------------------------------------
; Menu Displays
; -----------------------------------------------------------------------------
welcome_msg          db "LIBRARY MANAGEMENT SYSTEM", 0

; Admin menu
admin_menu_prompt    db "Admin Menu - Please select an option:", LF
                     db "1. Add a new book", LF
                     db "2. Search for a book", LF
                     db "3. Issue a book", LF
                     db "4. Return a book", LF
                     db "5. Display all books", LF
                     db "6. Calculate fines", LF
                     db "7. View statistics", LF
                     db "8. Delete a book", LF
                     db "9. Borrow request", LF
                     db "A. Save data to file", LF
                     db "B. Load data from file", LF
                     db "C. View borrowed books", LF
                     db "X. Exit", LF
                     db "L. Back to Login", LF
                     db "Enter your choice: ", 0

; Librarian menu
librarian_menu_prompt db "Librarian Menu - Please select an option:", LF
                     db "1. Search for a book", LF
                     db "2. Issue a book", LF
                     db "3. Return a book", LF
                     db "4. Display all books", LF
                     db "5. Calculate fines", LF
                     db "6. Borrow request", LF
                     db "7. View borrowed books", LF
                     db "X. Exit", LF
                     db "L. Back to Login", LF
                     db "Enter your choice: ", 0

; Guest menu with new options
guest_menu_prompt    db "Guest Menu:", LF
                     db "1. Search for a book by ID", LF
                     db "2. Search for a book by Title/Author", LF  ; New option
                     db "3. Display all books", LF
                     db "4. Borrow request", LF
                     db "5. Return a book", LF
                     db "6. View my borrowed books", LF             ; New option
                     db "7. Browse books by category", LF           ; New option
                     db "8. Library information", LF                ; New option
                     db "H. Help", LF                               ; New option
                     db "X. Exit", LF
                     db "L. Back to Login", LF
                     db "Enter your choice: ", 0

; -----------------------------------------------------------------------------
; New Guest Experience Strings
; -----------------------------------------------------------------------------
; Help and information messages
guest_help_msg       db "Help for Guest Users:", LF
                     db "- To borrow books, you need a borrower ID (starts with a letter)", LF
                     db "- Books can be borrowed for 1-10 days", LF
                     db "- Search by title allows partial matches", LF
                     db "- Borrower IDs starting with A have highest privileges", LF
                     db "- You can browse books by category", LF
                     db "- Return a book using only its ID", LF, 0

borrower_id_help     db "Borrower ID starts with a letter (A-Z). IDs starting with A have", LF
                     db "the highest borrowing privileges.", LF, 0

; Updated error message
empty_borrower_id    db "Error: Borrower ID cannot be empty.", LF
                     db "Borrower ID must start with a letter (A-Z).", LF
                     db "IDs starting with A have the highest privileges.", LF, 0

; Welcome and navigation messages
guest_welcome        db "Welcome to the Library System - Guest Access", LF, LF
                     db "As a guest, you can:", LF
                     db "- Browse and search for books", LF
                     db "- Borrow books with a borrower ID", LF
                     db "- Return books", LF, LF
                     db "Press H at any time for help", LF, 0

back_option          db " (or type 'back' to return to menu)", 0

; New screen titles
search_title_author  db "SEARCH BY TITLE OR AUTHOR", 0
my_borrows_title     db "MY BORROWED BOOKS", 0
browse_category_title db "BROWSE BOOKS BY CATEGORY", 0
library_info_title   db "LIBRARY INFORMATION", 0
help_title           db "GUEST HELP CENTER", 0

; Library status display
library_status_heading db "Library Status Overview:", LF, 0
books_available_msg  db " books available for borrowing", LF, 0
books_by_cat_msg     db "Books by category:", LF, 0
most_popular_msg     db "Most popular books:", LF, 0

; Search prompts
title_search_prompt  db "Enter book title to search (or part of title): ", 0
author_search_prompt db "Enter author name to search (or part of name): ", 0
no_matches_found     db "No matching books found for your search criteria.", LF, 0
multiple_matches     db "Multiple matches found. Please refine your search.", LF, 0

; Category browsing
category_select_prompt db "Select category to browse:", LF
                     db "1. Fiction", LF
                     db "2. Non-fiction", LF
                     db "3. Reference", LF
                     db "4. Textbook", LF
                     db "5. Magazine", LF
                     db "6. All categories", LF
                     db "Enter choice (1-6): ", 0

; Borrower history prompt
borrower_id_view_prompt db "Enter your Borrower ID to view your borrowed books: ", 0
no_borrowed_by_user  db "You haven't borrowed any books yet.", LF, 0

; New borrowing system
prompt_borrow_days  db "Number of days to borrow (1-10): ", 0
error_invalid_days  db "Error: Please enter a number between 1 and 10.", LF, 0
return_date_msg     db "Book must be returned within ", 0
days_suffix         db " days.", LF, 0

; -----------------------------------------------------------------------------
; Input Buffer
; -----------------------------------------------------------------------------
; Reserve 64 bytes for input buffer, initialized to zeros
input_buffer         times 64 db 0
