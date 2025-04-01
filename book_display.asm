; =============================================================================
; Book Display Module for Library Management System
; =============================================================================
;
; This module handles the display of book information, both for individual
; books and for listing all books in the library.
;
; The module implements:
; - Formatted tabular display of book information
; - Color-coded availability indicators
; - Truncation of long text fields to maintain alignment
; - Empty library handling
; =============================================================================

; Function: display_books
; Purpose: Display all books in the library in a tabular format
; Input: None
; Output: None (returns to main menu)
; Registers: All preserved
display_books:
    ; Save all registers we use
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Display framed title
    mov eax, welcome_msg
    call display_framed_title

    ; Check if there are any books in the library
    mov eax, [book_count]
    test eax, eax
    jz .no_books

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
    ; Loop through all books and display them
    ; -----------------------------------------------------------------
    mov ecx, 0          ; Book index counter

.display_loop:
    ; Load book at index ECX
    push ecx
    mov [search_result], ecx
    call load_book

    ; Display book details
    call display_book_row

    ; Move to next book
    pop ecx
    inc ecx
    cmp ecx, [book_count]
    jl .display_loop

    ; -----------------------------------------------------------------
    ; Print final separator
    ; -----------------------------------------------------------------
    mov eax, COLOR_CYAN
    mov ebx, table_header_border
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string

    jmp .finish

.no_books:
    ; Display message that there are no books
    mov eax, COLOR_YELLOW
    mov ebx, book_not_found_msg
    call print_colored

.finish:
    ; Wait for user to press Enter before returning to menu
    mov eax, COLOR_WHITE
    mov ebx, press_any_key
    call print_colored
    call wait_for_enter

   ; Restore registers
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax

    ; Return to main menu
    jmp main_loop

; Function: display_book_row
; Purpose: Display a single book as a formatted table row
; Input: temp_book_* variables contain book data
; Output: None
; Registers: All preserved
display_book_row:
    ; Save all registers we'll use
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; -----------------------------------------------------------------
    ; Display Book ID Column
    ; -----------------------------------------------------------------
    ; Start data row with pipe
    mov eax, COLOR_WHITE
    mov ebx, table_separator_pipe
    call print_colored

    ; Display book ID
    mov eax, COLOR_GREEN
    mov ebx, temp_book_id
    call print_colored

    ; Calculate padding needed for ID column
    xor ecx, ecx              ; Clear counter
    mov esi, temp_book_id     ; Set source for length calculation

.id_length_loop:
    cmp byte [esi + ecx], NULL
    je .id_padding
    inc ecx
    jmp .id_length_loop

.id_padding:
    ; Calculate spaces needed: column width - string length - 2 (for "| ")
    mov eax, ID_COL_WIDTH
    sub eax, ecx
    sub eax, 2

    ; Handle underflow (just in case)
    cmp eax, 0
    jge .id_padding_ok
    xor eax, eax

.id_padding_ok:
    ; Print padding spaces
    call print_spaces

    ; -----------------------------------------------------------------
    ; Display Title Column
    ; -----------------------------------------------------------------
    ; Display separator
    mov eax, COLOR_WHITE
    mov ebx, table_separator_pipe
    call print_colored

    ; Copy title to temp buffer (with potential truncation)
    mov esi, temp_book_title      ; Source
    mov edi, temp_buffer          ; Destination
    mov ecx, 0                    ; Counter

.title_copy_loop:
    ; Check for end of string or max length
    cmp byte [esi + ecx], NULL
    je .title_copy_done
    cmp ecx, 28                   ; Maximum visible title length
    jge .title_truncate

    ; Copy character
    mov al, [esi + ecx]
    mov [edi + ecx], al
    inc ecx
    jmp .title_copy_loop

.title_truncate:
    ; Add ellipsis for truncated titles
    mov byte [edi + ecx - 2], '.'
    mov byte [edi + ecx - 1], '.'
    mov byte [edi + ecx], NULL
    jmp .title_display

.title_copy_done:
    ; Null-terminate the string
    mov byte [edi + ecx], NULL

.title_display:
    ; Display title
    mov eax, COLOR_YELLOW
    mov ebx, temp_buffer
    call print_colored

    ; Calculate padding needed
    mov eax, TITLE_COL_WIDTH
    sub eax, ecx
    sub eax, 2                ; Subtract 2 for "| "

    ; Handle underflow
    cmp eax, 0
    jge .title_padding_ok
    xor eax, eax

.title_padding_ok:
    ; Print padding spaces
    call print_spaces

    ; -----------------------------------------------------------------
    ; Display Author Column
    ; -----------------------------------------------------------------
    ; Display separator
    mov eax, COLOR_WHITE
    mov ebx, table_separator_pipe
    call print_colored

    ; Copy author to temp buffer (with potential truncation)
    mov esi, temp_book_author      ; Source
    mov edi, temp_buffer           ; Destination
    mov ecx, 0                     ; Counter

.author_copy_loop:
    ; Check for end of string or max length
    cmp byte [esi + ecx], NULL
    je .author_copy_done
    cmp ecx, 18                   ; Maximum visible author length
    jge .author_truncate

    ; Copy character
    mov al, [esi + ecx]
    mov [edi + ecx], al
    inc ecx
    jmp .author_copy_loop

.author_truncate:
    ; Add ellipsis for truncated authors
    mov byte [edi + ecx - 2], '.'
    mov byte [edi + ecx - 1], '.'
    mov byte [edi + ecx], NULL
    jmp .author_display

.author_copy_done:
    ; Null-terminate the string
    mov byte [edi + ecx], NULL

.author_display:
    ; Display author
    mov eax, COLOR_CYAN
    mov ebx, temp_buffer
    call print_colored

    ; Calculate padding needed
    mov eax, AUTHOR_COL_WIDTH
    sub eax, ecx
    sub eax, 2               ; Subtract 2 for "| "

    ; Handle underflow
    cmp eax, 0
    jge .author_padding_ok
    xor eax, eax

.author_padding_ok:
    ; Print padding spaces
    call print_spaces

; Improved availability display section with better handling for multi-digit numbers

    ; -----------------------------------------------------------------
    ; Display Availability Column
    ; -----------------------------------------------------------------
    ; Display separator
    mov eax, COLOR_WHITE
    mov ebx, table_separator_pipe
    call print_colored

    ; Calculate availability
    mov eax, [temp_book_quantity]  ; Total copies
    mov ebx, [temp_book_issued]    ; Issued copies
    sub eax, ebx                   ; Available copies = total - issued

    ; Store available count for later use
    push eax   ; IMPORTANT: Save on stack

    ; Choose color based on availability
    cmp eax, 0
    je .out_of_stock              ; No copies available

    cmp eax, [temp_book_quantity]
    je .fully_available           ; All copies available

    cmp eax, 3
    jl .limited_availability      ; Few copies left

    ; Enough copies - use green
    mov eax, COLOR_GREEN
    jmp .display_color

.out_of_stock:
    ; No copies - use red
    mov eax, COLOR_RED
    jmp .display_color

.limited_availability:
    ; Limited copies - use yellow
    mov eax, COLOR_YELLOW
    jmp .display_color

.fully_available:
    ; All copies available - use green
    mov eax, COLOR_GREEN

.display_color:
    ; Apply color
    call print_string

    ; Display status text based on availability
    pop eax                        ; Get available count
    push eax                       ; Save it again

    cmp eax, 0
    je .display_out

    cmp eax, [temp_book_quantity]
    je .display_all

    ; Display "LTD"
    mov eax, "LTD"
    push eax
    mov eax, esp
    call print_string
    add esp, 4
    jmp .after_status

.display_out:
    ; Display "OUT"
    mov eax, "OUT"
    push eax
    mov eax, esp
    call print_string
    add esp, 4
    jmp .after_status

.display_all:
    ; Display "ALL"
    mov eax, "ALL"
    push eax
    mov eax, esp
    call print_string
    add esp, 4

.after_status:
    ; Print a space
    mov eax, ' '
    push eax
    mov eax, esp
    call print_char
    add esp, 4

    ; Print the count directly
    pop eax                        ; Get available count
    call print_int                 ; Use our fixed print_int function

    ; Reset color
    mov eax, COLOR_RESET
    call print_string

    ; Add padding for alignment
    mov eax, AVAIL_COL_WIDTH
    sub eax, 5                     ; Approx length of status (eg "ALL 10")
    sub eax, 2                     ; "| "

    ; Ensure non-negative
    cmp eax, 0
    jg .pad_ok
    mov eax, 0

.pad_ok:
    call print_spaces



    ; -----------------------------------------------------------------
    ; Display Category Column
    ; -----------------------------------------------------------------
    ; Display separator
    mov eax, COLOR_WHITE
    mov ebx, table_separator_pipe
    call print_colored

    ; Get category name
    mov eax, [temp_book_category]
    call get_category_name

    ; Display category with color
    push eax             ; Save category name
    mov ebx, eax
    mov eax, COLOR_MAGENTA
    call print_colored
    pop eax              ; Restore category name

    ; Calculate category name length
    xor ecx, ecx
    mov esi, eax

.cat_length_loop:
    cmp byte [esi + ecx], NULL
    je .cat_padding
    inc ecx
    jmp .cat_length_loop

.cat_padding:
    ; Calculate padding needed
    mov eax, CATEGORY_COL_WIDTH
    sub eax, ecx
    sub eax, 2               ; Subtract 2 for "| "

    ; Handle underflow
    cmp eax, 0
    jge .cat_padding_ok
    xor eax, eax

.cat_padding_ok:
    ; Print padding spaces
    call print_spaces

    ; -----------------------------------------------------------------
    ; Finish Row
    ; -----------------------------------------------------------------
    ; Display closing pipe
    mov eax, COLOR_WHITE
    mov ebx, table_pipe
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; Restore registers
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
