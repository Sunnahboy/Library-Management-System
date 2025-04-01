; =============================================================================
; Fine Calculation Module for Library Management System
; =============================================================================
;
; This module handles the calculation of fines for overdue books.
; Different book categories have different fine rates per day overdue.
;
; The module implements:
; - Book lookup by ID
; - Overdue days input
; - Category-specific fine rate application
; - Formatted display of fine amount in dollars and cents
; - Comprehensive error handling
; =============================================================================

; Function: calculate_fines
; Purpose: Calculate and display fines for overdue books
; Input: None
; Output: None (returns to main menu)
; Registers: All preserved
calculate_fines:
    ; Save registers we'll use
    push eax
    push ebx
    push ecx
    push edx

    ; Display framed title
    mov eax, fine_title
    call display_framed_title

    ; -----------------------------------------------------------------
    ; Get and validate book ID
    ; -----------------------------------------------------------------
    ; Display prompt in cyan
    mov eax, COLOR_CYAN
    mov ebx, fine_prompt
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
    ; Get and validate days overdue
    ; -----------------------------------------------------------------
    ; Display prompt
    mov eax, COLOR_CYAN
    mov ebx, days_prompt
    call print_colored

    ; Get user input
    mov ecx, input_buffer
    mov edx, 8                      ; Reasonable length for days
    call get_string

    ; Validate days input (ensure it's numeric)
    mov eax, input_buffer
    call validate_numeric
    cmp eax, 0
    je .invalid_days

    ; Convert to integer
    mov eax, input_buffer
    call string_to_int

    ; Validate days is reasonable (not negative, not too large)
    cmp eax, 0
    jl .invalid_days
    cmp eax, 1000                   ; Arbitrary upper limit for sanity check
    jg .invalid_days

    ; Store days overdue for calculation
    mov [days_late], eax

    ; -----------------------------------------------------------------
    ; Display days overdue
    ; -----------------------------------------------------------------
    ; Display label in yellow
    mov eax, COLOR_YELLOW
    mov ebx, days_overdue
    call print_colored

    ; Display days value
    mov eax, [days_late]
    call print_int

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; -----------------------------------------------------------------
    ; Display appropriate fine rate based on category
    ; -----------------------------------------------------------------
    ; Get book category
    mov eax, [temp_book_category]

    ; Branch based on category
    cmp eax, CAT_FICTION
    je .fiction_rate

    cmp eax, CAT_NONFICTION
    je .nonfiction_rate

    cmp eax, CAT_REFERENCE
    je .reference_rate

    cmp eax, CAT_TEXTBOOK
    je .textbook_rate

    cmp eax, CAT_MAGAZINE
    je .magazine_rate

    ; Default to fiction rate if category unknown
    jmp .fiction_rate

.fiction_rate:
    ; Display fiction fine rate
    mov eax, COLOR_CYAN
    mov ebx, fine_rate_fiction
    call print_colored

    ; Calculate fine (days * 50 cents)
    mov eax, [days_late]
    mov ebx, FINE_RATE_FICTION
    mul ebx
    mov [fine_amount], eax
    jmp .display_fine

.nonfiction_rate:
    ; Display non-fiction fine rate
    mov eax, COLOR_CYAN
    mov ebx, fine_rate_nonfiction
    call print_colored

    ; Calculate fine (days * 40 cents)
    mov eax, [days_late]
    mov ebx, FINE_RATE_NONFICTION
    mul ebx
    mov [fine_amount], eax
    jmp .display_fine

.reference_rate:
    ; Display reference fine rate
    mov eax, COLOR_CYAN
    mov ebx, fine_rate_reference
    call print_colored

    ; Calculate fine (days * 75 cents)
    mov eax, [days_late]
    mov ebx, FINE_RATE_REFERENCE
    mul ebx
    mov [fine_amount], eax
    jmp .display_fine

.textbook_rate:
    ; Display textbook fine rate
    mov eax, COLOR_CYAN
    mov ebx, fine_rate_textbook
    call print_colored

    ; Calculate fine (days * 60 cents)
    mov eax, [days_late]
    mov ebx, FINE_RATE_TEXTBOOK
    mul ebx
    mov [fine_amount], eax
    jmp .display_fine

.magazine_rate:
    ; Display magazine fine rate
    mov eax, COLOR_CYAN
    mov ebx, fine_rate_magazine
    call print_colored

    ; Calculate fine (days * 30 cents)
    mov eax, [days_late]
    mov ebx, FINE_RATE_MAGAZINE
    mul ebx
    mov [fine_amount], eax

.display_fine:
    ; -----------------------------------------------------------------
    ; Display fine amount in dollars and cents
    ; -----------------------------------------------------------------
    ; Display label in green
    mov eax, COLOR_GREEN
    mov ebx, fine_result
    call print_colored

    ; Calculate dollars and cents
    mov eax, [fine_amount]
    mov ebx, 100
    xor edx, edx
    div ebx             ; EAX = dollars, EDX = cents

    ; Display dollars
    call print_int

    ; Display decimal point
    mov eax, '.'
    push eax
    mov eax, esp
    call print_char
    add esp, 4

    ; Handle cents display with leading zero if needed
    mov eax, edx        ; Get cents value

    ; Check if we need a leading zero
    cmp eax, 10
    jge .print_cents

    ; Print leading zero for cents < 10
    push eax            ; Save cents value
    mov eax, '0'
    push eax
    mov eax, esp
    call print_char
    add esp, 4
    pop eax             ; Restore cents value

.print_cents:
    ; Print cents value
    call print_int

    ; Print newline
    mov eax, LF_STR
    call print_string

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

.invalid_days:
    ; Invalid days input
    mov eax, COLOR_RED
    mov ebx, error_invalid_quantity  ; Reuse this error message
    call print_colored

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
