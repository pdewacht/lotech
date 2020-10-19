	.386

        public _amis_header
        public _amis_id
        public _amis_handler

        public _emm386_table
        public _qemm_handler

        extern _config : near


cmp_ah  macro
        db 0x80, 0xFC
        endm


        _TEXT segment word use16 public 'CODE'


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; AMIS API IMPLEMENTATION


_amis_header:
        db 'SERDACO '           ;8 bytes: manufacturer
        db 'LOTECH  '           ;8 bytes: product
        db 0                    ;no description
;;; Configuration pointer immediately follows AMIS header
        dw _config


;;; IBM Interrupt Sharing Protocol header
iisp_header macro chain
        jmp short $+0x12
chain:  dd 0
        dw 0x424B               ;signature
        db 0                    ;flags
        jmp short _retf         ;hardware reset routine
        db 7 dup (0)            ;unused/zero
        endm


_amis_handler:
        iisp_header amis_next_handler
        cmp_ah
_amis_id: db 0xFF
        je @@amis_match
        jmp dword ptr cs:amis_next_handler
@@amis_match:
        test al, al
        je @@amis_install_check
        cmp al, 4
        je @@amis_hook_table
        xor al, al
        iret
@@amis_install_check:
        mov al, 0xFF
        mov cx, (VERSION_MAJOR * 256 + VERSION_MINOR)
        mov dx, cs
        mov di, offset _amis_header
        iret
@@amis_hook_table:
        mov dx, cs
        mov bx, amis_hook_table
        iret


amis_hook_table:
        db 0x2D
        dw _amis_handler


_retf:
        retf


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; EMM386 GLUE CODE


        even
_emm386_table:
        dw 0x0C0, tnd_emulate
        dw 0x0C1, tnd_emulate
        dw 0x1E0, tnd_emulate
        dw 0x1E1, tnd_emulate
        dw 0x205, tnd_emulate


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; QEMM GLUE CODE


_qemm_handler:
        iisp_header qemm_next_handler
        cmp dx, 0x0C0
        je tnd_emulate
        cmp dx, 0x0C1
        je tnd_emulate
        cmp dx, 0x1E0
        je tnd_emulate
        cmp dx, 0x1E1
        je tnd_emulate
        cmp dx, 0x205
        je tnd_emulate
        jmp dword ptr cs:qemm_next_handler


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; EMULATION CODE


tnd_emulate:
        test cl, 4
        je tnd_ignore

        push dx
        mov dx, 0x2C0
        out dx, al
        pop dx

tnd_ignore:
        clc
        retf


        _TEXT ends
        end
