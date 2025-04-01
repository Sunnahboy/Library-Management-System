; =============================================================================
; Constants for Library Management System
; =============================================================================
;
; This file contains all constant definitions used throughout the application.
; - Character and string constants
; - Database size limitations
; - UI/Display formatting constants
; - Role/permission definitions
; - Error codes
;
; All constants are declared with descriptive names to improve code readability
; and maintainability.
; =============================================================================

; -----------------------------------------------------------------------------
; Character Constants
; -----------------------------------------------------------------------------
LF          equ 10      ; Line Feed character (newline)
CR          equ 13      ; Carriage Return character
TAB         equ 9       ; Tab character
SPACE       equ 32      ; Space character
NULL        equ 0       ; String terminator (null byte)

; Commonly used character strings
LF_STR      db LF, 0    ; Newline string (LF followed by null terminator)
CRLF_STR    db CR, LF, 0 ; Windows-style newline string

; -----------------------------------------------------------------------------
; Database Constraints
; -----------------------------------------------------------------------------
MAX_BOOKS   equ 50      ; Maximum number of books in the library
BOOK_SIZE   equ 100     ; Size of each book record in bytes

; Field sizes - used for validation
MAX_ID_LEN          equ 5       ; Maximum book ID length
MAX_TITLE_LEN       equ 50      ; Maximum book title length
MAX_AUTHOR_LEN      equ 30      ; Maximum author name length
MAX_BORROWER_ID_LEN equ 10      ; Maximum borrower ID length
MAX_DATE_LEN        equ 10      ; Maximum date string length (DD/MM/YYYY)

; -----------------------------------------------------------------------------
; Display and UI Constants
; -----------------------------------------------------------------------------
; Column widths for table display
ID_COL_WIDTH        equ 8       ; ID column width
TITLE_COL_WIDTH     equ 32      ; Title column width
AUTHOR_COL_WIDTH    equ 22      ; Author column width
AVAIL_COL_WIDTH     equ 10      ; Availability column width
CATEGORY_COL_WIDTH  equ 13      ; Category column width

; UI element widths
MENU_WIDTH          equ 76      ; Width of menu display
FRAME_WIDTH         equ 72      ; Width of framed text

; -----------------------------------------------------------------------------
; User Roles and Permissions
; -----------------------------------------------------------------------------
ROLE_ADMIN          equ 1       ; Administrator role
ROLE_LIBRARIAN      equ 2       ; Librarian role
ROLE_GUEST          equ 3       ; Guest role

; -----------------------------------------------------------------------------
; Category Constants
; -----------------------------------------------------------------------------
CAT_FICTION         equ 1       ; Fiction category
CAT_NONFICTION      equ 2       ; Non-fiction category
CAT_REFERENCE       equ 3       ; Reference category
CAT_TEXTBOOK        equ 4       ; Textbook category
CAT_MAGAZINE        equ 5       ; Magazine category
CAT_UNKNOWN         equ 6       ; Unknown category

; -----------------------------------------------------------------------------
; Fine Rate Constants (in cents)
; -----------------------------------------------------------------------------
FINE_RATE_FICTION    equ 50     ; $0.50 per day for fiction
FINE_RATE_NONFICTION equ 40     ; $0.40 per day for non-fiction
FINE_RATE_REFERENCE  equ 75     ; $0.75 per day for reference books
FINE_RATE_TEXTBOOK   equ 60     ; $0.60 per day for textbooks
FINE_RATE_MAGAZINE   equ 30     ; $0.30 per day for magazines
FINE_RATE_DEFAULT    equ 50     ; Default fine rate if category unknown

; -----------------------------------------------------------------------------
; Error Code Constants
; -----------------------------------------------------------------------------
ERR_SUCCESS         equ 0       ; Operation succeeded
ERR_NOT_FOUND       equ -1      ; Item not found
ERR_INVALID_INPUT   equ -2      ; Invalid input data
ERR_ACCESS_DENIED   equ -3      ; Permission denied
ERR_OUT_OF_STOCK    equ -4      ; No books available
ERR_FILE_ERROR      equ -5      ; File operation error
