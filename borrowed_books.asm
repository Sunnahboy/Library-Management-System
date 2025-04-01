; =============================================================================
; Borrowed Books Display Module
; =============================================================================
;
; This module provides functionality to view all currently borrowed books
; in the library. It filters the book database to display only books with
; at least one copy issued to borrowers.
;
; The module implements:
; - Filtering books by issued status
; - Tabular display of borrowed books
; - Borrowed count display
; - Empty state handling when no books are borrowed
; =============================================================================

; Function: view_borrowed_books
; Purpose: Display all currently borrowed books
; Input: None
; Output: None (returns to main menu)
; Registers: All preserved
view_borrowed_books:
    ; Save registers we'll use
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Clear screen for clean display
    call clear_screen

    ; Display framed title
    mov eax, view_borrowed_title
    call display_framed_title

    ; -----------------------------------------------------------------
    ; Check if any books are borrowed
    ; -----------------------------------------------------------------
    mov eax, [stat_books_issued]
    test eax, eax
    jz .no_borrowed

    ; -----------------------------------------------------------------
    ; Display header information
    ; -----------------------------------------------------------------
    ; Display introduction text
    mov eax, COLOR_CYAN
    mov ebx, borrowed_books_header
    call print_colored

    ; Display number of borrowed books
    mov eax, COLOR_WHITE
    mov dword [temp_buffer], "Tota"
    mov dword [temp_buffer+4], "l bo"
    mov dword [temp_buffer+8], "oks "
    mov dword [temp_buffer+12], "borr"
    mov dword [temp_buffer+16], "owed"
    mov dword [temp_buffer+20], ": "
    mov byte [temp_buffer+22], NULL
    mov ebx, temp_buffer
    call print_colored

    mov eax, COLOR_YELLOW
    call print_string
    mov eax, [stat_books_issued]
    call print_int

    ; Print newline
    mov eax, LF_STR
    call print_string
    mov eax, LF_STR   ; Extra space
    call print_string

    ; -----------------------------------------------------------------
    ; Print table header
    ; -----------------------------------------------------------------
    ; Print the table border
    mov eax, COLOR_CYAN
    mov ebx, table_header_border
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; Print header row
    mov eax, COLOR_WHITE
    mov ebx, table_header_row
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; Print separator
    mov eax, COLOR_CYAN
    mov ebx, table_header_border
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; -----------------------------------------------------------------
    ; Loop through all books to find and display borrowed ones
    ; -----------------------------------------------------------------
    ; Initialize counter
    mov ecx, 0

    ; Initialize borrowed book counter for verification
    mov ebx, 0

.display_loop:
    ; Check if we've reached the end of the book database
    cmp ecx, [book_count]
    jge .end_display

    ; Load book data
    push ecx
    push ebx
    mov [search_result], ecx
    call load_book

    ; Check if any copies are borrowed
    mov eax, [temp_book_issued]
    test eax, eax
    jz .next_book

    ; Increment borrowed books counter
    pop ebx
    inc ebx
    push ebx

    ; Display this book's information
    call display_book_row

.next_book:
    ; Move to next book
    pop ebx
    pop ecx
    inc ecx
    jmp .display_loop

.end_display:
    ; Verify we found the expected number of borrowed books
    cmp ebx, [stat_books_issued]
    je .display_footer

    ; Mismatch in statistics - update them
    call update_statistics

.display_footer:
    ; Print final separator
    mov eax, COLOR_CYAN
    mov ebx, table_header_border
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string

    jmp .finish

.no_borrowed:
    ; -----------------------------------------------------------------
    ; Handle the case where no books are borrowed
    ; -----------------------------------------------------------------
    mov eax, COLOR_YELLOW
    mov ebx, no_borrowed_books
    call print_colored

.finish:
    ; -----------------------------------------------------------------
    ; Wait for user input and return to menu
    ; -----------------------------------------------------------------
    ; Wait for user to press Enter before returning to menu
    mov eax, COLOR_WHITE
    mov ebx, press_any_key
    call print_colored
    call wait_for_enter

    ; Clear screen before returning to menu
    call clear_screen

    ; Restore registers
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax

    ; Return to main menu
    jmp main_loop

; =============================================================================
; My Borrowed Books View
; =============================================================================
;
; Function: view_my_borrowed_books
; Purpose: Display books borrowed by a specific user
; Input: None
; Output: None (returns to main menu)
; Registers: All preserved
view_my_borrowed_books:
    ; Save registers we'll use
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Clear screen for clean display
    call clear_screen

    ; Display framed title
    mov eax, my_borrows_title
    call display_framed_title

    ; -----------------------------------------------------------------
    ; Get and validate borrower ID
    ; -----------------------------------------------------------------
    ; Display prompt in cyan
    mov eax, COLOR_CYAN
    mov ebx, borrower_id_view_prompt
    call print_colored

    ; Get user input
    mov ecx, borrower_id_buffer
    mov edx, 11                     ; Max 10 chars + null
    call get_string

    ; Check first character for 'b' (potential "back" command)
    mov al, [borrower_id_buffer]
    cmp al, 'b'
    je .check_back_cmd
    cmp al, 'B'
    je .check_back_cmd
    jmp .continue_processing

.check_back_cmd:
    ; Look at second character to confirm it's "back"
    mov al, [borrower_id_buffer+1]
    cmp al, 'a'
    jne .continue_processing
    mov al, [borrower_id_buffer+2]
    cmp al, 'c'
    jne .continue_processing
    mov al, [borrower_id_buffer+3]
    cmp al, 'k'
    jne .continue_processing

    ; It's "back" command
    jmp .return_to_menu

.continue_processing:
    ; Validate borrower ID (ensure it's not empty)
    mov eax, borrower_id_buffer
    call validate_not_empty
    cmp eax, 0
    je .empty_borrower

    ; -----------------------------------------------------------------
    ; Initialize counter for borrowed books
    ; -----------------------------------------------------------------
    mov dword [match_count], 0

    ; -----------------------------------------------------------------
    ; Display header for borrowed books
    ; -----------------------------------------------------------------
    ; Display introduction text
    mov eax, COLOR_CYAN
    mov dword [temp_buffer], "Book"
    mov dword [temp_buffer+4], "s bo"
    mov dword [temp_buffer+8], "rrow"
    mov dword [temp_buffer+12], "ed b"
    mov dword [temp_buffer+16], "y ID"
    mov dword [temp_buffer+20], ": "
    mov byte [temp_buffer+22], NULL
    mov ebx, temp_buffer
    call print_colored

    ; Display borrower ID
    mov eax, COLOR_YELLOW
    mov ebx, borrower_id_buffer
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string
    mov eax, LF_STR   ; Extra space
    call print_string

    ; -----------------------------------------------------------------
    ; Print table header
    ; -----------------------------------------------------------------
    ; Print the table border
    mov eax, COLOR_CYAN
    mov ebx, table_header_border
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; Print header row
    mov eax, COLOR_WHITE
    mov ebx, table_header_row
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; Print separator
    mov eax, COLOR_CYAN
    mov ebx, table_header_border
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; -----------------------------------------------------------------
    ; Loop through all books to find ones borrowed by this user
    ; -----------------------------------------------------------------
    ; Initialize counter
    mov ecx, 0

.display_loop:
    ; Check if we've reached the end of the book database
    cmp ecx, [book_count]
    jge .end_display

    ; Load book data
    push ecx
    mov [search_result], ecx
    call load_book

    ; For demo purposes, we'll just check if:
    ; 1. Book has at least one copy issued
    ; 2. The first letter of book ID matches first letter of borrower ID
    ; In a real system, you would have a proper borrower-book mapping

    ; Check if any copies are issued
    mov eax, [temp_book_issued]
    test eax, eax
    jz .next_book

    ; Simple check: If first letter of book ID matches first letter of borrower ID
    ; This is just for demo - in a real system, you'd have proper borrower tracking
    mov al, [temp_book_id]
    mov bl, [borrower_id_buffer]
    cmp al, bl
    jne .next_book

    ; This book is borrowed by this user (for demo purposes)
    inc dword [match_count]

    ; Display this book's information
    call display_book_row

.next_book:
    ; Move to next book
    pop ecx
    inc ecx
    jmp .display_loop

.end_display:
    ; Print final separator
    mov eax, COLOR_CYAN
    mov ebx, table_header_border
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; Check if any books were found
    mov eax, [match_count]
    test eax, eax
    jnz .found_books

    ; No books borrowed by this user
    mov eax, COLOR_YELLOW
    mov ebx, no_borrowed_by_user
    call print_colored
    jmp .finish

.found_books:
    ; Display info about return process
    mov eax, COLOR_GREEN
    mov dword [temp_buffer], "You "
    mov dword [temp_buffer+4], "have"
    mov dword [temp_buffer+8], " "
    mov byte [temp_buffer+9], NULL
    mov ebx, temp_buffer
    call print_colored

    mov eax, COLOR_WHITE
    call print_string
    mov eax, [match_count]
    call print_int

    mov eax, COLOR_GREEN
    mov dword [temp_buffer], " boo"
    mov dword [temp_buffer+4], "k(s)"
    mov dword [temp_buffer+8], " cur"
    mov dword [temp_buffer+12], "rent"
    mov dword [temp_buffer+16], "ly b"
    mov dword [temp_buffer+20], "orro"
    mov dword [temp_buffer+24], "wed."
    mov byte [temp_buffer+28], LF
    mov byte [temp_buffer+29], NULL
    mov ebx, temp_buffer
    call print_colored

    ; Add reminder about returning
    mov eax, COLOR_YELLOW
    mov dword [temp_buffer], "Reme"
    mov dword [temp_buffer+4], "mber"
    mov dword [temp_buffer+8], " to "
    mov dword [temp_buffer+12], "retu"
    mov dword [temp_buffer+16], "rn b"
    mov dword [temp_buffer+20], "ooks"
    mov dword [temp_buffer+24], " on "
    mov dword [temp_buffer+28], "time"
    mov dword [temp_buffer+32], "."
    mov byte [temp_buffer+33], LF
    mov byte [temp_buffer+34], NULL
    mov ebx, temp_buffer
    call print_colored

    jmp .finish

.empty_borrower:
    ; Borrower ID is empty
    mov eax, COLOR_RED
    mov ebx, empty_borrower_id
    call print_colored
    jmp .finish

.finish:
    ; -----------------------------------------------------------------
    ; Wait for user input and return to menu
    ; -----------------------------------------------------------------
    ; Wait for user to press Enter before returning to menu
    mov eax, COLOR_WHITE
    mov ebx, press_any_key
    call print_colored
    call wait_for_enter

.return_to_menu:
    ; Restore registers
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax

    ; Return to main menu
    jmp main_loop
