; =============================================================================
; Library Statistics Module
; =============================================================================
;
; This module handles the display of library statistics, including:
; - Total book count
; - Books issued
; - Books available
; - Books by category
;
; The presentation uses color coding for better readability and clear
; organization of information.
; =============================================================================

; Function: display_statistics
; Purpose: Display library statistics in a formatted view
; Input: None
; Output: None (returns to main menu)
; Registers: All preserved
display_statistics:
    ; Save registers we'll use
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Display framed title
    mov eax, stats_title
    call display_framed_title

    ; -----------------------------------------------------------------
    ; Update statistics to ensure they're current
    ; -----------------------------------------------------------------
    call update_statistics

    ; -----------------------------------------------------------------
    ; Display General Statistics
    ; -----------------------------------------------------------------
    ; Display general statistics heading
    mov eax, COLOR_YELLOW
    mov dword [temp_buffer], "Gene"
    mov dword [temp_buffer+4], "ral "
    mov dword [temp_buffer+8], "Stat"
    mov dword [temp_buffer+12], "isti"
    mov dword [temp_buffer+16], "cs:"
    mov byte [temp_buffer+20], LF
    mov byte [temp_buffer+21], NULL
    mov ebx, temp_buffer
    call print_colored

    ; Print separator for visual clarity
    mov eax, COLOR_CYAN
    mov dword [temp_buffer], "----"
    mov dword [temp_buffer+4], "----"
    mov dword [temp_buffer+8], "----"
    mov dword [temp_buffer+12], "----"
    mov dword [temp_buffer+16], "----"
    mov byte [temp_buffer+20], LF
    mov byte [temp_buffer+21], NULL
    mov ebx, temp_buffer
    call print_colored

    ; -----------------------------------------------------------------
    ; Display Total Books
    ; -----------------------------------------------------------------
    ; Display label
    mov eax, COLOR_CYAN
    mov ebx, stats_total_books
    call print_colored

    ; Display value with color based on count
    mov eax, [stat_total_books]

    ; Choose color based on book count
    push eax
    cmp eax, 20
    jge .good_total
    cmp eax, 10
    jge .avg_total

    mov eax, COLOR_RED      ; Low book count
    jmp .print_total

.avg_total:
    mov eax, COLOR_YELLOW   ; Average book count
    jmp .print_total

.good_total:
    mov eax, COLOR_GREEN    ; Good book count

.print_total:
    call print_string
    pop eax
    call print_int

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; -----------------------------------------------------------------
    ; Display Issued Books
    ; -----------------------------------------------------------------
    ; Display label
    mov eax, COLOR_CYAN
    mov ebx, stats_books_issued
    call print_colored

    ; Display value with color
    mov eax, COLOR_YELLOW
    call print_string
    mov eax, [stat_books_issued]
    call print_int

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; -----------------------------------------------------------------
    ; Display Available Books
    ; -----------------------------------------------------------------
    ; Display label
    mov eax, COLOR_CYAN
    mov ebx, stats_books_available
    call print_colored

    ; Display value with color based on availability
    mov eax, [stat_books_available]

    ; Choose color based on available count
    push eax
    cmp eax, 15
    jge .good_avail
    cmp eax, 5
    jge .avg_avail

    mov eax, COLOR_RED      ; Low availability
    jmp .print_avail

.avg_avail:
    mov eax, COLOR_YELLOW   ; Average availability
    jmp .print_avail

.good_avail:
    mov eax, COLOR_GREEN    ; Good availability

.print_avail:
    call print_string
    pop eax
    call print_int

    ; Print newline
    mov eax, LF_STR
    call print_string
    mov eax, LF_STR          ; Add extra space
    call print_string

    ; -----------------------------------------------------------------
    ; Display Category Statistics
    ; -----------------------------------------------------------------
    ; Display category header
    mov eax, COLOR_MAGENTA
    mov ebx, stats_category_header
    call print_colored

    ; Print separator for visual clarity
    mov eax, COLOR_CYAN
    mov dword [temp_buffer], "----"
    mov dword [temp_buffer+4], "----"
    mov dword [temp_buffer+8], "----"
    mov dword [temp_buffer+12], "----"
    mov dword [temp_buffer+16], "----"
    mov byte [temp_buffer+20], LF
    mov byte [temp_buffer+21], NULL
    mov ebx, temp_buffer
    call print_colored

    ; -----------------------------------------------------------------
    ; Display Books by Category
    ; -----------------------------------------------------------------
    ; Fiction - category 1
    mov eax, COLOR_CYAN
    mov ebx, category_fiction
    call print_colored

    mov eax, colon_space
    call print_string

    ; Get count for this category
    mov eax, [stat_by_category]  ; Access array at index 0

    ; Choose color based on count
    push eax
    test eax, eax
    jz .empty_cat1
    cmp eax, 5
    jge .good_cat1

    mov eax, COLOR_YELLOW   ; Low count
    jmp .print_cat1

.empty_cat1:
    mov eax, COLOR_RED      ; Empty category
    jmp .print_cat1

.good_cat1:
    mov eax, COLOR_GREEN    ; Good count

.print_cat1:
    call print_string
    pop eax
    call print_int

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; -----------------------------------------------------------------
    ; Non-fiction - category 2
    ; -----------------------------------------------------------------
    mov eax, COLOR_CYAN
    mov ebx, category_nonfiction
    call print_colored

    mov eax, colon_space
    call print_string

    ; Get count for this category
    mov eax, [stat_by_category + 4]  ; Access array at index 1

    ; Choose color based on count
    push eax
    test eax, eax
    jz .empty_cat2
    cmp eax, 5
    jge .good_cat2

    mov eax, COLOR_YELLOW   ; Low count
    jmp .print_cat2

.empty_cat2:
    mov eax, COLOR_RED      ; Empty category
    jmp .print_cat2

.good_cat2:
    mov eax, COLOR_GREEN    ; Good count

.print_cat2:
    call print_string
    pop eax
    call print_int

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; -----------------------------------------------------------------
    ; Reference - category 3
    ; -----------------------------------------------------------------
    mov eax, COLOR_CYAN
    mov ebx, category_reference
    call print_colored

    mov eax, colon_space
    call print_string

    ; Get count for this category
    mov eax, [stat_by_category + 8]  ; Access array at index 2

    ; Choose color based on count
    push eax
    test eax, eax
    jz .empty_cat3
    cmp eax, 5
    jge .good_cat3

    mov eax, COLOR_YELLOW   ; Low count
    jmp .print_cat3

.empty_cat3:
    mov eax, COLOR_RED      ; Empty category
    jmp .print_cat3

.good_cat3:
    mov eax, COLOR_GREEN    ; Good count

.print_cat3:
    call print_string
    pop eax
    call print_int

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; -----------------------------------------------------------------
    ; Textbook - category 4
    ; -----------------------------------------------------------------
    mov eax, COLOR_CYAN
    mov ebx, category_textbook
    call print_colored

    mov eax, colon_space
    call print_string

    ; Get count for this category
    mov eax, [stat_by_category + 12]  ; Access array at index 3

    ; Choose color based on count
    push eax
    test eax, eax
    jz .empty_cat4
    cmp eax, 5
    jge .good_cat4

    mov eax, COLOR_YELLOW   ; Low count
    jmp .print_cat4

.empty_cat4:
    mov eax, COLOR_RED      ; Empty category
    jmp .print_cat4

.good_cat4:
    mov eax, COLOR_GREEN    ; Good count

.print_cat4:
    call print_string
    pop eax
    call print_int

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; -----------------------------------------------------------------
    ; Magazine - category 5
    ; -----------------------------------------------------------------
    mov eax, COLOR_CYAN
    mov ebx, category_magazine
    call print_colored

    mov eax, colon_space
    call print_string

    ; Get count for this category
    mov eax, [stat_by_category + 16]  ; Access array at index 4

    ; Choose color based on count
    push eax
    test eax, eax
    jz .empty_cat5
    cmp eax, 5
    jge .good_cat5

    mov eax, COLOR_YELLOW   ; Low count
    jmp .print_cat5

.empty_cat5:
    mov eax, COLOR_RED      ; Empty category
    jmp .print_cat5

.good_cat5:
    mov eax, COLOR_GREEN    ; Good count

.print_cat5:
    call print_string
    pop eax
    call print_int

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; -----------------------------------------------------------------
    ; Unknown - category 6
    ; -----------------------------------------------------------------
    mov eax, COLOR_CYAN
    mov ebx, unknown_category
    call print_colored

    mov eax, colon_space
    call print_string

    ; Get count for this category
    mov eax, [stat_by_category + 20]  ; Access array at index 5

    ; Choose color based on count
    push eax
    test eax, eax
    jz .empty_cat6
    cmp eax, 5
    jge .good_cat6

    mov eax, COLOR_YELLOW   ; Low count
    jmp .print_cat6

.empty_cat6:
    mov eax, COLOR_RED      ; Empty category
    jmp .print_cat6

.good_cat6:
    mov eax, COLOR_GREEN    ; Good count

.print_cat6:
    call print_string
    pop eax
    call print_int

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; -----------------------------------------------------------------
    ; Additional Statistics
    ; -----------------------------------------------------------------
    ; Display percentage of books issued
    mov eax, [stat_total_books]
    test eax, eax            ; Check if there are any books
    jz .skip_percentage      ; Skip if no books (avoid division by zero)

    ; Calculate percentage of books issued
    mov eax, [stat_books_issued]
    mov edx, 100             ; For percentage calculation
    mul edx                  ; EAX = issued * 100
    mov ebx, [stat_total_books]
    div ebx                  ; EAX = (issued * 100) / total

    ; Display percentage
    mov eax, LF_STR          ; Add extra space
    call print_string

    mov eax, COLOR_CYAN
    mov dword [temp_buffer], "Perc"
    mov dword [temp_buffer+4], "enta"
    mov dword [temp_buffer+8], "ge i"
    mov dword [temp_buffer+12], "ssue"
    mov dword [temp_buffer+16], "d: "
    mov byte [temp_buffer+19], NULL
    mov ebx, temp_buffer
    call print_colored

    ; Get percentage again (the division above modified EAX)
    mov eax, [stat_books_issued]
    mov edx, 100
    mul edx
    mov ebx, [stat_total_books]
    div ebx

    ; Choose color based on percentage
    push eax
    cmp eax, 80
    jge .high_usage
    cmp eax, 40
    jge .med_usage

    mov eax, COLOR_GREEN    ; Low usage (good)
    jmp .print_pct

.med_usage:
    mov eax, COLOR_YELLOW   ; Medium usage
    jmp .print_pct

.high_usage:
    mov eax, COLOR_RED      ; High usage (might need more books)

.print_pct:
    call print_string
    pop eax
    call print_int

    ; Print percent sign
    mov eax, '%'
    push eax
    mov eax, esp
    call print_char
    add esp, 4

    ; Print newline
    mov eax, LF_STR
    call print_string

.skip_percentage:
    ; -----------------------------------------------------------------
    ; Wait for user input and return to menu
    ; -----------------------------------------------------------------
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

; =============================================================================
; Browse by Category Module
; =============================================================================
;
; Function: browse_by_category
; Purpose: Allow users to browse books by category
; Input: None
; Output: None (returns to main menu)
; Registers: All preserved
browse_by_category:
    ; Save registers we'll use
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Clear screen for clean display
    call clear_screen

    ; Display framed title
    mov eax, browse_category_title
    call display_framed_title

    ; -----------------------------------------------------------------
    ; Display category selection menu
    ; -----------------------------------------------------------------
    ; Display prompt in cyan
    mov eax, COLOR_CYAN
    mov ebx, category_select_prompt
    call print_colored

    ; Get user choice
    mov ecx, input_buffer
    mov edx, 2                      ; Just 1 digit + null
    call get_string
    ; Check if input might be "back" by looking at first character
    mov al, [input_buffer]

    ; Check if it starts with 'b' or 'B'
    cmp al, 'b'
    je .check_back_text
    cmp al, 'B'
    je .check_back_text

    ; Not "back" - continue with regular processing
    jmp .continue_processing

.check_back_text:
    ; Simple check - if first letter is 'b', assume "back" was intended
    ; This prevents having to do a full string comparison
    jmp .return_to_menu

.continue_processing:
    ; Validate user choice
    mov eax, input_buffer
    call validate_numeric
    cmp eax, 0
    je .invalid_choice

    ; Convert to integer
    mov eax, input_buffer
    call string_to_int

    ; Validate range (1-6)
    cmp eax, 1
    jl .invalid_choice
    cmp eax, 6
    jg .invalid_choice

    ; Store selected category (1-5 real categories, 6 means all)
    mov [selected_category], eax

    ; -----------------------------------------------------------------
    ; Display books of selected category
    ; -----------------------------------------------------------------
    ; Display header with selected category
    mov eax, COLOR_MAGENTA
    mov dword [temp_buffer], "Brow"
    mov dword [temp_buffer+4], "sing"
    mov dword [temp_buffer+8], " cat"
    mov dword [temp_buffer+12], "egor"
    mov dword [temp_buffer+16], "y: "
    mov byte [temp_buffer+19], NULL
    mov ebx, temp_buffer
    call print_colored

    ; Get category name and display it
    mov eax, [selected_category]

    ; Special case for "All categories"
    cmp eax, 6
    je .all_categories

    ; Display specific category name
    call get_category_name
    mov ebx, eax
    mov eax, COLOR_YELLOW
    call print_colored
    jmp .continue_display

.all_categories:
    ; Display "All categories"
    mov eax, COLOR_YELLOW
    mov dword [temp_buffer], "All "
    mov dword [temp_buffer+4], "cate"
    mov dword [temp_buffer+8], "gori"
    mov dword [temp_buffer+12], "es"
    mov byte [temp_buffer+14], NULL
    mov ebx, temp_buffer
    call print_colored

.continue_display:
    ; Print newline
    mov eax, LF_STR
    call print_string
    mov eax, LF_STR   ; Extra space
    call print_string

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

    ; Print separator
    mov eax, COLOR_CYAN
    mov ebx, table_header_border
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; -----------------------------------------------------------------
    ; Loop through all books to find ones matching the category
    ; -----------------------------------------------------------------
    ; Initialize counter
    mov ecx, 0

.display_loop:
    ; Check if we've reached the end of the book database
    cmp ecx, [book_count]
    jge .end_display

    ; Load book data
    push ecx
    mov [search_result], ecx
    call load_book

    ; Check if this book matches the selected category
    mov eax, [selected_category]

    ; Special case for "All categories"
    cmp eax, 6
    je .display_book

    ; Check if book category matches selected category
    cmp eax, [temp_book_category]
    jne .next_book

.display_book:
    ; This book matches the category filter
    inc dword [match_count]

    ; Display this book's information
    call display_book_row

.next_book:
    ; Move to next book
    pop ecx
    inc ecx
    jmp .display_loop

.end_display:
    ; Print final separator
    mov eax, COLOR_CYAN
    mov ebx, table_header_border
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; Check if any books were found
    mov eax, [match_count]
    test eax, eax
    jnz .found_books

    ; No books in this category
    mov eax, COLOR_YELLOW
    mov dword [temp_buffer], "No b"
    mov dword [temp_buffer+4], "ooks"
    mov dword [temp_buffer+8], " in "
    mov dword [temp_buffer+12], "this"
    mov dword [temp_buffer+16], " cat"
    mov dword [temp_buffer+20], "egor"
    mov dword [temp_buffer+24], "y."
    mov byte [temp_buffer+27], LF
    mov byte [temp_buffer+28], NULL
    mov ebx, temp_buffer
    call print_colored
    jmp .finish

.found_books:
    ; Display number of books found
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

    mov eax, COLOR_GREEN
    mov dword [temp_buffer], " boo"
    mov dword [temp_buffer+4], "k(s)"
    mov byte [temp_buffer+8], NULL
    mov ebx, temp_buffer
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string

    jmp .finish

.invalid_choice:
    ; Invalid category choice
    mov eax, COLOR_RED
    mov dword [temp_buffer], "Inva"
    mov dword [temp_buffer+4], "lid "
    mov dword [temp_buffer+8], "choi"
    mov dword [temp_buffer+12], "ce. "
    mov dword [temp_buffer+16], "Plea"
    mov dword [temp_buffer+20], "se e"
    mov dword [temp_buffer+24], "nter"
    mov dword [temp_buffer+28], " 1-6"
    mov dword [temp_buffer+32], "."
    mov byte [temp_buffer+33], LF
    mov byte [temp_buffer+34], NULL
    mov ebx, temp_buffer
    call print_colored

    ; Brief delay
    mov ecx, 300000
.delay_loop:
    loop .delay_loop

    ; Try again
    jmp browse_by_category

.finish:
    ; -----------------------------------------------------------------
    ; Wait for user input and return to menu
    ; -----------------------------------------------------------------
    ; Wait for user to press Enter before returning to menu
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

; =============================================================================
; Library Information Module
; =============================================================================
;
; Function: display_library_info
; Purpose: Display comprehensive library information
; Input: None
; Output: None (returns to main menu)
; Registers: All preserved
display_library_info:
    ; Save registers we'll use
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Clear screen
    call clear_screen

    ; Display framed title
    mov eax, library_info_title
    call display_framed_title

    ; -----------------------------------------------------------------
    ; Display library status overview
    ; -----------------------------------------------------------------
    ; Make sure statistics are current
    call update_statistics

    ; Display heading
    mov eax, COLOR_YELLOW
    mov ebx, library_status_heading
    call print_colored

    ; Display total books
    mov eax, COLOR_CYAN
    mov dword [temp_buffer], "Tota"
    mov dword [temp_buffer+4], "l bo"
    mov dword [temp_buffer+8], "oks:"
    mov dword [temp_buffer+12], " "
    mov byte [temp_buffer+13], NULL
    mov ebx, temp_buffer
    call print_colored

    mov eax, COLOR_WHITE
    call print_string
    mov eax, [stat_total_books]
    call print_int

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; Display books available
    mov eax, COLOR_CYAN
    mov dword [temp_buffer], "Book"
    mov dword [temp_buffer+4], "s av"
    mov dword [temp_buffer+8], "aila"
    mov dword [temp_buffer+12], "ble:"
    mov dword [temp_buffer+16], " "
    mov byte [temp_buffer+17], NULL
    mov ebx, temp_buffer
    call print_colored

    mov eax, COLOR_GREEN
    call print_string
    mov eax, [stat_books_available]
    call print_int

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; Display books issued
    mov eax, COLOR_CYAN
    mov dword [temp_buffer], "Book"
    mov dword [temp_buffer+4], "s is"
    mov dword [temp_buffer+8], "sued"
    mov dword [temp_buffer+12], ": "
    mov byte [temp_buffer+14], NULL
    mov ebx, temp_buffer
    call print_colored

    mov eax, COLOR_YELLOW
    call print_string
    mov eax, [stat_books_issued]
    call print_int

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; Display usage percentage
    mov eax, [stat_total_books]
    test eax, eax            ; Check if there are any books
    jz .skip_percentage      ; Skip if no books (avoid division by zero)

    ; Calculate percentage of books issued
    mov eax, [stat_books_issued]
    mov edx, 100             ; For percentage calculation
    mul edx                  ; EAX = issued * 100
    mov ebx, [stat_total_books]
    div ebx                  ; EAX = (issued * 100) / total

    ; Display percentage
    mov eax, COLOR_CYAN
    mov dword [temp_buffer], "Book"
    mov dword [temp_buffer+4], " usa"
    mov dword [temp_buffer+8], "ge: "
    mov byte [temp_buffer+12], NULL
    mov ebx, temp_buffer
    call print_colored

    ; Get percentage again (the division above modified EAX)
    mov eax, [stat_books_issued]
    mov edx, 100
    mul edx
    mov ebx, [stat_total_books]
    div ebx

    ; Choose color based on percentage
    push eax
    cmp eax, 80
    jge .high_usage
    cmp eax, 40
    jge .med_usage

    mov eax, COLOR_GREEN    ; Low usage (good)
    jmp .print_pct

.med_usage:
    mov eax, COLOR_YELLOW   ; Medium usage
    jmp .print_pct

.high_usage:
    mov eax, COLOR_RED      ; High usage (might need more books)

.print_pct:
    call print_string
    pop eax
    call print_int

    ; Print percent sign
    mov eax, '%'
    push eax
    mov eax, esp
    call print_char
    add esp, 4

    ; Print newline
    mov eax, LF_STR
    call print_string

.skip_percentage:
    ; Print extra newline for spacing
    mov eax, LF_STR
    call print_string

    ; -----------------------------------------------------------------
    ; Display books by category
    ; -----------------------------------------------------------------
    ; Display category header
    mov eax, COLOR_MAGENTA
    mov ebx, books_by_cat_msg
    call print_colored

    ; Display books for each category
    ; Fiction - category 1
    mov eax, COLOR_CYAN
    mov ebx, category_fiction
    call print_colored

    mov eax, colon_space
    call print_string

    ; Get count for this category
    mov eax, [stat_by_category]  ; Access array at index 0
    call print_int

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; Non-fiction - category 2
    mov eax, COLOR_CYAN
    mov ebx, category_nonfiction
    call print_colored

    mov eax, colon_space
    call print_string

    ; Get count for this category
    mov eax, [stat_by_category + 4]  ; Access array at index 1
    call print_int

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; Reference - category 3
    mov eax, COLOR_CYAN
    mov ebx, category_reference
    call print_colored

    mov eax, colon_space
    call print_string

    ; Get count for this category
    mov eax, [stat_by_category + 8]  ; Access array at index 2
    call print_int

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; Textbook - category 4
    mov eax, COLOR_CYAN
    mov ebx, category_textbook
    call print_colored

    mov eax, colon_space
    call print_string

    ; Get count for this category
    mov eax, [stat_by_category + 12]  ; Access array at index 3
    call print_int

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; Magazine - category 5
    mov eax, COLOR_CYAN
    mov ebx, category_magazine
    call print_colored

    mov eax, colon_space
    call print_string

    ; Get count for this category
    mov eax, [stat_by_category + 16]  ; Access array at index 4
    call print_int

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; Print extra newline for spacing
    mov eax, LF_STR
    call print_string

    ; -----------------------------------------------------------------
    ; Display borrowing information
    ; -----------------------------------------------------------------
    ; Display system info
    mov eax, COLOR_YELLOW
    mov dword [temp_buffer], "Borr"
    mov dword [temp_buffer+4], "owin"
    mov dword [temp_buffer+8], "g In"
    mov dword [temp_buffer+12], "form"
    mov dword [temp_buffer+16], "atio"
    mov dword [temp_buffer+20], "n:"
    mov byte [temp_buffer+23], LF
    mov byte [temp_buffer+24], NULL
    mov ebx, temp_buffer
    call print_colored

    ; Display borrow count
    mov eax, COLOR_CYAN
    mov dword [temp_buffer], "Tota"
    mov dword [temp_buffer+4], "l bo"
    mov dword [temp_buffer+8], "rrow"
    mov dword [temp_buffer+12], "s: "
    mov byte [temp_buffer+15], NULL
    mov ebx, temp_buffer
    call print_colored

    mov eax, COLOR_WHITE
    call print_string
    mov eax, [borrow_count]
    call print_int

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; Display most recent borrower info (if any)
    mov eax, [borrow_count]
    test eax, eax
    jz .skip_recent_borrow

    ; Display most recent borrower
    mov eax, COLOR_CYAN
    mov dword [temp_buffer], "Most"
    mov dword [temp_buffer+4], " rec"
    mov dword [temp_buffer+8], "ent "
    mov dword [temp_buffer+12], "borr"
    mov dword [temp_buffer+16], "ower"
    mov dword [temp_buffer+20], ": "
    mov byte [temp_buffer+22], NULL
    mov ebx, temp_buffer
    call print_colored

    mov eax, COLOR_WHITE
    mov ebx, last_borrower
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string

.skip_recent_borrow:
    ; -----------------------------------------------------------------
    ; Wait for user input and return to menu
    ; -----------------------------------------------------------------
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

; =============================================================================
; Guest Help Module
; =============================================================================
;
; Function: display_guest_help
; Purpose: Display help information for guest users
; Input: None
; Output: None (returns to main menu)
; Registers: All preserved
display_guest_help:
    ; Save registers we'll use
    push eax
    push ebx
    push ecx
    push edx

    ; Clear screen
    call clear_screen

    ; Display framed title
    mov eax, help_title
    call display_framed_title

    ; -----------------------------------------------------------------
    ; Display general help information
    ; -----------------------------------------------------------------
    mov eax, COLOR_YELLOW
    mov ebx, guest_help_msg
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; -----------------------------------------------------------------
    ; Display borrower ID information
    ; -----------------------------------------------------------------
    mov eax, COLOR_CYAN
    mov dword [temp_buffer], "Abou"
    mov dword [temp_buffer+4], "t Bo"
    mov dword [temp_buffer+8], "rrow"
    mov dword [temp_buffer+12], "er I"
    mov dword [temp_buffer+16], "Ds:"
    mov byte [temp_buffer+19], LF
    mov byte [temp_buffer+20], NULL
    mov ebx, temp_buffer
    call print_colored

    ; Display borrower ID help
    mov eax, COLOR_WHITE
    mov ebx, borrower_id_help
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; -----------------------------------------------------------------
    ; Display search tips
    ; -----------------------------------------------------------------
    mov eax, COLOR_CYAN
    mov dword [temp_buffer], "Sear"
    mov dword [temp_buffer+4], "ch T"
    mov dword [temp_buffer+8], "ips:"
    mov byte [temp_buffer+12], LF
    mov byte [temp_buffer+13], NULL
    mov ebx, temp_buffer
    call print_colored

; Display search tips
    mov eax, COLOR_WHITE
    mov dword [temp_buffer], "- Yo"
    mov dword [temp_buffer+4], "u ca"
    mov dword [temp_buffer+8], "n se"
    mov dword [temp_buffer+12], "arch"
    mov dword [temp_buffer+16], " by "
    mov dword [temp_buffer+20], "book"
    mov dword [temp_buffer+24], " ID,"
    mov dword [temp_buffer+28], " tit"
    mov dword [temp_buffer+32], "le, "
    mov dword [temp_buffer+36], "or a"
    mov dword [temp_buffer+40], "utho"
    mov dword [temp_buffer+44], "r"
    mov byte [temp_buffer+46], LF
    mov byte [temp_buffer+47], 0
    mov ebx, temp_buffer
    call print_colored

    mov eax, COLOR_WHITE
    mov dword [temp_buffer], "- Pa"
    mov dword [temp_buffer+4], "rtia"
    mov dword [temp_buffer+8], "l ma"
    mov dword [temp_buffer+12], "tche"
    mov dword [temp_buffer+16], "s ar"
    mov dword [temp_buffer+20], "e su"
    mov dword [temp_buffer+24], "ppor"
    mov dword [temp_buffer+28], "ted "
    mov dword [temp_buffer+32], "(e.g"
    mov dword [temp_buffer+36], ". Pr"
    mov dword [temp_buffer+40], "og w"
    mov dword [temp_buffer+44], "ill "
    mov dword [temp_buffer+48], "find"
    mov dword [temp_buffer+52], " Pro"
    mov dword [temp_buffer+56], "gram"
    mov dword [temp_buffer+60], "ming"
    mov dword [temp_buffer+64], ")"
    mov byte [temp_buffer+66], LF
    mov byte [temp_buffer+67], 0
    mov ebx, temp_buffer
    call print_colored

    mov eax, COLOR_WHITE
    mov dword [temp_buffer], "- Se"
    mov dword [temp_buffer+4], "arch"
    mov dword [temp_buffer+8], "es a"
    mov dword [temp_buffer+12], "re c"
    mov dword [temp_buffer+16], "ase-"
    mov dword [temp_buffer+20], "inse"
    mov dword [temp_buffer+24], "nsit"
    mov dword [temp_buffer+28], "ive"
    mov byte [temp_buffer+32], LF
    mov byte [temp_buffer+33], 0
    mov ebx, temp_buffer
    call print_colored
    ; Print newline
    mov eax, LF_STR
    call print_string

    ; -----------------------------------------------------------------
    ; Display borrowing tips
    ; -----------------------------------------------------------------
    mov eax, COLOR_CYAN
    mov dword [temp_buffer], "Borr"
    mov dword [temp_buffer+4], "owin"
    mov dword [temp_buffer+8], "g Ti"
    mov dword [temp_buffer+12], "ps:"
    mov byte [temp_buffer+16], LF
    mov byte [temp_buffer+17], NULL
    mov ebx, temp_buffer
    call print_colored

    ; Display borrowing tips
    mov eax, COLOR_WHITE
    mov dword [temp_buffer], "- Bo"
    mov dword [temp_buffer+4], "rrow"
    mov dword [temp_buffer+8], "er I"
    mov dword [temp_buffer+12], "Ds s"
    mov dword [temp_buffer+16], "tart"
    mov dword [temp_buffer+20], "ing "
    mov dword [temp_buffer+24], "with"
    mov dword [temp_buffer+28], " 'A'"
    mov dword [temp_buffer+32], " get"
    mov dword [temp_buffer+36], " the"
    mov dword [temp_buffer+40], " bes"
    mov dword [temp_buffer+44], "t pr"
    mov dword [temp_buffer+48], "ivil"
    mov dword [temp_buffer+52], "eges"
    mov byte [temp_buffer+56], LF
    mov byte [temp_buffer+57], NULL
    mov ebx, temp_buffer
    call print_colored

    mov eax, COLOR_WHITE
    mov dword [temp_buffer], "- Bo"
    mov dword [temp_buffer+4], "oks "
    mov dword [temp_buffer+8], "can "
    mov dword [temp_buffer+12], "be b"
    mov dword [temp_buffer+16], "orro"
    mov dword [temp_buffer+20], "wed "
    mov dword [temp_buffer+24], "for "
    mov dword [temp_buffer+28], "1-10"
    mov dword [temp_buffer+32], " day"
    mov dword [temp_buffer+36], "s"
    mov byte [temp_buffer+38], LF
    mov byte [temp_buffer+39], NULL
    mov ebx, temp_buffer
    call print_colored

    mov eax, COLOR_WHITE
    mov dword [temp_buffer], "- Re"
    mov dword [temp_buffer+4], "turn"
    mov dword [temp_buffer+8], " boo"
    mov dword [temp_buffer+12], "ks o"
    mov dword [temp_buffer+16], "n ti"
    mov dword [temp_buffer+20], "me t"
    mov dword [temp_buffer+24], "o av"
    mov dword [temp_buffer+28], "oid "
    mov dword [temp_buffer+32], "fine"
    mov dword [temp_buffer+36], "s"
    mov byte [temp_buffer+38], LF
    mov byte [temp_buffer+39], NULL
    mov ebx, temp_buffer
    call print_colored

    ; Print newline
    mov eax, LF_STR
    call print_string

    ; -----------------------------------------------------------------
    ; Display navigation tips
    ; -----------------------------------------------------------------
    mov eax, COLOR_CYAN
    mov dword [temp_buffer], "Navi"
    mov dword [temp_buffer+4], "gati"
    mov dword [temp_buffer+8], "on T"
    mov dword [temp_buffer+12], "ips:"
    mov byte [temp_buffer+16], LF
    mov byte [temp_buffer+17], NULL
    mov ebx, temp_buffer
    call print_colored

    ; Display navigation tips
    mov eax, COLOR_WHITE
    mov dword [temp_buffer], "- Ty"
    mov dword [temp_buffer+4], "pe '"
    mov dword [temp_buffer+8], "back"
    mov dword [temp_buffer+12], "' at"
    mov dword [temp_buffer+16], " any"
    mov dword [temp_buffer+20], " pro"
    mov dword [temp_buffer+24], "mpt "
    mov dword [temp_buffer+28], "to r"
    mov dword [temp_buffer+32], "etur"
    mov dword [temp_buffer+36], "n to"
    mov dword [temp_buffer+40], " the"
    mov dword [temp_buffer+44], " men"
    mov dword [temp_buffer+48], "u"
    mov byte [temp_buffer+50], LF
    mov byte [temp_buffer+51], NULL
    mov ebx, temp_buffer
    call print_colored

    mov eax, COLOR_WHITE
    mov dword [temp_buffer], "- Pr"
    mov dword [temp_buffer+4], "ess "
    mov dword [temp_buffer+8], "'H' "
    mov dword [temp_buffer+12], "from"
    mov dword [temp_buffer+16], " the"
    mov dword [temp_buffer+20], " mai"
    mov dword [temp_buffer+24], "n me"
    mov dword [temp_buffer+28], "nu t"
    mov dword [temp_buffer+32], "o sh"
    mov dword [temp_buffer+36], "ow t"
    mov dword [temp_buffer+40], "his "
    mov dword [temp_buffer+44], "help"
    mov dword [temp_buffer+48], " scr"
    mov dword [temp_buffer+52], "een"
    mov byte [temp_buffer+56], LF
    mov byte [temp_buffer+57], NULL
    mov ebx, temp_buffer
    call print_colored

    ; -----------------------------------------------------------------
    ; Wait for user input and return to menu
    ; -----------------------------------------------------------------
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


