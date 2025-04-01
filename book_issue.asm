; =============================================================================
; Book Issue Module for Library Management System
; =============================================================================
;
; This module handles issuing books to borrowers. It allows staff to record
; when a book is loaned out, including recording issue and due dates.
;
; The module implements:
; - Book lookup by ID
; - Availability checking
; - Issue date and due date recording with validation
; - Book status update in the database
; - Comprehensive error handling
;
; Note: This module requires librarian or admin privileges to use.
; =============================================================================

; Function: issue_book
; Purpose: Issue a book to a borrower
; Input: None
; Output: None (returns to main menu)
; Registers: All preserved
issue_book:
    ; Save registers we'll use
    push eax
    push ebx
    push ecx
    push edx

    ; Clear the screen for a clean interface
    call clear_screen

    ; Display framed title
    mov eax, issue_title
    call display_framed_title

    ; -----------------------------------------------------------------
    ; Get and validate book ID
    ; -----------------------------------------------------------------
    ; Display prompt in cyan
    mov eax, COLOR_CYAN
    mov ebx, issue_prompt
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
    ; Check book availability
    ; -----------------------------------------------------------------
    ; Calculate available copies
    mov eax, [temp_book_quantity]
    mov ebx, [temp_book_issued]

    ; Check if there are available copies
    cmp eax, ebx
    jle .no_copies

    ; -----------------------------------------------------------------
    ; Get and validate issue date
    ; -----------------------------------------------------------------
.get_issue_date:
    mov eax, COLOR_CYAN
    mov ebx, prompt_issue_date
    call print_colored

    mov ecx, issue_date_buffer
    mov edx, 11                     ; DD/MM/YYYY + null
    call get_string

    ; Validate issue date format (basic check for format DD/MM/YYYY)
    mov eax, issue_date_buffer
    call validate_date_format
    cmp eax, 0
    je .invalid_issue_date

    ; -----------------------------------------------------------------
    ; Get and validate due date
    ; -----------------------------------------------------------------
.get_due_date:
    mov eax, COLOR_CYAN
    mov ebx, prompt_due_date
    call print_colored

    mov ecx, due_date_buffer
    mov edx, 11                     ; DD/MM/YYYY + null
    call get_string

    ; Validate due date format (basic check for format DD/MM/YYYY)
    mov eax, due_date_buffer
    call validate_date_format
    cmp eax, 0
    je .invalid_due_date

    ; -----------------------------------------------------------------
    ; Update book status in database
    ; -----------------------------------------------------------------
    ; Increase issued count
    inc dword [temp_book_issued]

    ; Update statistics
    mov eax, [stat_books_issued]
    inc eax
    mov [stat_books_issued], eax

    mov eax, [stat_books_available]
    dec eax
    mov [stat_books_available], eax

    ; Update book in database
    call update_book

    ; -----------------------------------------------------------------
    ; Display success message
    ; -----------------------------------------------------------------
    mov eax, COLOR_GREEN
    mov ebx, issue_success_msg
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

.no_copies:
    ; No available copies to issue
    mov eax, COLOR_RED
    mov ebx, issue_fail_msg
    call print_colored
    jmp .finish

.invalid_issue_date:
    ; Invalid issue date format
    mov eax, COLOR_RED
    mov ebx, error_date_format
    call print_colored
    jmp .get_issue_date

.invalid_due_date:
    ; Invalid due date format
    mov eax, COLOR_RED
    mov ebx, error_date_format
    call print_colored
    jmp .get_due_date

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

; Function: validate_date_format
; Purpose: Check if a date string is in valid format (DD/MM/YYYY)
; Input: EAX = date string pointer
; Output: EAX = 1 if valid, 0 if invalid
; Registers: Preserves original string address in EBX
validate_date_format:
    push ebx
    push ecx
    push edx

    mov ebx, eax        ; Save string address

    ; Check string length (should be 10 characters)
    mov ecx, 0
.length_loop:
    cmp byte [ebx+ecx], NULL
    je .check_length
    inc ecx
    cmp ecx, 11         ; Maximum length plus null
    jge .invalid
    jmp .length_loop

.check_length:
    cmp ecx, 10         ; Should be exactly 10 characters (DD/MM/YYYY)
    jne .invalid

    ; Check for slashes at positions 2 and 5
    cmp byte [ebx+2], '/'
    jne .invalid
    cmp byte [ebx+5], '/'
    jne .invalid

    ; Check that all other positions are digits
    ; Check day
    mov al, [ebx]
    call is_digit
    cmp eax, 0
    je .invalid

    mov al, [ebx+1]
    call is_digit
    cmp eax, 0
    je .invalid

    ; Check month
    mov al, [ebx+3]
    call is_digit
    cmp eax, 0
    je .invalid

    mov al, [ebx+4]
    call is_digit
    cmp eax, 0
    je .invalid

    ; Check year
    mov al, [ebx+6]
    call is_digit
    cmp eax, 0
    je .invalid

    mov al, [ebx+7]
    call is_digit
    cmp eax, 0
    je .invalid

    mov al, [ebx+8]
    call is_digit
    cmp eax, 0
    je .invalid

    mov al, [ebx+9]
    call is_digit
    cmp eax, 0
    je .invalid

    ; Valid date format
    mov eax, 1
    jmp .done

.invalid:
    mov eax, 0

.done:
    pop edx
    pop ecx
    pop ebx
    ret

; Function: is_digit
; Purpose: Check if a character is a digit (0-9)
; Input: AL = character to check
; Output: EAX = 1 if digit, 0 if not
is_digit:
    cmp al, '0'
    jl .not_digit
    cmp al, '9'
    jg .not_digit
    mov eax, 1
    ret

.not_digit:
    mov eax, 0
    ret
