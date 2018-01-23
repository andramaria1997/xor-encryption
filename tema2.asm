extern puts
extern printf

section .data
filename: db "./input.dat",0
inputlen: dd 2263
fmtstr: db "Key: %d",0xa,0

section .text
global main

; TODO: define functions and helper functions

;get length of string function:

get_length_string:

    push ebp
    mov ebp, esp
    
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    mov ebx, [ebp+8]

length:
    mov cl, byte [ebx + eax]
    cmp cl, 0
    je outloop
    inc eax
    jmp length
    
outloop:
    
    leave
    ret

;xor strings function:

xor_strings:

    push ebp
    mov ebp, esp
    
    mov ebx, [ebp+12]   ; in ebx se afla sirul
    mov edx, [ebp+8]    ; in edx se afla cheia
    
    push ebx
    call get_length_string
    pop ebx
    
    mov esi, eax        ; in esi se afla lungimea sirului si a cheii

    xor eax, eax
    xor ecx, ecx

make_xor:
    dec esi
    mov al, byte [ebx + esi]    ; caracterul din sir
    mov cl, byte [edx + esi]    ; caracterul din cheie
    xor al, cl                  ; se face xor
    mov byte [ebx + esi], al    ; se inlocuieste in sirul initial
    cmp esi, 0                  ; daca nu s-a ajuns la sfarsit, reia
    jne make_xor
    
    leave
    ret
    
; rolling xor function:

rolling_xor:

    push ebp
    mov ebp, esp
    
    mov ebx, [ebp+8]    ; se muta in ebx adresa sirului codificat
    
    push ebx
    call get_length_string  ; se calculeaza lungimea
    pop ebx
    add ebx, eax        ; se sare la sfarsitul sirului
    dec ebx
   
    xor ecx, ecx
    xor edx, edx

    ;se parcurge sirul incepand de la sfarsit:
xor_loop:
    mov cl, byte [ebx]  ; caracterul curent
    cmp cl, 0           ; conditie de iesit din loop
    je end              ; daca se intalneste caracterul null, se iese
    mov dl, byte [ebx-1]; caracterul anterior
    xor cl, dl          ; xor intre caracterul curent si cel anterior
    mov byte [ebx], cl  ; se inlocuieste in sir
    dec ebx
    jmp xor_loop
end:
    
    leave
    ret
    
; functie care converteste un string in valori hexa:
; returneaza in eax lungimea noului sir:

convert_hex_string:

    push ebp
    mov ebp, esp
    
    mov ebx, [ebp+8]    ; sirul care urmeaza sa fie convertit
    
    xor edi, edi    ; cu edi se parcurge sirul initial
    xor esi, esi    ; cu esi se parcurge noul sir formar

    
again:
    xor eax, eax
    xor ecx, ecx
    mov al, [ebx+edi]   ; se ia primul octet
    cmp al, 0           ; daca e null, se iese din loop
    je end4
    cmp al, 97          ; se verifica daca e cifra sau litera, comparand cu valoarea ascii pt 'a'
    jl over1            ; daca e cifra, se scade doar 48
    sub al, 39          
    over1:
    sub al, 48          ; daca e litera, se scade 39+48 = 87 (97 - 87 = 10, adica 'a' in hexa)
    inc edi
    mov cl, [ebx+edi]   ; se ia cel de al 2 lea octet
    cmp cl, 97          ; se converteste din ascii in hexa in acelasi mod
    jl over2
    sub cl, 39
    over2:
    sub cl, 48
    shl al, 4           ; se shifteaza primul octet cu 4 biti
    add al, cl          ; apoi se aduna cele 2 valori, astfel obsinandu-se octetul necesar
    mov byte [ebx+esi], al  ; se inlocuieste in sirul original
    inc esi
    inc edi
    jmp again
end4:
    
    mov eax, esi        ; in esi se afla lungimea noului sir
    inc esi             ; se muta in eax, pentru a fi returnata de functie
    mov byte [ebx+esi], 0       
    
    
    leave
    ret
    
; xor_hex_strings function:
    
xor_hex_strings:

    push ebp
    mov ebp, esp
    
    mov ecx, [ebp+8]
    
    push ecx                ; string 4 address
    call convert_hex_string ; conversie la valori hexa
    pop ecx
                      
    add ecx, eax            ; in eax se afla lungimea sirului convertit
    add ecx, eax            ; care este jumatate din lungimea sirului initial
    inc ecx
    push ecx                ; string 5 address
    call convert_hex_string ; conversie la valori hexa
    pop ecx
        
    sub ecx, eax
    sub ecx, eax
    dec ecx                 ; revenire la string 4
        
    push ecx                ; string 4 address
    add ecx, eax
    add ecx, eax
    inc ecx
    push ecx                ; string 5 address
    call xor_strings        ; se face xor utilizand functia de la task1    
    
    leave
    ret
    
; functia pentru decodarea in baza 32:

base32decode:

    push ebp
    mov ebp, esp
    
    mov esi, [ebp+8]
    
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    xor edx, edx
    xor edi, edi
    
    push esi
    call get_length_string
    pop esi
    
    mov edx, eax
    xor ebx, ebx
        
parcurge:    
    mov eax, dword [esi+edi]
    
    ; decodez cate 8 caractere prin 2 apeluri ale functiei convert:
    
    push eax
    call convert
    add esp, 4
         
    rol eax, 16
    mov byte [esi+ebx], ah
    inc ebx
    mov byte [esi+ebx], al
    inc ebx
    rol eax, 16
    mov cl, ah
    
    ; avand 20 biti in eax, raman 4, care se pun in partea superioara a lui cl
    
    add edi, 4
    
    mov eax, dword [esi+edi]
    push eax
    call convert
    add esp, 4
    
    ; se atasaza cei 4 biti ramasi la ceilalti 4 din cl, formand un caracter:
    
    shr eax, 12
    rol eax, 16
    add cl, al
    rol eax, 16
    

    mov byte [esi+ebx], cl
    
    inc ebx
    
    ; apoi se inlocuiesc si cei 16 biti ramasi pe sir:
    
    mov byte [esi+ebx], ah
    inc ebx
    mov byte [esi+ebx], al
    inc ebx
    
    add edi, 4
    
    cmp edi, edx
    jl parcurge
    
    mov byte [esi+ebx], 0
    
    leave
    ret
    
; functie care decodifica 4 caractere din baza 32:
    
convert:

    push ebp
    mov ebp, esp
    
    mov eax, [ebp+8]
    
    ; am scris codul de 4 ca sa fac economie de registri, nu-mi ajungeau
    ; pentru fiecare octet din eax
    ; se converteste la valoarea necesara decodificarii in baza 32
    ; in functie de ASCII:
    
    rol eax, 8
    cmp al, 61  ; 61 este codul ascii pentru '=', caz in care se pune 0
    jne peste0
    sub al, 37  ; 37 + 24 = 61 (ramane 0 in al)
    peste0:
    cmp al, 65  ; daca este cifra (cod ascii < 65 = 'A')
    jl over3    ; se scade 24
    sub al, 41  ; altfel este litera si se scade 65
    over3:
    sub al, 24

    
    rol eax, 8
    cmp al, 61
    jne peste1
    sub al, 37
    peste1:
    cmp al, 65
    jl over4
    sub al, 41
    over4:
    sub al, 24
    
    rol eax, 8
    cmp al, 61
    jne peste2
    sub al, 37
    peste2:
    cmp al, 65
    jl over5
    sub al, 41
    over5:
    sub al, 24
    
    rol eax, 8
    cmp al, 61
    jne peste3
    sub al, 37
    peste3:
    cmp al, 65
    jl over6
    sub al, 41
    over6:
    sub al, 24
    
    ; avand little endian, rearanjez octetii in ordinea in care erau in sir:
    
    rol ax, 8
    rol eax, 16
    rol ax, 8
   
    
    end5:
    
    ; aliniez cei 20 de biti obtinuti la inceputul registrului eax:
     
    shl al, 3
    shl ax, 3
    shr eax, 6
    shl ax, 1
    shr eax, 1
    shl ax, 1
    shr eax, 1
    shl ax, 1
    shl eax, 11
    
    leave
    ret
    
; functia care cauta cheia prin bruteforce:
    
bruteforce_singlebyte_xor:

    push ebp
    mov ebp, esp
    
    mov ebx, [ebp+8]
    xor eax, eax
    xor edx, edx
    xor ecx, ecx
    
; in al se incrementeaza cheia
    
xorloop:    ; se face xor pe tot sirul:
    mov cl, byte [ebx+edx]
    cmp cl, 0
    je check
    xor cl, al
    mov byte [ebx+edx], cl
    inc edx
    jmp xorloop

check:      ; se verifica daca contine 'force':
    xor edx, edx
    nope:
    mov cl, byte [ebx+edx]
    cmp cl, 0
    je nextkey
    inc edx
    cmp cl, 102     ; codul ascii pentru 'f'
    jne nope
    mov cl, byte [ebx+edx]
    cmp cl, 0
    je nextkey
    inc edx
    cmp cl, 111     ; codul ascii pentru 'o'
    jne nope
    mov cl, byte [ebx+edx]
    inc edx
    cmp cl, 0
    je nextkey
    cmp cl, 114     ; codul ascii pentru 'r'
    jne nope
    mov cl, byte [ebx+edx]
    inc edx
    cmp cl, 0
    je nextkey
    cmp cl, 99    ; codul ascii pentru 'c'
    jne nope    
    mov cl, byte [ebx+edx]
    inc edx
    cmp cl, 0
    je nextkey
    cmp cl, 101     ; codul ascii pentru 'e'
    jne nope
        
    jmp found_it    ; cand se ajunge in acest punct s-a gasit 'force' => am gasit cheia
    
nextkey:        
    
    xor edx, edx    ; se reseteaza contorul
    
restore:            ; se restaureaza sirul prin repetarea xorului:
    mov cl, byte [ebx+edx]
    cmp cl, 0
    je go_on
    xor cl, al
    mov byte [ebx+edx], cl
    inc edx
    jmp restore

go_on:              ; apoi se incrementeaza cheia, se reseteaza contorul si se reiau pasii
     inc eax
     xor edx, edx
     jmp xorloop   


found_it:

    leave
    ret

main:
    mov ebp, esp; for correct debugging
    push ebp
    mov ebp, esp
    sub esp, 2300
    
    ; fd = open("./input.dat", O_RDONLY);
    mov eax, 5
    mov ebx, filename
    xor ecx, ecx
    xor edx, edx
    int 0x80
    
	; read(fd, ebp-2300, inputlen);
	mov ebx, eax
	mov eax, 3
	lea ecx, [ebp-2300]
	mov edx, [inputlen]
	int 0x80

	; close(fd);
	mov eax, 6
	int 0x80

	; all input.dat contents are now in ecx (address on stack)

	; TASK 1: Simple XOR between two byte streams
	; TODO: compute addresses on stack for str1 and str2
	; TODO: XOR them byte by byte

	push ecx
        call get_length_string
	pop ecx

        push ecx    ; adresa sirului
        add ecx, eax
        inc ecx
        push ecx    ; adresa cheii
        call xor_strings ; apelul functiei xor
        pop ecx    
        pop ecx     ; restaurarea sirului
        
	; Print the first resulting string

        push ecx
        call puts
        pop ecx

	; TASK 2: Rolling XOR
	; TODO: compute address on stack for str3
	; TODO: implement and apply rolling_xor function

        ; in eax se afla lungimea sirului 1 (si 2, fiind de lungimi egale)
        ; trecem la sirul 3, sarind peste 1 si 2:
                        
        add ecx, eax
        add ecx, eax

	push ecx
	call rolling_xor
	pop ecx

	; Print the second resulting string

	push ecx
	call puts
	pop ecx

	
	; TASK 3: XORing strings represented as hex strings
	; TODO: compute addresses on stack for strings 4 and 5
	; TODO: implement and apply xor_hex_strings

        push ecx
        call get_length_string
        pop ecx
        add ecx, eax

        inc ecx
        
        push ecx
        call get_length_string
        pop ecx
        
        push eax ; salvez lungimea sirului pentru a determina adresa necesara urmatorului task

        push ecx
        call xor_hex_strings
        pop ecx
        
        push ecx
        call puts
        pop ecx
        
	
	; TASK 4: decoding a base32-encoded string
	; TODO: compute address on stack for string 6
	; TODO: implement and apply base32decode

        ; M-A INNEBUNIT TASK UL ASTA !!!!!!

        pop eax

        add ecx, eax
        add ecx, eax
        inc ecx
        inc ecx
        
        push ecx
        call get_length_string
        pop ecx
        
        push eax ; salvez lungimea sirului pentru a determina adresa necesara urmatorului task
        
        push ecx
        call base32decode
        pop ecx
        
	; Print the fourth string
        
        push ecx
        call puts
        pop ecx


	; TASK 5: Find the single-byte key used in a XOR encoding
	; TODO: determine address on stack for string 7
	; TODO: implement and apply bruteforce_singlebyte_xor

        pop eax
        add ecx, eax
        inc ecx
        
        push ecx
        call bruteforce_singlebyte_xor
        pop ecx
        
        push eax
        push ecx
        call puts
        pop ecx
        pop eax

        push ecx
        push eax
        push fmtstr
        call printf
        add esp, 4
        pop eax
        pop ecx

	; TASK 6: Break substitution cipher
	; TODO: determine address on stack for string 8
	; TODO: implement break_substitution

        ;push ecx
        ;call get_length_string
        ;pop ecx       
        ;add ecx, eax
        ;inc ecx
        
        ;push ecx
        ;call puts
        ;pop ecx
        
        	;push substitution_table_addr
	;push addr_str8
	;call break_substitution
	;add esp, 8

	; Print final solution (after some trial and error)
	;push addr_str8
	;call puts
	;add esp, 4

	; Print substitution table
	;push substitution_table_addr
	;call puts
	;add esp, 4

	; Phew, finally done
    xor eax, eax
    leave
    ret
