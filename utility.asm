; =============================================================================
; Utility Functions for Library Management System
; =============================================================================
;
; This file contains a comprehensive suite of utility functions that support
; the library management system operations. It handles:
;   1. I/O Operations: String/char printing, input handling, screen management
;   2. Data Validation: Type checking and input verification
;   3. String Processing: Comparison, conversion between strings and integers
;   4. Book Management: Core functions for book database operations
;   5. UI Elements: Colored output, framed text, and formatted displays
;
; Each function preserves all registers it modifies (except return values)
; and follows consistent calling conventions.
; =============================================================================

; -----------------------------------------------------------------------------
; String Output Functions
; -----------------------------------------------------------------------------

; Function: print_string
; Purpose: Prints a null-terminated string to stdout
; Input: EAX = pointer to string
; Output: None
; Registers: Preserves all
print_string:
    push edx            ; Save registers
    push ecx
    push ebx
    push eax

    ; Calculate string length using common algorithm
    mov ecx, eax        ; Copy string pointer
    mov edx, 0          ; Length counter

.strlen_loop:
    cmp byte [ecx], NULL
    je .print_now
    inc ecx
    inc edx
    jmp .strlen_loop

.print_now:
    ; Don't print if length is zero
    test edx, edx
    jz .done

    ; Print the string using system call
    mov ecx, eax        ; String address
    mov ebx, 1          ; File descriptor (stdout)
    mov eax, 4          ; System call (sys_write)
    int 80h

.done:
    pop eax             ; Restore registers in reverse order
    pop ebx
    pop ecx
    pop edx
    ret

; Function: print_char
; Purpose: Prints a single character to stdout
; Input: EAX = pointer to character
; Output: None
; Registers: Preserves all
print_char:
    push edx
    push ecx
    push ebx
    push eax

    mov edx, 1          ; Length is 1 byte
    mov ecx, eax        ; Address of character
    mov ebx, 1          ; File descriptor (stdout)
    mov eax, 4          ; System call (sys_write)
    int 80h

    pop eax
    pop ebx
    pop ecx
    pop edx
    ret

; Function: print_int
; Purpose: Prints a decimal integer
; Input: EAX = integer value
; Output: None
; Registers: Preserves all
print_int:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Create buffer on stack for number conversion
    sub esp, 16         ; Allocate 16 bytes for number string
    mov edi, esp        ; EDI points to buffer

    ; Save original number
    mov esi, eax

    ; Handle special case for zero
    test eax, eax
    jnz .not_zero

    ; Print "0"
    mov byte [edi], "0"
    mov byte [edi+1], 0
    mov eax, edi
    call print_string
    jmp .cleanup

.not_zero:
    ; Create a string from the number (backwards)
    mov ebx, 10
    xor ecx, ecx        ; Digit count

.convert_loop:
    xor edx, edx        ; Clear for division
    div ebx             ; Divide by 10: quotient in EAX, remainder in EDX
    add dl, "0"         ; Convert to ASCII
    mov [edi+ecx], dl   ; Store in buffer
    inc ecx
    test eax, eax       ; Check if done
    jnz .convert_loop

    ; Now reverse the string
    mov byte [edi+ecx], 0  ; Null-terminate
    dec ecx
    mov esi, 0             ; Start index

.reverse_loop:
    cmp esi, ecx
    jge .done_reverse

    ; Swap characters
    mov al, [edi+esi]
    mov bl, [edi+ecx]
    mov [edi+esi], bl
    mov [edi+ecx], al

    inc esi
    dec ecx
    jmp .reverse_loop

.done_reverse:
    ; Print the reversed string
    mov eax, edi
    call print_string

.cleanup:
    add esp, 16         ; Free buffer

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Function: print_colored
; Purpose: Prints text with ANSI color
; Input: EAX = color code pointer, EBX = string pointer
; Output: None
; Registers: Preserves all
print_colored:
    push eax
    push ebx

    ; Print color code
    call print_string

    ; Print string
    mov eax, ebx
    call print_string

    ; Reset color
    mov eax, COLOR_RESET
    call print_string

    pop ebx
    pop eax
    ret

; Function: clear_screen
; Purpose: Clears the terminal screen
; Input: None
; Output: None
; Registers: Preserves all
clear_screen:
    push eax
    push ebx
    push ecx
    push edx

    ; Use direct system call for efficiency
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, clear_seq  ; ANSI escape sequence
    mov edx, clear_seq_len ; Length
    int 80h

    ; Small delay for screen refresh
    mov ecx, 100000     ; Reduced delay for optimization
.delay_loop:
    loop .delay_loop

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Function: display_framed_title
; Purpose: Displays a title with decorative frame
; Input: EAX = title string pointer
; Output: None
; Registers: Preserves all
display_framed_title:
    push eax
    push ebx
    push ecx
    push edx

    ; Clear screen first
    call clear_screen

    ; Print title with color
    mov ebx, eax        ; Save title pointer
    mov eax, COLOR_YELLOW
    call print_colored

    ; Print double newline for spacing
    mov eax, LF_STR
    call print_string
    call print_string

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; -----------------------------------------------------------------------------
; Input Functions
; -----------------------------------------------------------------------------

; Function: get_choice
; Purpose: Gets a single character choice from user
; Input: None
; Output: Character stored in [choice]
; Registers: Preserves all
get_choice:
    push eax
    push ebx
    push ecx
    push edx

    ; Read user input
    mov eax, 3          ; System call (sys_read)
    mov ebx, 0          ; File descriptor (stdin)
    mov ecx, input_buffer ; Buffer to store input
    mov edx, 16         ; Maximum length
    int 80h

    ; Store first character in choice
    mov al, [input_buffer]
    mov [choice], al

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Function: get_string
; Purpose: Gets string input from user
; Input: ECX = buffer address, EDX = maximum length
; Output: String stored at buffer address
; Registers: Preserves all
get_string:
    push eax
    push ebx
    push esi
    push edi

    ; Save original buffer pointer
    mov esi, ecx

    ; Read user input
    mov eax, 3          ; System call (sys_read)
    mov ebx, 0          ; File descriptor (stdin)
    ; ECX already has buffer address
    ; EDX already has max length
    int 80h

    ; Replace newline with null terminator
    cmp eax, 0          ; Check if any bytes were read
    jle .done

    ; Find and replace newline with null
    mov edi, esi        ; Start from beginning of buffer
    add edi, eax        ; Go to end of input
    dec edi             ; Move to last actual character

    ; Check if last char is newline
    cmp byte [edi], 10  ; ASCII for LF
    jne .skip_newline
    mov byte [edi], NULL

.skip_newline:
    ; If input is exactly max length, ensure null termination
    mov edi, esi
    add edi, edx
    dec edi
    mov byte [edi], NULL

.done:
    pop edi
    pop esi
    pop ebx
    pop eax
    ret

; Function: wait_for_enter
; Purpose: Waits for user to press Enter
; Input: None
; Output: None
; Registers: Preserves all
wait_for_enter:
    push eax
    push ebx
    push ecx
    push edx

    ; Read a character
    mov eax, 3          ; System call (sys_read)
    mov ebx, 0          ; File descriptor (stdin)
    mov ecx, input_buffer
    mov edx, 2          ; Read at most 2 bytes (char + newline)
    int 80h

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; -----------------------------------------------------------------------------
; Validation Functions
; -----------------------------------------------------------------------------

; Function: validate_numeric
; Purpose: Checks if a string contains only digits
; Input: EAX = string address
; Output: EAX = 1 if numeric, 0 if not
; Registers: Preserves original string address in EBX
validate_numeric:
    push ebx
    push ecx
    push edx

    mov ebx, eax        ; Store string address

    ; Check if string is empty
    cmp byte [ebx], NULL
    je .not_numeric

    ; Check each character
    mov ecx, 0
.check_loop:
    mov dl, [ebx+ecx]

    ; Check if end of string
    cmp dl, NULL
    je .numeric

    ; Check if character is a digit
    cmp dl, '0'
    jl .not_numeric
    cmp dl, '9'
    jg .not_numeric

    ; Move to next character
    inc ecx
    jmp .check_loop

.numeric:
    mov eax, 1
    jmp .done

.not_numeric:
    mov eax, 0

.done:
    pop edx
    pop ecx
    pop ebx
    ret

; Function: validate_not_empty
; Purpose: Checks if a string is not empty
; Input: EAX = string address
; Output: EAX = 1 if not empty, 0 if empty
; Registers: Preserves original string address
validate_not_empty:
    push ebx

    mov ebx, eax        ; Store string address

    ; Check if first character is NULL (empty string)
    cmp byte [ebx], NULL
    je .invalid

    ; Check if first character is just whitespace
    cmp byte [ebx], ' '
    je .check_only_whitespace

    ; Has at least one non-null, non-space character
    mov eax, 1
    jmp .done

.check_only_whitespace:
    ; Iterate through string to see if it's only spaces
    mov eax, ebx

.whitespace_loop:
    inc eax
    cmp byte [eax], NULL
    je .invalid         ; End of string, only had spaces
    cmp byte [eax], ' '
    je .whitespace_loop

    ; Found non-space character
    mov eax, 1
    jmp .done

.invalid:
    mov eax, 0

.done:
    pop ebx
    ret

; -----------------------------------------------------------------------------
; Data Conversion Functions
; -----------------------------------------------------------------------------

; Function: string_to_int
; Purpose: Converts a string to integer
; Input: EAX = string address
; Output: EAX = integer value
; Registers: Preserves original string pointer in ESI
string_to_int:
    push ebx
    push ecx
    push edx
    push esi

    mov esi, eax        ; Save string pointer
    xor ebx, ebx        ; Result
    xor ecx, ecx        ; Current digit

    ; Check if string is empty
    cmp byte [esi], NULL
    je .done

    ; Check for negative sign
    xor edx, edx        ; Flag for negative number
    cmp byte [esi], '-'
    jne .process_digits

    mov edx, 1          ; Set negative flag
    inc esi             ; Skip the minus sign

.process_digits:
    ; Get current character
    movzx ecx, byte [esi]

    ; Check if end of string
    cmp ecx, NULL
    je .check_sign

    ; Check if digit
    sub ecx, '0'
    cmp ecx, 0
    jl .invalid_digit
    cmp ecx, 9
    jg .invalid_digit

    ; Multiply current result by 10 and add digit
    imul ebx, 10
    add ebx, ecx

    ; Move to next character
    inc esi
    jmp .process_digits

.invalid_digit:
    ; Hit a non-digit, stop processing
    jmp .check_sign

.check_sign:
    ; Apply sign if needed
    test edx, edx
    jz .done
    neg ebx             ; Negate if flag was set

.done:
    mov eax, ebx        ; Return value in EAX

    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

; Function: string_compare
; Purpose: Compares two strings
; Input: ESI = first string, EDI = second string
; Output: EAX = 1 if equal, 0 if different
; Registers: Preserves original pointers in ESI and EDI
string_compare:
    push ebx
    push ecx
    push edx
    push esi
    push edi

.compare_loop:
    ; Load characters from both strings
    movzx eax, byte [esi]
    movzx ebx, byte [edi]

    ; Compare the characters
    cmp eax, ebx
    jne .not_equal

    ; Check if we reached the end of both strings
    test eax, eax
    jz .equal

    ; Move to next character
    inc esi
    inc edi
    jmp .compare_loop

.not_equal:
    xor eax, eax        ; Return 0 (not equal)
    jmp .done

.equal:
    mov eax, 1          ; Return 1 (equal)

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

; -----------------------------------------------------------------------------
; Book Management Functions
; -----------------------------------------------------------------------------

; Function: find_book
; Purpose: Finds a book by ID in the database
; Input: [temp_book_id] = ID to search for
; Output: [search_result] = index if found, -1 if not found
; Registers: Preserves all
find_book:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Initialize search result to not found
    mov dword [search_result], -1

    ; Get book count
    mov ecx, [book_count]
    test ecx, ecx
    jz .not_found        ; No books in database

    ; Start from first book
    mov ebx, 0           ; Book index

.search_loop:
    ; Calculate address of current book
    push ecx
    mov eax, ebx
    mov ecx, BOOK_SIZE
    mul ecx              ; EAX = EBX * BOOK_SIZE
    mov esi, books_db
    add esi, eax         ; ESI points to current book

    ; Compare book ID
    mov edi, temp_book_id
    mov ecx, 6           ; Compare up to 6 characters (5 + null)
    cld                  ; Clear direction flag (forward)
    repe cmpsb           ; Compare string bytes
    je .found

    ; Not a match, continue to next book
    pop ecx
    inc ebx
    cmp ebx, ecx
    jl .search_loop

    ; Book not found
    jmp .not_found

.found:
    pop ecx
    mov [search_result], ebx
    jmp .done

.not_found:
    mov dword [search_result], -1

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Function: store_book
; Purpose: Stores book data in the database
; Input: All temp_book_* variables contain book data
; Output: Book added to database, book_count updated
; Registers: Preserves all
store_book:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Get current book count
    mov eax, [book_count]

    ; Calculate address for new book
    mov ebx, eax
    mov eax, BOOK_SIZE
    mul ebx              ; EAX = book_count * BOOK_SIZE
    mov edi, books_db
    add edi, eax         ; EDI points to new book slot

    ; Copy book ID
    mov esi, temp_book_id
    mov ecx, 6           ; 5 chars + null
    rep movsb

    ; Copy book title
    mov esi, temp_book_title
    mov ecx, 51          ; 50 chars + null
    rep movsb

    ; Copy book author
    mov esi, temp_book_author
    mov ecx, 31          ; 30 chars + null
    rep movsb

    ; Copy quantity, issued count, and category
    mov eax, [temp_book_quantity]
    stosd                ; Store EAX at EDI and increment EDI by 4

    mov eax, [temp_book_issued]
    stosd

    mov eax, [temp_book_category]
    stosd

    ; Increment book count
    mov eax, [book_count]
    inc eax
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

; Function: load_book
; Purpose: Loads book data from database
; Input: [search_result] = index of book to load
; Output: All temp_book_* variables filled with book data
; Registers: Preserves all
load_book:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Get book index
    mov ebx, [search_result]

    ; Calculate address of book
    mov eax, BOOK_SIZE
    mul ebx              ; EAX = search_result * BOOK_SIZE
    mov esi, books_db
    add esi, eax         ; ESI points to book

    ; Copy book ID
    mov edi, temp_book_id
    mov ecx, 6           ; 5 chars + null
    rep movsb

    ; Copy book title
    mov edi, temp_book_title
    mov ecx, 51          ; 50 chars + null
    rep movsb
    
    ; Copy book author
    mov edi, temp_book_author
    mov ecx, 31          ; 30 chars + null
    rep movsb

    ; Copy quantity, issued count, and category
    lodsd                ; Load dword from ESI into EAX and increment ESI by 4
    mov [temp_book_quantity], eax

    lodsd
    mov [temp_book_issued], eax

    lodsd
    mov [temp_book_category], eax

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Function: update_book
; Purpose: Updates book information in the database
; Input: [search_result] = index of book to update, temp_book_* variables
; Output: Book data updated in database
; Registers: Preserves all
update_book:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Get book index
    mov ebx, [search_result]

    ; Calculate address of book
    mov eax, BOOK_SIZE
    mul ebx              ; EAX = search_result * BOOK_SIZE
    mov edi, books_db
    add edi, eax         ; EDI points to book

    ; Skip ID, title, and author fields (don't update these)
    add edi, 88          ; 6 + 51 + 31 = 88 bytes to skip

    ; Update quantity and issued
    mov eax, [temp_book_quantity]
    stosd
    mov eax, [temp_book_issued]
    stosd

    ; Skip category (we don't update it)

    ; Update statistics
    call update_statistics

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Function: update_statistics
; Purpose: Updates library statistics
; Input: None (reads from book database)
; Output: All statistics variables updated
; Registers: Preserves all
update_statistics:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Reset statistics
    mov dword [stat_total_books], 0
    mov dword [stat_books_issued], 0

    ; Clear category counts
    mov ecx, 6
    mov edi, stat_by_category
    xor eax, eax
    rep stosd

    ; No books? We're done
    mov eax, [book_count]
    test eax, eax
    jz .done

    ; Loop through all books
    mov ecx, 0          ; Book index counter

.stats_loop:
    ; Load book at index ECX
    push ecx
    mov [search_result], ecx
    call load_book

    ; Count this book in total
    inc dword [stat_total_books]

    ; Add issued books to count
    mov eax, [temp_book_issued]
    add [stat_books_issued], eax

    ; Count book by category
    mov eax, [temp_book_category]
    dec eax              ; Convert to 0-based index

    ; Ensure index is valid (0-4)
    cmp eax, 0
    jl .unknown_cat
    cmp eax, 4
    jg .unknown_cat

    ; Update the appropriate category count
    inc dword [stat_by_category + eax*4]
    jmp .next_book

.unknown_cat:
    ; Update unknown category count (index 5)
    inc dword [stat_by_category + 20]  ; 5*4 = 20

.next_book:
    ; Move to next book
    pop ecx
    inc ecx
    cmp ecx, [book_count]
    jl .stats_loop

    ; Calculate available books
    mov eax, [stat_total_books]
    mov ebx, [stat_books_issued]
    mov [stat_books_available], eax
    sub [stat_books_available], ebx

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Function: get_category_name
; Purpose: Gets category name from category index
; Input: EAX = category index (1-5)
; Output: EAX = pointer to category name
; Registers: Preserves original input in EDX
get_category_name:
    push ebx
    push edx

    mov edx, eax        ; Save original index

    ; Adjust to 0-based index
    dec eax

    ; Validate index
    cmp eax, 0
    jl .unknown
    cmp eax, 4
    jg .unknown

    ; Load category name pointer
    lea ebx, [category_names + eax*4]
    mov eax, [ebx]
    jmp .done

.unknown:
    ; Load "Unknown" category name
    mov eax, [category_names + 20]  ; 5*4 = 20

.done:
    pop edx
    pop ebx
    ret

; -----------------------------------------------------------------------------
; UI Display Functions
; -----------------------------------------------------------------------------

; Function: display_book_details
; Purpose: Displays formatted book details
; Input: temp_book_* variables contain book data
; Output: None
; Registers: Preserves all
display_book_details:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Print table header and separators
    mov eax, COLOR_CYAN
    mov ebx, table_header_border
    call print_colored

    mov eax, LF_STR
    call print_string

    mov eax, COLOR_WHITE
    mov ebx, table_header_row
    call print_colored

    mov eax, LF_STR
    call print_string

    mov eax, COLOR_CYAN
    mov ebx, table_header_border
    call print_colored

    mov eax, LF_STR
    call print_string

    ; Start data row with pipe
    mov eax, COLOR_WHITE
    mov ebx, table_separator_pipe
    call print_colored

    ; Display book ID (optimized with automatic padding)
    mov eax, COLOR_GREEN
    mov ebx, temp_book_id
    call print_colored

    ; Calculate padding for ID
    xor ecx, ecx
    mov esi, temp_book_id

.id_len_loop:
    cmp byte [esi+ecx], NULL
    je .id_pad_done
    inc ecx
    jmp .id_len_loop

.id_pad_done:
    ; Calculate spaces needed: column width - string length - pipe separator space
    mov eax, ID_COL_WIDTH
    sub eax, ecx
    sub eax, 2          ; "| "
    call print_spaces

    ; Display separator
    mov eax, COLOR_WHITE
    mov ebx, table_separator_pipe
    call print_colored

    ; Display book title
    mov eax, COLOR_YELLOW
    mov ebx, temp_book_title
    call print_colored

    ; Calculate padding for title
    xor ecx, ecx
    mov esi, temp_book_title

.title_len_loop:
    cmp byte [esi+ecx], NULL
    je .title_pad_done
    inc ecx
    jmp .title_len_loop

.title_pad_done:
    ; Calculate spaces needed
    mov eax, TITLE_COL_WIDTH
    sub eax, ecx
    sub eax, 2
    call print_spaces

    ; Display separator
    mov eax, COLOR_WHITE
    mov ebx, table_separator_pipe
    call print_colored

    ; Display author
    mov eax, COLOR_CYAN
    mov ebx, temp_book_author
    call print_colored

    ; Calculate padding for author
    xor ecx, ecx
    mov esi, temp_book_author

.author_len_loop:
    cmp byte [esi+ecx], NULL
    je .author_pad_done
    inc ecx
    jmp .author_len_loop

.author_pad_done:
    ; Calculate spaces needed
    mov eax, AUTHOR_COL_WIDTH
    sub eax, ecx
    sub eax, 2
    call print_spaces

    ; Display separator
    mov eax, COLOR_WHITE
    mov ebx, table_separator_pipe
    call print_colored

    ; Calculate availability
    mov eax, [temp_book_quantity]
    mov ebx, [temp_book_issued]
    sub eax, ebx         ; EAX = available count

    ; Choose color based on availability
    push eax             ; Save available count

    cmp eax, 0
    je .red_avail

    cmp eax, 3
    jl .yellow_avail

    ; Green for good availability
    mov eax, COLOR_GREEN
    jmp .avail_color_selected

.yellow_avail:
    mov eax, COLOR_YELLOW
    jmp .avail_color_selected

.red_avail:
    mov eax, COLOR_RED

.avail_color_selected:
    ; Print with color
    call print_string

    ; Get back available count and display status
    pop eax
    mov ebx, [temp_book_quantity]

    ; Determine status code (ALL, LTD, OUT)
    cmp eax, 0
    je .print_out

    cmp eax, ebx
    je .print_all

    ; Print LTD status
    push eax
    mov eax, "LTD "
    push eax
    mov eax, esp
    call print_string
    add esp, 4
    pop eax
    jmp .print_avail_count

.print_out:
    mov eax, "OUT "
    push eax
    mov eax, esp
    call print_string
    add esp, 4
    xor eax, eax        ; Available count is 0
    jmp .print_avail_count

.print_all:
    mov eax, "ALL "
    push eax
    mov eax, esp
    call print_string
    add esp, 4
    mov eax, ebx        ; Available count = total

.print_avail_count:
    ; Print available count
    call print_int

    ; Reset color
    mov eax, COLOR_RESET
    call print_string

    ; Calculate padding for availability
    mov eax, AVAIL_COL_WIDTH
    sub eax, 7           ; Approximate length of status + count
    sub eax, 2
    call print_spaces

    ; Display separator
    mov eax, COLOR_WHITE
    mov ebx, table_separator_pipe
    call print_colored

    ; Display category
    mov eax, COLOR_MAGENTA
    call print_string

    mov eax, [temp_book_category]
    call get_category_name

    ; Save category name for length calculation
    push eax
    mov esi, eax

    ; Calculate length of category name
    xor ecx, ecx
.cat_len_loop:
    cmp byte [esi+ecx], NULL
    je .cat_len_done
    inc ecx
    jmp .cat_len_loop

.cat_len_done:
    ; Display category
    pop eax
    call print_string

    ; Reset color
    mov eax, COLOR_RESET
    call print_string

    ; Calculate padding for category
    mov eax, CATEGORY_COL_WIDTH
    sub eax, ecx
    sub eax, 2
    call print_spaces

    ; Close the row
    mov eax, COLOR_WHITE
    mov ebx, table_pipe
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; Print bottom separator
    mov eax, COLOR_CYAN
    mov ebx, table_header_border
    call print_colored

    mov eax, LF_STR
    call print_string

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Function: print_spaces
; Purpose: Prints a specified number of spaces
; Input: EAX = number of spaces
; Output: None
; Registers: Preserves all
print_spaces:
    push eax
    push ecx

    ; Don't print negative spaces
    test eax, eax
    jle .done

    mov ecx, eax        ; Loop counter

.space_loop:
    push ecx

    ; Print a space
    push ' '
    mov eax, esp
    call print_char
    add esp, 4

    pop ecx
    dec ecx
    jnz .space_loop

.done:
    pop ecx
    pop eax
    ret

; Function: int_to_string
; Purpose: Converts integer to string
; Input: EAX = integer, EDI = buffer to store string
; Output: String in buffer, EDI updated to point after string
; Registers: Preserves EAX
int_to_string:
    push eax
    push ebx
    push ecx
    push edx

    mov ebx, 10         ; Divisor
    mov ecx, 0          ; Digit count

    ; Handle zero specially
    test eax, eax
    jnz .convert_loop

    mov byte [edi], '0'
    inc edi
    jmp .done

.convert_loop:
    test eax, eax
    jz .reverse

    ; Extract next digit
    xor edx, edx
    div ebx

    ; Convert to ASCII and store temporarily
    add dl, '0'
    push edx
    inc ecx

    jmp .convert_loop

.reverse:
    ; Pop digits in reverse order
    test ecx, ecx
    jz .done

    pop eax
    mov [edi], al
    inc edi
    dec ecx
    jmp .reverse

.done:
    mov byte [edi], NULL

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; -----------------------------------------------------------------------------
; Navigation and Improved Validation Functions
; -----------------------------------------------------------------------------

; Function: check_for_back
; Purpose: Check if input string is "back" to return to main menu
; Input: EAX = input string pointer
; Output: EAX = 1 if "back", 0 if not
; Registers: Preserves all except EAX
check_for_back:
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Store string pointer
    mov esi, eax

    ; Compare with "back" (case-insensitive)
    ; First, convert input to lowercase
    mov edi, temp_buffer    ; Use temp buffer for conversion

    ; Copy and convert to lowercase
    xor ecx, ecx           ; Character counter

.copy_loop:
    ; Get current character
    mov al, [esi + ecx]

    ; Check if end of string
    cmp al, NULL
    je .copy_done

    ; Convert to lowercase if uppercase
    cmp al, 'A'
    jl .skip_conversion
    cmp al, 'Z'
    jg .skip_conversion
    add al, 32             ; Convert to lowercase

.skip_conversion:
    ; Store in buffer
    mov [edi + ecx], al

    ; Move to next character
    inc ecx
    cmp ecx, 10            ; Safety limit
    jl .copy_loop

.copy_done:
    ; Null terminate
    mov byte [edi + ecx], NULL

    ; Now compare with "back"
    mov esi, temp_buffer
    mov edi, "back"
    call string_compare

    ; Result is already in EAX

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

; Function: validate_borrower_id
; Purpose: Check if borrower ID starts with a letter (improved validation)
; Input: EAX = borrower ID string pointer
; Output: EAX = 1 if valid (starts with letter), 0 if invalid
; Registers: Preserves all except EAX
validate_borrower_id:
    push ebx
    push ecx
    push edx

    mov ebx, eax        ; Save string address

    ; First check if string is empty
    call validate_not_empty
    cmp eax, 0
    je .invalid

    ; Check first character is a letter
    mov al, [ebx]

    ; Check if uppercase (A-Z)
    cmp al, 'A'
    jl .check_lowercase
    cmp al, 'Z'
    jle .valid

    ; Check if lowercase (a-z)
.check_lowercase:
    cmp al, 'a'
    jl .invalid
    cmp al, 'z'
    jle .valid

.invalid:
    mov eax, 0
    jmp .done

.valid:
    mov eax, 1

.done:
    pop edx
    pop ecx
    pop ebx
    ret

; Function: get_string_with_back
; Purpose: Gets string input with "back" option support
; Input: ECX = buffer address, EDX = maximum length
; Output: EAX = 1 if user entered text, 0 if "back" was entered
; Registers: Preserves all except EAX
get_string_with_back:
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Display back option hint
    mov eax, COLOR_CYAN
    mov ebx, back_option
    call print_colored

    ; Get user input (using standard function)
    call get_string

    ; Check if user entered "back"
    mov eax, ecx        ; Buffer address passed in ECX
    call check_for_back

    ; EAX now contains 1 if "back", 0 if not
    ; Return the opposite (1 for normal input, 0 for back)
    test eax, eax
    jz .normal_input

    ; User entered "back"
    xor eax, eax        ; Return 0
    jmp .done

.normal_input:
    mov eax, 1          ; Return 1

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
