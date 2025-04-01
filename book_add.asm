; =============================================================================
; Book Addition Module for Library Management System
; =============================================================================
;
; This module handles the addition of new books to the library database.
; It provides comprehensive validation of all input fields and ensures
; data integrity by preventing duplicate book IDs.
;
; The module implements:
; - Input collection for all book fields
; - Data validation for each field type
; - Duplicate ID checking
; - User feedback for validation errors
; - Database storage of verified book data
; =============================================================================

; Function: add_book
; Purpose: Handles the addition of a new book to the library
; Input: None
; Output: None (returns to main menu)
; Registers: All preserved
add_book:
    ; Save all registers we modify
    push eax
    push ebx
    push ecx
    push edx

    ; Clear the screen
    call clear_screen

    ; Display framed title
    mov eax, add_book_title
    call display_framed_title

    ; -----------------------------------------------------------------
    ; Get and validate Book ID
    ; -----------------------------------------------------------------
    ; Display prompt in cyan
    mov eax, COLOR_CYAN
    mov ebx, prompt_book_id
    call print_colored

    ; Get user input
    mov ecx, temp_book_id
    mov edx, 6                      ; Max 5 digits + null
    call get_string

    ; Validate book ID format (ensure it's numeric)
    mov eax, temp_book_id
    call validate_numeric
    cmp eax, 0
    je .invalid_id

    ; Check that ID isn't empty
    mov eax, temp_book_id
    call validate_not_empty
    cmp eax, 0
    je .invalid_id

    ; Check if book with this ID already exists
    call find_book
    cmp dword [search_result], -1
    jne .book_exists

    ; -----------------------------------------------------------------
    ; Get and validate Book Title
    ; -----------------------------------------------------------------
    ; Display prompt
    mov eax, COLOR_CYAN
    mov ebx, prompt_book_title
    call print_colored

    ; Get user input
    mov ecx, temp_book_title
    mov edx, 51                     ; Max 50 chars + null
    call get_string

    ; Validate book title (ensure it's not empty)
    mov eax, temp_book_title
    call validate_not_empty
    cmp eax, 0
    je .empty_title

    ; -----------------------------------------------------------------
    ; Get and validate Book Author
    ; -----------------------------------------------------------------
    ; Display prompt
    mov eax, COLOR_CYAN
    mov ebx, prompt_book_author
    call print_colored

    ; Get user input
    mov ecx, temp_book_author
    mov edx, 31                     ; Max 30 chars + null
    call get_string

    ; Validate author (ensure it's not empty)
    mov eax, temp_book_author
    call validate_not_empty
    cmp eax, 0
    je .empty_author

    ; -----------------------------------------------------------------
    ; Get and validate Book Category
    ; -----------------------------------------------------------------
    ; Display category options
    mov eax, COLOR_MAGENTA
    mov ebx, prompt_book_category
    call print_colored

    ; Get category choice
    mov ecx, input_buffer
    mov edx, 2                      ; Max 1 digit + null
    call get_string

    ; Validate category input is numeric
    mov eax, input_buffer
    call validate_numeric
    cmp eax, 0
    je .invalid_category

    ; Convert to integer
    mov eax, input_buffer
    call string_to_int

    ; Validate category range (1-5)
    cmp eax, 1
    jl .invalid_category
    cmp eax, 5
    jg .invalid_category

    ; Store category
    mov [temp_book_category], eax

    ; -----------------------------------------------------------------
    ; Get and validate Book Quantity
    ; -----------------------------------------------------------------
    ; Display prompt
    mov eax, COLOR_CYAN
    mov ebx, prompt_book_quantity
    call print_colored

    ; Get user input
    mov ecx, input_buffer
    mov edx, 8                      ; Reasonable length for quantity
    call get_string

    ; Validate quantity (ensure it's numeric)
    mov eax, input_buffer
    call validate_numeric
    cmp eax, 0

    je .invalid_quantity
    ; Convert to integer
    mov eax, input_buffer
    call string_to_int

    ; Validate quantity is reasonable (positive and not too large)
    cmp eax, 0
    jle .negative_quantity
    cmp eax, 10000                  ; Arbitrary upper limit for sanity check
    jg .invalid_quantity

    ; Store quantity
    mov [temp_book_quantity], eax

    ; Set issued books to 0 (new book)
    mov dword [temp_book_issued], 0

    ; -----------------------------------------------------------------
    ; Add book to database and show success message
    ; -----------------------------------------------------------------
    ; Store book in database
    call store_book

    ; Display success message in green
    mov eax, COLOR_GREEN
    mov ebx, book_added_msg
    call print_colored

    ; Wait for user to press Enter before returning to menu
    mov eax, COLOR_WHITE
    mov ebx, press_any_key
    call print_colored
    call wait_for_enter

    ; Return to main menu
    jmp .done

; -----------------------------------------------------------------
; Error handling section
; -----------------------------------------------------------------

.invalid_id:
    ; Book ID validation failed
    mov eax, COLOR_RED
    mov ebx, error_invalid_id
    call print_colored

    ; Wait for user acknowledgment
    mov eax, COLOR_WHITE
    mov ebx, press_any_key
    call print_colored
    call wait_for_enter

    ; Return to the add book form
    jmp add_book

.book_exists:
    ; Book with this ID already exists
    mov eax, COLOR_RED
    mov ebx, book_exists_msg
    call print_colored

    ; Wait for user acknowledgment
    mov eax, COLOR_WHITE
    mov ebx, press_any_key
    call print_colored
    call wait_for_enter

    ; Return to main menu (different IDs need to be chosen carefully)
    jmp .done

.empty_title:
    ; Book title is empty
    mov eax, COLOR_RED
    mov ebx, error_empty_title
    call print_colored

    ; Wait for user acknowledgment
    mov eax, COLOR_WHITE
    mov ebx, press_any_key
    call print_colored
    call wait_for_enter

    ; Return to the add book form
    jmp add_book

.empty_author:
    ; Book author is empty
    mov eax, COLOR_RED
    mov ebx, error_empty_author
    call print_colored

    ; Wait for user acknowledgment
    mov eax, COLOR_WHITE
    mov ebx, press_any_key
    call print_colored
    call wait_for_enter

    ; Return to the add book form
    jmp add_book

.invalid_category:
    ; Invalid category selection
    mov eax, COLOR_RED
    mov ebx, error_invalid_category
    call print_colored

    ; Wait for user acknowledgment
    mov eax, COLOR_WHITE
    mov ebx, press_any_key
    call print_colored
    call wait_for_enter

    ; Return to the add book form
    jmp add_book

.invalid_quantity:
    ; Invalid quantity input
    mov eax, COLOR_RED
    mov ebx, error_invalid_quantity
    call print_colored

    ; Wait for user acknowledgment
    mov eax, COLOR_WHITE
    mov ebx, press_any_key
    call print_colored
    call wait_for_enter

    ; Return to the add book form
    jmp add_book

.negative_quantity:
    ; Quantity is negative or zero
    mov eax, COLOR_RED
    mov ebx, error_negative_quantity
    call print_colored

    ; Wait for user acknowledgment
    mov eax, COLOR_WHITE
    mov ebx, press_any_key
    call print_colored
    call wait_for_enter

    ; Return to the add book form
    jmp add_book

.done:
    ; Restore all registers and return to main menu
    pop edx
    pop ecx
    pop ebx
    pop eax
    jmp main_loop
