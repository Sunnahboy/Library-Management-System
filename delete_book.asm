; =============================================================================
; Book Deletion Module for Library Management System
; =============================================================================
;
; This module handles the deletion of books from the library database.
; It provides safe deletion with confirmation and prevents deletion of
; books that currently have copies issued to borrowers.
;
; The module implements:
; - Book lookup by ID
; - Confirmation prompt before deletion
; - Safety check to prevent deletion of issued books
; - Database update after deletion
; - Comprehensive error handling
;
; Note: This module requires admin privileges to use.
; =============================================================================

; Function: delete_book
; Purpose: Delete a book from the library
; Input: None
; Output: None (returns to main menu)
; Registers: All preserved
delete_book:
    ; Save registers we'll use
    push eax
    push ebx
    push ecx
    push edx

    ; Display framed title
    mov eax, delete_title
    call display_framed_title

    ; -----------------------------------------------------------------
    ; Get and validate book ID
    ; -----------------------------------------------------------------
    ; Display prompt in cyan
    mov eax, COLOR_CYAN
    mov ebx, delete_prompt
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
    ; Check if the book has issued copies
    ; -----------------------------------------------------------------
    mov eax, [temp_book_issued]
    test eax, eax
    jnz .books_issued

    ; -----------------------------------------------------------------
    ; Confirm deletion
    ; -----------------------------------------------------------------
    ; Display confirmation prompt in red (warning color)
    mov eax, COLOR_RED
    mov ebx, delete_confirm
    call print_colored

    ; Get user confirmation
    mov ecx, input_buffer
    mov edx, 2                      ; Just 'Y'/'N' + null
    call get_string

    ; Check if user confirmed with 'Y' or 'y'
    mov al, [input_buffer]
    cmp al, 'Y'
    je .do_delete
    cmp al, 'y'
    je .do_delete

    ; User did not confirm, abort
    mov eax, COLOR_YELLOW
    mov ebx, delete_abort
    call print_colored
    jmp .finish

.do_delete:
    ; -----------------------------------------------------------------
    ; Remove book from database
    ; -----------------------------------------------------------------
    call remove_book

    ; Display success message
    mov eax, COLOR_GREEN
    mov ebx, delete_success
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

.books_issued:
    ; Cannot delete book with issued copies
    mov eax, COLOR_RED
    mov ebx, delete_issued_error
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

; -----------------------------------------------------------------------------
; Function: remove_book
; Purpose: Remove a book from the database (shifts remaining books)
; Input: [search_result] contains index of book to remove
; Output: book_count updated, remaining books shifted
; Registers: All preserved
; -----------------------------------------------------------------------------
remove_book:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Get book index
    mov ebx, [search_result]

    ; Calculate address of current book
    mov eax, BOOK_SIZE
    mul ebx                        ; EAX = search_result * BOOK_SIZE
    mov edi, books_db
    add edi, eax                   ; EDI points to book to remove

    ; Calculate address of next book
    mov esi, edi
    add esi, BOOK_SIZE             ; ESI points to the next book

    ; Calculate number of bytes to move
    mov eax, [book_count]
    sub eax, ebx                   ; Number of books after the one to remove
    dec eax                        ; Adjust for zero-based index

    ; Check if this is the last book (nothing to move)
    test eax, eax
    jle .update_count

    ; Calculate bytes to move
    mov ecx, BOOK_SIZE
    mul ecx                        ; EAX = Number of bytes to move

    ; Move the remaining books (shift them up)
    mov ecx, eax
    cld                            ; Clear direction flag (forward)
    rep movsb                      ; Move bytes from ESI to EDI

.update_count:
    ; Decrement book count
    mov eax, [book_count]
    dec eax
    mov [book_count], eax

    ; Update statistics
    call update_statistics

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
