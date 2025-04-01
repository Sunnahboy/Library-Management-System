; =============================================================================
; Book Search Module for Library Management System
; =============================================================================
;
; This module handles searching for books in the library database by ID.
; It provides a user interface for entering search criteria and displays
; detailed information about the found book.
;
; The module implements:
; - User interface for entering search criteria
; - Book lookup in the database
; - Detailed display of found book information
; - Error handling for book not found condition
; =============================================================================

; Function: search_book
; Purpose: Search for a book by ID and display its details
; Input: None
; Output: None (returns to main menu)
; Registers: All preserved
search_book:
    ; Save registers we'll use
    push eax
    push ebx
    push ecx
    push edx

    ; Clear the screen for a clean display
    call clear_screen

    ; Display framed title
    mov eax, search_title
    call display_framed_title

    ; -----------------------------------------------------------------
    ; Get book ID to search
    ; -----------------------------------------------------------------
    ; Display prompt in cyan
    mov eax, COLOR_CYAN
    mov ebx, search_prompt
    call print_colored

    ; Get user input
    mov ecx, temp_book_id
    mov edx, 6                  ; Max 5 digits + null
    call get_string

    ; Validate book ID format (ensure it's not empty)
    mov eax, temp_book_id
    call validate_not_empty
    cmp eax, 0
    je .not_found               ; Treat empty input as not found

    ; -----------------------------------------------------------------
    ; Search for the book in database
    ; -----------------------------------------------------------------
    ; Call the find_book function
    call find_book

    ; Check if book was found
    cmp dword [search_result], ERR_NOT_FOUND
    je .not_found

    ; -----------------------------------------------------------------
    ; Display book details if found
    ; -----------------------------------------------------------------
    ; Display success message in green
    mov eax, COLOR_GREEN
    mov ebx, book_found_msg
    call print_colored

    ; Load book details from database
    call load_book

    ; Display detailed book information
    call display_book_details

    ; Jump to finish section
    jmp .finish

.not_found:
    ; Display not found message in red
    mov eax, COLOR_RED
    mov ebx, book_not_found_msg
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


; =============================================================================
; Title/Author Search Extension
; =============================================================================
;
; Function: search_by_title_author
; Purpose: Search for books by title or author
; Input: None
; Output: None (returns to main menu)
; Registers: All preserved
search_by_title_author:
    ; Save registers we'll use
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Clear the screen
    call clear_screen

    ; Display framed title
    mov eax, search_title_author
    call display_framed_title

    ; Ask user if they want to search by title or author
    mov eax, COLOR_CYAN
    mov dword [temp_buffer], "Sear"
    mov dword [temp_buffer+4], "ch b"
    mov dword [temp_buffer+8], "y (T"
    mov dword [temp_buffer+12], ")itl"
    mov dword [temp_buffer+16], "e or"
    mov dword [temp_buffer+20], " (A)"
    mov dword [temp_buffer+24], "utho"
    mov dword [temp_buffer+28], "r? ["
    mov dword [temp_buffer+32], "T/A]"
    mov dword [temp_buffer+36], ": "
    mov byte [temp_buffer+38], NULL
    mov ebx, temp_buffer
    call print_colored
; Fix for search_by_title_author function in book_search.asm:

    ; Get user choice
    mov ecx, input_buffer
    mov edx, 2                      ; Just T/A + null
    call get_string

    ; Check if input is empty or "back"
    cmp byte [input_buffer], 0
    je .return_to_menu              ; Empty input, go back

    ; Check first character for 'b' (back)
    mov al, [input_buffer]
    cmp al, 'b'
    je .return_to_menu
    cmp al, 'B'
    je .return_to_menu

    ; Check for search by author (anything else defaults to title)
    cmp al, 'A'
    je .search_by_author
    cmp al, 'a'
    je .search_by_author

    ; Not A/a, default to title search
    ; Search by title (default option)
    mov eax, COLOR_CYAN
    mov ebx, title_search_prompt
    call print_colored

    ; Get search term
    mov ecx, temp_buffer
    mov edx, 51                     ; Max 50 chars + null
    call get_string

    ; Check if search term is empty
    mov eax, temp_buffer
    call validate_not_empty
    cmp eax, 0
    je .empty_search

    ; Set search mode to title
    mov dword [search_mode], 0      ; 0 = search by title
    jmp .perform_search


.search_by_author:
    ; Search by author
    mov eax, COLOR_CYAN
    mov ebx, author_search_prompt
    call print_colored

    ; Get search term
    mov ecx, temp_buffer
    mov edx, 31                     ; Max 30 chars + null
    call get_string

    ; Check if search term is empty
    mov eax, temp_buffer
    call validate_not_empty
    cmp eax, 0
    je .empty_search

    ; Set search mode to author
    mov dword [search_mode], 1      ; 1 = search by author

.perform_search:
    ; Initialize match counter
    mov dword [match_count], 0

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

    ; Print separator again
    mov eax, COLOR_CYAN
    mov ebx, table_header_border
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; -----------------------------------------------------------------
    ; Search through all books and display matches
    ; -----------------------------------------------------------------
    mov ecx, 0                  ; Book index counter

.search_loop:
    ; Check if we've searched all books
    cmp ecx, [book_count]
    jge .end_search

    ; Load book data
    push ecx
    mov [search_result], ecx
    call load_book

    ; Check if this book matches search criteria
    call check_search_match
    cmp eax, 0
    je .next_book

    ; Book matches search criteria
    inc dword [match_count]

    ; Display book details
    call display_book_row

.next_book:
    ; Move to next book
    pop ecx
    inc ecx
    jmp .search_loop

.end_search:
    ; Print closing separator
    mov eax, COLOR_CYAN
    mov ebx, table_header_border
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; Check if any matches were found
    mov eax, [match_count]
    test eax, eax
    jz .no_matches

    ; Display match count
    mov eax, COLOR_GREEN
    mov dword [temp_buffer], "Foun"
    mov dword [temp_buffer+4], "d "
    mov byte [temp_buffer+8], NULL
    mov ebx, temp_buffer
    call print_colored

    mov eax, COLOR_WHITE
    call print_string
    mov eax, [match_count]
    call print_int

    mov eax, COLOR_WHITE
    mov dword [temp_buffer], " mat"
    mov dword [temp_buffer+4], "ches"
    mov byte [temp_buffer+8], NULL
    mov ebx, temp_buffer
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string

    jmp .finish

.empty_search:
    ; Handle empty search term
    mov eax, COLOR_YELLOW
    mov dword [temp_buffer], "Plea"
    mov dword [temp_buffer+4], "se e"
    mov dword [temp_buffer+8], "nter"
    mov dword [temp_buffer+12], " a s"
    mov dword [temp_buffer+16], "earc"
    mov dword [temp_buffer+20], "h te"
    mov dword [temp_buffer+24], "rm."
    mov byte [temp_buffer+28], LF
    mov byte [temp_buffer+29], NULL
    mov ebx, temp_buffer
    call print_colored

    ; Brief delay
    mov ecx, 200000
.delay_loop:
    loop .delay_loop

    ; Return to search
    jmp search_by_title_author

.no_matches:
    ; No matches found
    mov eax, COLOR_YELLOW
    mov ebx, no_matches_found
    call print_colored

.finish:
    ; Wait for user input
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

; Function: check_search_match
; Purpose: Check if current book matches search criteria
; Input: temp_book_* variables, temp_buffer contains search term, [search_mode] 0=title/1=author
; Output: EAX = 1 if match, 0 if no match
; Registers: Preserves all except EAX

check_search_match:
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Choose what field to search based on search_mode
    mov eax, [search_mode]
    cmp eax, 0
    je .search_title

    ; Search author
    mov esi, temp_book_author
    jmp .perform_match

.search_title:
    ; Search title
    mov esi, temp_book_title

.perform_match:
    ; Simplified partial string match algorithm
    ; Convert search term to lowercase
    mov edi, temp_buffer

    ; Initialize match flag
    xor edx, edx         ; EDX = 0 (no match yet)

.match_loop:
    ; Check if we've reached end of book title/author
    cmp byte [esi], NULL
    je .match_end

    ; Start substring match from current position
    push esi
    push edi

    ; Substring comparison loop
    mov ecx, 0
.substr_loop:
    ; Get characters from both strings
    mov al, [edi+ecx]

    ; Check if we reached end of search term (match completed)
    cmp al, NULL
    je .match_found

    ; Get corresponding character from book
    mov bl, [esi+ecx]

    ; Check if we reached end of book string (no match)
    cmp bl, NULL
    je .no_substr_match

    ; Convert both to lowercase for case-insensitive comparison
    cmp al, 'A'
    jl .skip_case1
    cmp al, 'Z'
    jg .skip_case1
    add al, 32          ; Convert to lowercase
.skip_case1:

    cmp bl, 'A'
    jl .skip_case2
    cmp bl, 'Z'
    jg .skip_case2
    add bl, 32          ; Convert to lowercase
.skip_case2:

    ; Compare characters
    cmp al, bl
    jne .no_substr_match

    ; Characters match, continue with next
    inc ecx
    jmp .substr_loop

.match_found:
    ; Match found, set flag
    mov edx, 1

.no_substr_match:
    ; Restore string positions
    pop edi
    pop esi

    ; Check if we found a match
    test edx, edx
    jnz .match_end

    ; Move to next character in book string
    inc esi
    jmp .match_loop

.match_end:
    ; Return result
    mov eax, edx

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
