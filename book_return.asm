; =============================================================================
; Book Return Module for Library Management System
; =============================================================================
;
; This module handles the return of borrowed books to the library.
; It allows staff to record when a book is returned and updates its
; availability status in the database.
;
; The module implements:
; - Book lookup by ID
; - Validation to ensure the book exists and is currently issued
; - Immediate status update in the database after return
; - Comprehensive error handling
; =============================================================================

; Function: return_book
; Purpose: Handle the return of a borrowed book
; Input: None
; Output: None (returns to main menu)
; Registers: All preserved
return_book:
    ; Save registers we'll use
    push eax
    push ebx
    push ecx
    push edx

    ; Clear the screen for a clean interface
    call clear_screen

    ; Display framed title
    mov eax, return_title
    call display_framed_title

    ; -----------------------------------------------------------------
    ; Get and validate book ID
    ; -----------------------------------------------------------------
    ; Display prompt in cyan
    mov eax, COLOR_CYAN
    mov ebx, return_prompt
    call print_colored

    ; Get user input
    mov ecx, temp_book_id
    mov edx, 6                      ; Max 5 digits + null
    call get_string

    ; Validate book ID format (ensure it's not empty)
    mov eax, temp_book_id
    call validate_not_empty
    cmp eax, 0
    je .not_found

    ; -----------------------------------------------------------------
    ; Search for the book in database
    ; -----------------------------------------------------------------
    call find_book

    ; Check if book was found
    cmp dword [search_result], ERR_NOT_FOUND
    je .not_found

    ; Load book details from database
    call load_book

    ; Display detailed book information
    call display_book_details

    ; -----------------------------------------------------------------
    ; Check if the book has any issued copies
    ; -----------------------------------------------------------------
    mov eax, [temp_book_issued]
    test eax, eax
    jz .no_copies_issued

    ; -----------------------------------------------------------------
    ; Update book status in database
    ; -----------------------------------------------------------------
    ; Record return date as today (optional)
    mov dword [issue_date_buffer], "Toda"
    mov dword [issue_date_buffer+4], "y"
    mov byte [issue_date_buffer+8], NULL

    ; Decrease issued count
    dec dword [temp_book_issued]

    ; Update statistics
    mov eax, [stat_books_issued]
    dec eax
    mov [stat_books_issued], eax

    mov eax, [stat_books_available]
    inc eax
    mov [stat_books_available], eax

    ; Update book in database
    call update_book

    ; -----------------------------------------------------------------
    ; Display success message
    ; -----------------------------------------------------------------
    mov eax, COLOR_GREEN
    mov ebx, return_success_msg
    call print_colored

    jmp .finish

; -----------------------------------------------------------------
; Error handling section
; -----------------------------------------------------------------

.not_found:
    ; Book not found in database
    mov eax, COLOR_RED
    mov ebx, book_not_found_msg
    call print_colored
    jmp .finish

.no_copies_issued:
    ; No copies of this book are currently issued
    mov eax, COLOR_RED
    mov ebx, return_fail_msg
    call print_colored
    jmp .finish

.finish:
    ; Wait for user to press Enter before returning to menu
    mov eax, COLOR_WHITE
    mov ebx, press_any_key
    call print_colored
    call wait_for_enter

    ; Restore registers
    pop edx
    pop ecx
    pop ebx
    pop eax

    ; Return to main menu
    jmp main_loop
