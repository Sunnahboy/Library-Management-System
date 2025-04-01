; =============================================================================
; BSS Section for Library Management System
; =============================================================================
;
; This file defines all uninitialized data structures for the application.
; Memory is allocated but not filled with values until runtime.
;
; Data is organized by functional groups:
; - User authentication and session data
; - Book database structures
; - Temporary working data
; - Statistics counters
; - I/O and file operation buffers
; - Borrower tracking data
;
; All sizes are explicitly defined to ensure proper memory allocation.
; =============================================================================

; -----------------------------------------------------------------------------
; User Authentication and Session Data
; -----------------------------------------------------------------------------
; Current user session information
current_user_role    resd 1      ; Current user role (1=admin, 2=librarian, 3=guest)
username_buffer      resb 32     ; Buffer for username input (expanded for safety)
password_buffer      resb 32     ; Buffer for password input (expanded for safety)
choice               resb 2      ; Buffer for storing user menu choice (char + null)

; -----------------------------------------------------------------------------
; Book Database
; -----------------------------------------------------------------------------
; Main database storage
books_db             resb MAX_BOOKS * BOOK_SIZE  ; Storage for all book records
book_count           resd 1      ; Number of books in the database

; Search results
search_result        resd 1      ; Index of found book, -1 if not found

; -----------------------------------------------------------------------------
; Temporary Book Data for Operations
; -----------------------------------------------------------------------------
; Current book being processed
temp_book_id         resb 6      ; Book ID (5 digits + null)
temp_book_title      resb 51     ; Book title (50 chars + null)
temp_book_author     resb 31     ; Book author (30 chars + null)
temp_book_quantity   resd 1      ; Total number of copies
temp_book_issued     resd 1      ; Number of copies currently issued
temp_book_category   resd 1      ; Category of the book (1-5)

; -----------------------------------------------------------------------------
; Statistics Counters
; -----------------------------------------------------------------------------
; Library statistics
stat_total_books     resd 1      ; Total number of books in the system
stat_books_issued    resd 1      ; Total number of books issued
stat_books_available resd 1      ; Total number of books available
stat_by_category     resd 6      ; Count of books in each category (1-5 + unknown)

; -----------------------------------------------------------------------------
; Date and Loan Operations
; -----------------------------------------------------------------------------
; Date handling for book loans
issue_date_buffer    resb 11     ; DD/MM/YYYY + null
due_date_buffer      resb 11     ; DD/MM/YYYY + null
current_date_buffer  resb 11     ; DD/MM/YYYY + null

; Fine calculation
days_late            resd 1      ; Number of days book is overdue
fine_amount          resd 1      ; Fine amount in cents

; -----------------------------------------------------------------------------
; File I/O Variables
; -----------------------------------------------------------------------------
; File operations
file_descriptor      resd 1      ; File descriptor for I/O operations
file_buffer          resb 256    ; Buffer for file operations

; -----------------------------------------------------------------------------
; Borrower Tracking Data
; -----------------------------------------------------------------------------
; Borrower information
borrower_id_buffer   resb 11     ; Borrower ID (10 chars + null)
borrower_score       resd 1      ; Borrower history score (0-10)
last_borrower        resb 11     ; Last borrower ID
last_borrowed_book   resb 6      ; Last borrowed book ID
borrow_count         resd 1      ; Total number of borrows

; -----------------------------------------------------------------------------
; Working Buffers
; -----------------------------------------------------------------------------
; General purpose buffer for temporary storage
temp_buffer          resb 512    ; Multi-purpose buffer for string operations

; -----------------------------------------------------------------------------
; New Variables for Enhanced Guest Experience
; -----------------------------------------------------------------------------
; Search and display functionality
search_mode          resd 1      ; 0 = search by title, 1 = search by author
match_count          resd 1      ; Number of matches found in search/filter

; Category browsing
selected_category    resd 1      ; Selected category for browsing (1-5, or 6 for all)
