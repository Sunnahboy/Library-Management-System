; =============================================================================
; Library Management System - Main Program
; =============================================================================
;
; This is the main entry point for the Library Management System.
; It implements:
; - System initialization
; - User authentication via login system
; - Role-based menu navigation
; - Proper program exit
;
; The system supports three user roles:
; - Administrator (full access)
; - Librarian (operational access)
; - Guest (limited access)
;
; Each role has a dedicated menu with appropriate permissions.
; =============================================================================

; Include core system files
%include "constants.asm"   ; Include constants and definitions
%include "data.asm"        ; Include initialized data section

section .bss
    ; Include uninitialized data section
    %include "bss.asm"

section .text
    global _start

    ; Include utility functions
    %include "utility.asm"

; =============================================================================
; Program Entry Point
; =============================================================================
_start:
    ; Initialize system data
    call initialize_system_data

    ; Start with login flow
    jmp login_entry

; =============================================================================
; System Initialization
; =============================================================================
initialize_system_data:
    ; Save registers we'll use
    push eax
    push ecx
    push edi

    ; Initialize book counter to zero
    mov dword [book_count], 0

    ; Initialize statistics counters
    mov dword [stat_total_books], 0
    mov dword [stat_books_issued], 0
    mov dword [stat_books_available], 0

    ; Initialize category counters (clear 6 dwords starting at stat_by_category)
    mov ecx, 6                  ; Number of categories
    mov edi, stat_by_category   ; Destination address
    xor eax, eax                ; Value to store (zero)
    rep stosd                   ; Repeat store doubleword

    ; Initialize borrower history
    mov dword [borrow_count], 0

    ; Load sample data for testing
    call initialize_sample_data

    ; Restore registers
    pop edi
    pop ecx
    pop eax
    ret

; =============================================================================
; Login System
; =============================================================================
login_entry:
    ; Reset user session data
    mov dword [current_user_role], 0

    ; Call login system
    call login_system

    ; After successful login, display welcome message
    call clear_screen
    mov eax, welcome_msg
    call display_framed_title

    ; Continue to main program loop
    jmp main_loop

; Function: login_system
; Purpose: Handle user authentication
; Input: None
; Output: [current_user_role] set based on credentials
; Registers: All preserved
login_system:
    ; Save registers we'll use
    push eax
    push ebx
    push ecx
    push edx

    ; Clear screen for login interface
    call clear_screen

    ; Display login title
    mov eax, login_title
    call display_framed_title

    ; -----------------------------------------------------------------
    ; Get username
    ; -----------------------------------------------------------------
    mov eax, COLOR_CYAN
    mov ebx, username_prompt
    call print_colored

    ; Get user input
    mov ecx, username_buffer
    mov edx, 20                 ; Max 19 chars + null
    call get_string

    ; -----------------------------------------------------------------
    ; Get password
    ; -----------------------------------------------------------------
    mov eax, COLOR_CYAN
    mov ebx, password_prompt
    call print_colored

    ; Get user input
    mov ecx, password_buffer
    mov edx, 20                 ; Max 19 chars + null
    call get_string

    ; -----------------------------------------------------------------
    ; Check admin credentials
    ; -----------------------------------------------------------------
    ; First check username
    mov esi, username_buffer
    mov edi, admin_username
    call string_compare
    test eax, eax
    jz .check_librarian         ; Username doesn't match, try librarian

    ; Check admin password
    mov esi, password_buffer
    mov edi, admin_password
    call string_compare
    test eax, eax
    jz .login_failed            ; Password doesn't match

    ; Admin credentials verified
    mov dword [current_user_role], ROLE_ADMIN
    jmp .login_success

    ; -----------------------------------------------------------------
    ; Check librarian credentials
    ; -----------------------------------------------------------------
.check_librarian:
    ; Check username
    mov esi, username_buffer
    mov edi, librarian_username
    call string_compare
    test eax, eax
    jz .login_as_guest          ; Username doesn't match, login as guest

    ; Check librarian password
    mov esi, password_buffer
    mov edi, librarian_password
    call string_compare
    test eax, eax
    jz .login_failed            ; Password doesn't match

    ; Librarian credentials verified
    mov dword [current_user_role], ROLE_LIBRARIAN
    jmp .login_success

    ; -----------------------------------------------------------------
    ; Login failed handling
    ; -----------------------------------------------------------------
.login_failed:
    ; Display error message in red
    mov eax, COLOR_RED
    mov ebx, login_error
    call print_colored

    ; Wait for user acknowledgment
    mov eax, COLOR_WHITE
    mov ebx, press_any_key
    call print_colored
    call wait_for_enter

    ; Clear screen and retry login
    call clear_screen
    jmp login_system

    ; -----------------------------------------------------------------
    ; Guest login (no credentials required)
    ; -----------------------------------------------------------------
.login_as_guest:
    ; Set guest role
    mov dword [current_user_role], ROLE_GUEST

    ; Display guest role message
    mov eax, COLOR_YELLOW
    mov ebx, guest_role_msg
    call print_colored

    ; Display guest welcome message with system information
    mov eax, COLOR_GREEN
    mov ebx, guest_welcome
    call print_colored

    ; Wait for user acknowledgment
    mov eax, COLOR_WHITE
    mov ebx, press_any_key
    call print_colored
    call wait_for_enter

    ; Clear screen before returning
    call clear_screen

    ; Restore registers and return
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

    ; -----------------------------------------------------------------
    ; Login success handling
    ; -----------------------------------------------------------------
.login_success:
    ; Display success message in green
    mov eax, COLOR_GREEN
    mov ebx, login_success
    call print_colored

    ; Display role message based on role
    mov eax, COLOR_YELLOW
    mov ebx, [current_user_role]

    cmp ebx, ROLE_ADMIN
    jne .check_librarian_role

    ; Admin role message
    mov ebx, admin_role_msg
    jmp .display_role

.check_librarian_role:
    cmp ebx, ROLE_LIBRARIAN
    jne .display_guest_role

    ; Librarian role message
    mov ebx, librarian_role_msg
    jmp .display_role

.display_guest_role:
    ; Guest role message
    mov ebx, guest_role_msg

.display_role:
    ; Display role message
    call print_colored

    ; Wait for user acknowledgment
    mov eax, COLOR_WHITE
    mov ebx, press_any_key
    call print_colored
    call wait_for_enter

    ; Clear screen before returning
    call clear_screen

    ; Restore registers and return
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; =============================================================================
; Main Program Loop
; =============================================================================
main_loop:
    ; Clear screen before showing menu
    call clear_screen

    ; -----------------------------------------------------------------
    ; Display appropriate menu based on user role
    ; -----------------------------------------------------------------
    ; Set color for menu display
    mov eax, COLOR_CYAN

    ; Check user role and branch accordingly
    mov ecx, [current_user_role]

    cmp ecx, ROLE_ADMIN
    je .admin_menu

    cmp ecx, ROLE_LIBRARIAN
    je .librarian_menu

    ; Default to guest menu
    mov ebx, guest_menu_prompt
    call print_colored

    ; -----------------------------------------------------------------
    ; Process guest menu choices (ENHANCED)
    ; -----------------------------------------------------------------
    ; Get user choice
    call get_choice

    ; Branch based on selection
    cmp byte [choice], '1'
    je search_book

    cmp byte [choice], '2'
    je search_by_title_author

    cmp byte [choice], '3'
    je display_books

    cmp byte [choice], '4'
    je borrow_request

    cmp byte [choice], '5'
    je return_book

    cmp byte [choice], '6'
    je view_my_borrowed_books

    cmp byte [choice], '7'
    je browse_by_category

    cmp byte [choice], '8'
    je display_library_info

    ; Check for Help option
    cmp byte [choice], 'H'
    je display_guest_help
    cmp byte [choice], 'h'
    je display_guest_help

    ; Check for login option
    cmp byte [choice], 'L'
    je login_entry
    cmp byte [choice], 'l'
    je login_entry

    ; Check for exit option
    cmp byte [choice], 'X'
    je exit_program
    cmp byte [choice], 'x'
    je exit_program

    ; Invalid choice
    jmp .invalid_choice

; -----------------------------------------------------------------
; Admin Menu Handler
; -----------------------------------------------------------------
.admin_menu:
    ; Display admin menu
    mov ebx, admin_menu_prompt
    call print_colored

    ; Get user choice
    call get_choice

    ; Process admin menu choices
    cmp byte [choice], '1'
    je add_book

    cmp byte [choice], '2'
    je search_book

    cmp byte [choice], '3'
    je issue_book

    cmp byte [choice], '4'
    je return_book

    cmp byte [choice], '5'
    je display_books

    cmp byte [choice], '6'
    je calculate_fines

    cmp byte [choice], '7'
    je display_statistics

    cmp byte [choice], '8'
    je delete_book

    cmp byte [choice], '9'
    je borrow_request

    cmp byte [choice], 'C'
    je view_borrowed_books
    cmp byte [choice], 'c'
    je view_borrowed_books

    cmp byte [choice], 'A'
    je save_data
    cmp byte [choice], 'a'
    je save_data

    cmp byte [choice], 'B'
    je load_data
    cmp byte [choice], 'b'
    je load_data

    ; Check for login option
    cmp byte [choice], 'L'
    je login_entry
    cmp byte [choice], 'l'
    je login_entry

    ; Check for exit option
    cmp byte [choice], 'X'
    je exit_program
    cmp byte [choice], 'x'
    je exit_program

    ; Invalid choice
    jmp .invalid_choice

; -----------------------------------------------------------------
; Librarian Menu Handler
; -----------------------------------------------------------------
.librarian_menu:
    ; Display librarian menu
    mov ebx, librarian_menu_prompt
    call print_colored

    ; Get user choice
    call get_choice

    ; Process librarian menu choices
    cmp byte [choice], '1'
    je search_book

    cmp byte [choice], '2'
    je issue_book

    cmp byte [choice], '3'
    je return_book

    cmp byte [choice], '4'
    je display_books

    cmp byte [choice], '5'
    je calculate_fines

    cmp byte [choice], '6'
    je borrow_request

    cmp byte [choice], '7'
    je view_borrowed_books

    ; Check for login option
    cmp byte [choice], 'L'
    je login_entry
    cmp byte [choice], 'l'
    je login_entry

    ; Check for exit option
    cmp byte [choice], 'X'
    je exit_program
    cmp byte [choice], 'x'
    je exit_program

; -----------------------------------------------------------------
; Invalid Choice Handler
; -----------------------------------------------------------------
.invalid_choice:
    ; Display invalid choice message in red
    mov eax, COLOR_RED
    mov ebx, invalid_choice
    call print_colored

    ; Brief delay before showing menu again
    mov ecx, 300000     ; Reduced delay for better responsiveness
.delay_loop:
    loop .delay_loop

    ; Return to main menu
    jmp main_loop

; =============================================================================
; Program Exit
; =============================================================================
exit_program:
    ; Display goodbye message
    call clear_screen
    mov eax, COLOR_GREEN
    mov ebx, goodbye_msg
    call print_colored

    ; Exit program with status code 0
    mov eax, 1          ; system call for exit
    xor ebx, ebx        ; exit code 0
    int 80h             ; make kernel call

; =============================================================================
; Include all function modules
; =============================================================================
%include "book_add.asm"
%include "book_search.asm"
%include "book_display.asm"
%include "book_issue.asm"
%include "book_return.asm"
%include "fines.asm"
%include "statistics.asm"
%include "delete_book.asm"
%include "borrow_request.asm"
%include "file_io.asm"
%include "borrowed_books.asm"
