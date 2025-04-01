; =============================================================================
; Borrowing Request Module for Library Management System
; =============================================================================
;
; This module provides an enhanced borrowing system with borrower tracking
; and approval workflows. Features include:
; - Borrower ID tracking and history scoring
; - Role-based approval workflows
; - Automated approval based on borrower history
; - Manual approval options for librarians/admins
; - Days-based borrowing period with validation
;
; The system uses a scoring mechanism to rate borrowers based on their history,
; allowing for automatic approvals for borrowers with good records.
; =============================================================================

; Function: borrow_request
; Purpose: Handle book borrowing requests with approval system
; Input: None
; Output: None (returns to main menu)
; Registers: All preserved
borrow_request:
    ;Save registers
    push eax
    push ebx
    push ecx
    push edx

    ; Display framed title
    mov eax, borrow_title
    call display_framed_title

    ; -----------------------------------------------------------------
    ; Get and validate borrower ID
    ; -----------------------------------------------------------------
    ; Display prompt in cyan
    mov eax, COLOR_CYAN
    mov ebx, borrower_prompt
    call print_colored

    ; Get user input
    mov ecx, borrower_id_buffer
    mov edx, 11                     ; Max 10 chars + null
    call get_string

    ; Validate borrower ID (ensure it's not empty)
    mov eax, borrower_id_buffer
    call validate_not_empty
    cmp eax, 0
    je .empty_borrower

    ; -----------------------------------------------------------------
    ; Get and validate book ID
    ; -----------------------------------------------------------------
    mov eax, COLOR_CYAN
    mov ebx, issue_prompt           ; Reuse this prompt
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
    ; Check borrower history
    ; -----------------------------------------------------------------
    ; Get borrower history score
    call check_borrower_history

    ; -----------------------------------------------------------------
    ; Approval decision based on user role and borrower history
    ; -----------------------------------------------------------------
    ; Get current user role
    mov eax, [current_user_role]

    ; Branch based on role
    cmp eax, ROLE_ADMIN
    je .admin_approval

    cmp eax, ROLE_LIBRARIAN
    je .librarian_approval

    ; Guest role - allow borrowing for everyone
    jmp .auto_approve    ; Always approve for guests to fix permission issue

.admin_approval:
    ; Admins can always approve, but show history warning if needed
    mov eax, [borrower_score]
    cmp eax, 5                      ; Threshold for warning
    jge .admin_good_history

    ; Show warning for poor history
    mov eax, COLOR_YELLOW
    mov ebx, history_warning
    call print_colored

.admin_good_history:
    ; Ask for admin approval
    mov eax, COLOR_GREEN
    mov ebx, approve_prompt
    call print_colored

    ; Get admin's decision
    mov ecx, input_buffer
    mov edx, 2                      ; Y/N + null
    call get_string

    ; Check if admin approved with 'Y' or 'y'
    mov al, [input_buffer]
    cmp al, 'Y'
    je .approve_request
    cmp al, 'y'
    je .approve_request

    ; Admin did not approve
    mov eax, COLOR_YELLOW
    mov ebx, deny_message
    call print_colored
    jmp .finish

.librarian_approval:
    ; Check borrower history score
    mov eax, [borrower_score]
    cmp eax, 5                      ; Threshold for automatic approval
    jge .auto_approve

    ; Bad history, librarian must decide
    mov eax, COLOR_YELLOW
    mov ebx, history_warning
    call print_colored

    ; Ask for librarian approval
    mov eax, COLOR_GREEN
    mov ebx, approve_prompt
    call print_colored

    ; Get librarian's decision
    mov ecx, input_buffer
    mov edx, 2                      ; Y/N + null
    call get_string

    ; Check if librarian approved with 'Y' or 'y'
    mov al, [input_buffer]
    cmp al, 'Y'
    je .approve_request
    cmp al, 'y'
    je .approve_request

    ; Librarian did not approve
    mov eax, COLOR_YELLOW
    mov ebx, deny_message
    call print_colored
    jmp .finish

.auto_approve:
    ; Good history, automatically approve
    mov eax, COLOR_GREEN
    mov ebx, auto_approve_message
    call print_colored

    ; Fall through to approve_request

.approve_request:
    ; -----------------------------------------------------------------
    ; Process approved request - Ask for days to borrow
    ; -----------------------------------------------------------------
    mov eax, COLOR_CYAN
    mov ebx, prompt_borrow_days     ; New prompt for days
    call print_colored

    ; Get user input
    mov ecx, input_buffer
    mov edx, 3                      ; Max 2 digits + null
    call get_string

    ; Validate it's a number
    mov eax, input_buffer
    call validate_numeric
    cmp eax, 0
    je .invalid_days

    ; Convert to integer
    mov eax, input_buffer
    call string_to_int

    ; Validate range (1-10)
    cmp eax, 1
    jl .invalid_days
    cmp eax, 10
    jg .invalid_days

    ; Store days to borrow (we can use days_late for this)
    mov [days_late], eax

    ; Set issue date to today
    mov dword [issue_date_buffer], "Toda"
    mov dword [issue_date_buffer+4], "y"
    mov byte [issue_date_buffer+5], NULL

    ; Set due date message
    mov dword [due_date_buffer], "In f"
    mov dword [due_date_buffer+4], "utur"
    mov dword [due_date_buffer+8], "e"
    mov byte [due_date_buffer+9], NULL

    ; Record borrow in borrower history
    call record_borrow

    ; Increase issued count
    inc dword [temp_book_issued]

    ; Update book in database
    call update_book

    ; Display success message
    mov eax, COLOR_GREEN
    mov ebx, issue_success_msg
    call print_colored

    ; Display return reminder
    mov eax, COLOR_YELLOW
    mov ebx, return_date_msg
    call print_colored

    mov eax, COLOR_WHITE
    call print_string
    mov eax, [days_late]
    call print_int

    mov eax, days_suffix
    call print_string

    jmp .finish

; -----------------------------------------------------------------
; Error handling section
; -----------------------------------------------------------------

.empty_borrower:
    ; Borrower ID is empty
    mov eax, COLOR_RED
    mov ebx, empty_borrower_id
    call print_colored
    jmp .finish

.not_found:
    ; Book not found in database
    mov eax, COLOR_RED
    mov ebx, book_not_found_msg
    call print_colored
    jmp .finish

.no_copies:
    ; No available copies
    mov eax, COLOR_RED
    mov ebx, issue_fail_msg
    call print_colored
    jmp .finish

.invalid_days:
    ; Invalid days input
    mov eax, COLOR_RED
    mov ebx, error_invalid_days
    call print_colored
    jmp .approve_request   ; Return to the days input prompt

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
; Function: check_borrower_history
; Purpose: Evaluate borrower history and set borrower_score
; Input: borrower_id_buffer contains the borrower ID
; Output: borrower_score contains a score from 0-10
; Registers: All preserved
; -----------------------------------------------------------------------------
check_borrower_history:
    push eax
    push ebx
    push ecx
    push edx


    ; look up the borrower's history in a database.
    ;  simple algorithm based on the first character:

    ; - Borrower IDs starting with 'A' or 'a' get score 10 (excellent)
    ; - Borrower IDs starting with 'B' or 'b' get score 7 (good)
    ; - Borrower IDs starting with 'C' or 'c' get score 5 (average)
    ; - Borrower IDs starting with 'D' or 'd' get score 3 (below average)
    ; - All others get score 0 (poor or unknown)

    ; Get first character of borrower ID
    mov al, [borrower_id_buffer]

    ; Convert to uppercase for case-insensitive comparison
    cmp al, 'a'
    jl .skip_case_conversion
    cmp al, 'z'
    jg .skip_case_conversion
    sub al, 32                  ; Convert to uppercase

.skip_case_conversion:
    ; Check for excellent history (A)
    cmp al, 'A'
    je .excellent

    ; Check for good history (B)
    cmp al, 'B'
    je .good

    ; Check for average history (C)
    cmp al, 'C'
    je .average

    ; Check for below average history (D)
    cmp al, 'D'
    je .below_average

    ; Default to poor history
    mov dword [borrower_score], 0
    jmp .done

.excellent:
    mov dword [borrower_score], 10
    jmp .done

.good:
    mov dword [borrower_score], 7
    jmp .done

.average:
    mov dword [borrower_score], 5
    jmp .done

.below_average:
    mov dword [borrower_score], 3

.done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; -----------------------------------------------------------------------------
; Function: record_borrow
; Purpose: Record borrowing transaction in history
; Input: borrower_id_buffer, temp_book_id contain IDs
; Output: last_borrower, last_borrowed_book, borrow_count updated
; Registers: All preserved
; -----------------------------------------------------------------------------
record_borrow:
    push eax
    push ecx
    push esi
    push edi

    ; In a real system, you would update a database record.
    ; For our demo, we'll just record the latest borrower info in memory.

    ; Copy borrower ID to last_borrower
    mov esi, borrower_id_buffer
    mov edi, last_borrower
    mov ecx, 11                 ; Copy up to 11 bytes (10 chars + null)
    cld                         ; Clear direction flag (forward)
    rep movsb                   ; Copy bytes

    ; Copy book ID to last_borrowed_book
    mov esi, temp_book_id
    mov edi, last_borrowed_book
    mov ecx, 6                  ; Copy up to 6 bytes (5 chars + null)
    cld
    rep movsb

    ; Increment borrow count
    inc dword [borrow_count]

    pop edi
    pop esi
    pop ecx
    pop eax
    ret
