; =============================================================================
; File Operations Module for Library Management System
; =============================================================================
;
; This module handles all file operations for saving and loading library data.
; It uses a binary file format for efficient storage and retrieval of the
; library database and implements file format validation for data integrity.
;
; The module implements:
; - Saving library data to file
; - Loading library data from file
; - Data format validation with file signature
; - Sample data initialization for first-time users
; - Comprehensive error handling for file operations
; =============================================================================

; Function: save_data
; Purpose: Save library data to file
; Input: None
; Output: None (returns to main menu)
; Registers: All preserved
save_data:
    ; Save registers we'll use
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Display framed title
    mov eax, save_title
    call display_framed_title

    ; -----------------------------------------------------------------
    ; Open file for writing
    ; -----------------------------------------------------------------
    ; Use sys_creat to create or truncate file
    mov eax, 8                  ; System call (sys_creat)
    mov ebx, database_filename  ; Filename
    mov ecx, 0644               ; File permissions (rw-r--r--)
    int 80h

    ; Check if file was opened successfully
    test eax, eax
    js .file_error              ; Jump if sign flag set (negative result)

    ; Store file descriptor
    mov [file_descriptor], eax

    ; -----------------------------------------------------------------
    ; Write file header/signature
    ; -----------------------------------------------------------------
    ; This helps identify our file format and detect corruption
    mov eax, 4                  ; System call (sys_write)
    mov ebx, [file_descriptor]  ; File descriptor
    mov ecx, file_header        ; Buffer (signature)
    mov edx, file_header_len    ; Length
    int 80h

    ; Check if write was successful
    test eax, eax
    js .write_error             ; Jump if sign flag set (error)
    cmp eax, file_header_len    ; Check if all bytes were written
    jne .write_error

    ; -----------------------------------------------------------------
    ; Write book count
    ; -----------------------------------------------------------------
    mov eax, 4                  ; System call (sys_write)
    mov ebx, [file_descriptor]  ; File descriptor
    mov ecx, book_count         ; Buffer (book count)
    mov edx, 4                  ; Length (4 bytes for int)
    int 80h

    ; Check if write was successful
    test eax, eax
    js .write_error
    cmp eax, 4
    jne .write_error

    ; -----------------------------------------------------------------
    ; Write book records
    ; -----------------------------------------------------------------
    ; Loop through all books and write them to file
    mov ecx, 0                  ; Book index counter

.write_loop:
    ; Check if we've written all books
    cmp ecx, [book_count]
    jge .write_done

    ; Calculate address of current book
    push ecx
    mov eax, BOOK_SIZE
    mul ecx                     ; EAX = ecx * BOOK_SIZE

    ; Write book record
    mov edx, BOOK_SIZE          ; Length of record
    add eax, books_db           ; Address of book record
    mov ecx, eax                ; Buffer to write
    mov eax, 4                  ; System call (sys_write)
    mov ebx, [file_descriptor]  ; File descriptor
    int 80h

    ; Check if write was successful
    test eax, eax
    js .write_error
    cmp eax, BOOK_SIZE
    jne .write_error

    ; Move to next book
    pop ecx
    inc ecx
    jmp .write_loop

.write_done:
    ; -----------------------------------------------------------------
    ; Close file and display success message
    ; -----------------------------------------------------------------
    ; Close file
    mov eax, 6                  ; System call (sys_close)
    mov ebx, [file_descriptor]  ; File descriptor
    int 80h

    ; Display success message
    mov eax, COLOR_GREEN
    mov ebx, save_success
    call print_colored
    jmp .finish

.file_error:
    ; Display file error message
    mov eax, COLOR_RED
    mov ebx, file_error_msg
    call print_colored
    jmp .finish

.write_error:
    ; Close file
    mov eax, 6                  ; System call (sys_close)
    mov ebx, [file_descriptor]  ; File descriptor
    int 80h

    ; Display write error message
    mov eax, COLOR_RED
    mov ebx, write_error_msg
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

; Function: load_data
; Purpose: Load library data from file
; Input: None
; Output: None (returns to main menu)
; Registers: All preserved
load_data:
    ; Save registers we'll use
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Display framed title
    mov eax, load_title
    call display_framed_title

    ; -----------------------------------------------------------------
    ; Open file for reading
    ; -----------------------------------------------------------------
    mov eax, 5                  ; System call (sys_open)
    mov ebx, database_filename  ; Filename
    mov ecx, 0                  ; O_RDONLY (read-only)
    int 80h

    ; Check if file was opened successfully
    test eax, eax
    js .file_error

    ; Store file descriptor
    mov [file_descriptor], eax

    ; -----------------------------------------------------------------
    ; Read and verify file header
    ; -----------------------------------------------------------------
    ; Read header
    mov eax, 3                  ; System call (sys_read)
    mov ebx, [file_descriptor]  ; File descriptor
    mov ecx, file_buffer        ; Buffer
    mov edx, file_header_len    ; Length
    int 80h

    ; Check if read was successful
    test eax, eax
    js .read_error
    cmp eax, file_header_len
    jne .format_error

    ; Verify header matches our signature
    mov esi, file_buffer
    mov edi, file_header
    mov ecx, file_header_len
    cld                         ; Clear direction flag (forward)
    repe cmpsb                  ; Compare bytes
    jne .format_error

    ; -----------------------------------------------------------------
    ; Read book count
    ; -----------------------------------------------------------------
    mov eax, 3                  ; System call (sys_read)
    mov ebx, [file_descriptor]  ; File descriptor
    mov ecx, book_count         ; Buffer for book count
    mov edx, 4                  ; Length (4 bytes for int)
    int 80h

    ; Check if read was successful
    test eax, eax
    js .read_error
    cmp eax, 4
    jne .format_error

    ; Validate book count is reasonable
    mov eax, [book_count]
    test eax, eax
    jl .format_error            ; Negative count is invalid
    cmp eax, MAX_BOOKS
    jg .format_error            ; Exceeding max book count is invalid

    ; -----------------------------------------------------------------
    ; Read book records
    ; -----------------------------------------------------------------
    ; Loop through all books and read them from file
    mov ecx, 0                  ; Book index counter

.read_loop:
    ; Check if we've read all books
    cmp ecx, [book_count]
    jge .read_done

    ; Calculate address of current book
    push ecx
    mov eax, BOOK_SIZE
    mul ecx                     ; EAX = ecx * BOOK_SIZE

    ; Read book record
    mov edx, BOOK_SIZE          ; Length of record
    add eax, books_db           ; Address to store book record
    mov ecx, eax                ; Buffer to read into
    mov eax, 3                  ; System call (sys_read)
    mov ebx, [file_descriptor]  ; File descriptor
    int 80h

    ; Check if read was successful
    test eax, eax
    js .read_error
    cmp eax, BOOK_SIZE
    jne .format_error

    ; Move to next book
    pop ecx
    inc ecx
    jmp .read_loop

.read_done:
    ; -----------------------------------------------------------------
    ; Close file and update statistics
    ; -----------------------------------------------------------------
    ; Close file
    mov eax, 6                  ; System call (sys_close)
    mov ebx, [file_descriptor]  ; File descriptor
    int 80h

    ; Update statistics
    call update_statistics

    ; Display success message
    mov eax, COLOR_GREEN
    mov ebx, load_success
    call print_colored
    jmp .finish

.file_error:
    ; Display file error message
    mov eax, COLOR_RED
    mov ebx, file_error_msg
    call print_colored
    jmp .finish

.read_error:
    ; Close file
    mov eax, 6                  ; System call (sys_close)
    mov ebx, [file_descriptor]  ; File descriptor
    int 80h

    ; Display read error message
    mov eax, COLOR_RED
    mov ebx, read_error_msg
    call print_colored
    jmp .finish

.format_error:
    ; Close file
    mov eax, 6                  ; System call (sys_close)
    mov ebx, [file_descriptor]  ; File descriptor
    int 80h

    ; Display format error message
    mov eax, COLOR_RED
    mov ebx, format_error_msg
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

; Function: initialize_sample_data
; Purpose: Initialize library with sample books for new users
; Input: None
; Output: Sample books added to database if it's empty
; Registers: All preserved
initialize_sample_data:
    ; Save registers we'll use
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Check if we already have books (don't overwrite existing data)
    mov eax, [book_count]
    test eax, eax
    jnz .done

    ; -----------------------------------------------------------------
    ; Book 1: Programming in Assembly (Textbook)
    ; -----------------------------------------------------------------
    ; Set book category
    mov dword [temp_book_category], CAT_TEXTBOOK

    ; Set book ID: 10001
    mov dword [temp_book_id], "1000"
    mov byte [temp_book_id+4], "1"
    mov byte [temp_book_id+5], NULL

    ; Set book title: Programming in Assembly
    mov esi, temp_book_title
    mov dword [esi], "Prog"
    mov dword [esi+4], "ramm"
    mov dword [esi+8], "ing "
    mov dword [esi+12], "in A"
    mov dword [esi+16], "ssem"
    mov dword [esi+20], "bly"
    mov byte [esi+24], NULL

    ; Set author: John Smith
    mov esi, temp_book_author
    mov dword [esi], "John"
    mov dword [esi+4], " Smi"
    mov dword [esi+8], "th"
    mov byte [esi+10], NULL

    ; Set quantity and issued count
    mov dword [temp_book_quantity], 5
    mov dword [temp_book_issued], 0

    ; Add the book to database
    call store_book

    ; -----------------------------------------------------------------
    ; Book 2: Introduction to Algorithms (Textbook)
    ; -----------------------------------------------------------------
    ; Set book category
    mov dword [temp_book_category], CAT_TEXTBOOK

    ; Set book ID: 10002
    mov dword [temp_book_id], "1000"
    mov byte [temp_book_id+4], "2"
    mov byte [temp_book_id+5], NULL

    ; Set book title: Introduction to Algorithms
    mov esi, temp_book_title
    mov dword [esi], "Intr"
    mov dword [esi+4], "oduc"
    mov dword [esi+8], "tion"
    mov dword [esi+12], " to "
    mov dword [esi+16], "Algo"
    mov dword [esi+20], "rith"
    mov dword [esi+24], "ms"
    mov byte [esi+26], NULL

    ; Set author: Thomas Cormen
    mov esi, temp_book_author
    mov dword [esi], "Thom"
    mov dword [esi+4], "as C"
    mov dword [esi+8], "orme"
    mov byte [esi+12], "n"
    mov byte [esi+13], NULL

    ; Set quantity and issued count
    mov dword [temp_book_quantity], 3
    mov dword [temp_book_issued], 1

    ; Add the book to database
    call store_book

    ; -----------------------------------------------------------------
    ; Book 3: The Great Gatsby (Fiction)
    ; -----------------------------------------------------------------
    ; Set book category
    mov dword [temp_book_category], CAT_FICTION

    ; Set book ID: 20001
    mov dword [temp_book_id], "2000"
    mov byte [temp_book_id+4], "1"
    mov byte [temp_book_id+5], NULL

    ; Set book title: The Great Gatsby
    mov esi, temp_book_title
    mov dword [esi], "The "
    mov dword [esi+4], "Grea"
    mov dword [esi+8], "t Ga"
    mov dword [esi+12], "tsby"
    mov byte [esi+16], NULL

    ; Set author: F. Scott Fitzgerald
    mov esi, temp_book_author
    mov dword [esi], "F. S"
    mov dword [esi+4], "cott"
    mov dword [esi+8], " Fit"
    mov dword [esi+12], "zger"
    mov dword [esi+16], "ald"
    mov byte [esi+19], NULL

    ; Set quantity and issued count
    mov dword [temp_book_quantity], 4
    mov dword [temp_book_issued], 2

    ; Add the book to database
    call store_book

    ; -----------------------------------------------------------------
    ; Book 4: Science Today (Magazine)
    ; -----------------------------------------------------------------
    ; Set book category
    mov dword [temp_book_category], CAT_MAGAZINE

    ; Set book ID: 30001
    mov dword [temp_book_id], "3000"
    mov byte [temp_book_id+4], "1"
    mov byte [temp_book_id+5], NULL

    ; Set book title: Science Today
    mov esi, temp_book_title
    mov dword [esi], "Scie"
    mov dword [esi+4], "nce "
    mov dword [esi+8], "Toda"
    mov byte [esi+12], "y"
    mov byte [esi+13], NULL

    ; Set author: Various Authors
    mov esi, temp_book_author
    mov dword [esi], "Vari"
    mov dword [esi+4], "ous "
    mov dword [esi+8], "Auth"
    mov dword [esi+12], "ors"
    mov byte [esi+15], NULL

    ; Set quantity and issued count
    mov dword [temp_book_quantity], 10
    mov dword [temp_book_issued], 0

    ; Add the book to database
    call store_book

    ; -----------------------------------------------------------------
    ; Book 5: History of Computing (Non-fiction)
    ; -----------------------------------------------------------------
    ; Set book category
    mov dword [temp_book_category], CAT_NONFICTION

    ; Set book ID: 40001
    mov dword [temp_book_id], "4000"
    mov byte [temp_book_id+4], "1"
    mov byte [temp_book_id+5], NULL

    ; Set book title: History of Computing
    mov esi, temp_book_title
    mov dword [esi], "Hist"
    mov dword [esi+4], "ory "
    mov dword [esi+8], "of C"
    mov dword [esi+12], "ompu"
    mov dword [esi+16], "ting"
    mov byte [esi+20], NULL

    ; Set author: Alan Turing
    mov esi, temp_book_author
    mov dword [esi], "Alan"
    mov dword [esi+4], " Tur"
    mov dword [esi+8], "ing"
    mov byte [esi+11], NULL

    ; Set quantity and issued count
    mov dword [temp_book_quantity], 2
    mov dword [temp_book_issued], 1

    ; Add the book to database
    call store_book

    ; -----------------------------------------------------------------
    ; Update statistics after adding sample data
    ; -----------------------------------------------------------------
    call update_statistics

.done:
    ; Restore registers
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
