# Selbsttest fuer die RV32I-CPU in Digital
#
# Prueft jeden unterstuetzten Befehl mit bekannten Ergebnissen.
#   alles in Ordnung:  OUT = 0x00C0FFEE
#   Fehler:            OUT = Nummer des fehlgeschlagenen Tests (steht in s1)
# Danach haelt ebreak die CPU an.

        .macro  TEST_RR op, nr, erwartet, a, b
        li      s1, \nr
        li      t0, \a
        li      t1, \b
        \op     t2, t0, t1
        li      t3, \erwartet
        bne     t2, t3, fehler
        .endm

        .macro  TEST_IMM op, nr, erwartet, a, imm
        li      s1, \nr
        li      t0, \a
        \op     t2, t0, \imm
        li      t3, \erwartet
        bne     t2, t3, fehler
        .endm

        # Sprung wird erwartet
        .macro  TEST_BR_JA op, nr, a, b
        li      s1, \nr
        li      t0, \a
        li      t1, \b
        \op     t0, t1, 1f
        j       fehler
1:
        .endm

        # Sprung wird nicht erwartet
        .macro  TEST_BR_NEIN op, nr, a, b
        li      s1, \nr
        li      t0, \a
        li      t1, \b
        \op     t0, t1, fehler
        .endm

        .text
        .globl  _start
_start:
        li      s0, 0x80000000      # Adresse des Ausgaberegisters OUT

        # ---- Register-Register-Befehle
        TEST_RR add,  1, 0x00000005, 0x00000002, 0x00000003
        TEST_RR add,  2, 0x00000000, 0xFFFFFFFF, 0x00000001
        TEST_RR add,  3, 0x80000000, 0x7FFFFFFF, 0x00000001
        TEST_RR sub,  4, 0xFFFFFFFF, 0x00000002, 0x00000003
        TEST_RR sub,  5, 0x7FFFFFFF, 0x80000000, 0x00000001
        TEST_RR sub,  6, 0x00000000, 0x12345678, 0x12345678
        TEST_RR sll,  7, 0x80000000, 0x00000001, 31
        TEST_RR sll,  8, 0x23456780, 0x12345678, 4
        TEST_RR sll,  9, 0x12345678, 0x12345678, 32     # nur die unteren 5 Bit zaehlen
        TEST_RR slt, 10, 1, 0xFFFFFFFF, 0x00000001      # -1 < 1
        TEST_RR slt, 11, 0, 0x00000001, 0xFFFFFFFF
        TEST_RR slt, 12, 1, 0x80000000, 0x7FFFFFFF
        TEST_RR slt, 13, 0, 0x00000007, 0x00000007
        TEST_RR sltu, 14, 0, 0xFFFFFFFF, 0x00000001
        TEST_RR sltu, 15, 1, 0x00000001, 0xFFFFFFFF
        TEST_RR sltu, 16, 0, 0x80000000, 0x7FFFFFFF
        TEST_RR xor, 17, 0xFF00FF00, 0xF0F0F0F0, 0x0FF00FF0
        TEST_RR srl, 18, 0x00000001, 0x80000000, 31
        TEST_RR srl, 19, 0x08765432, 0x87654321, 4
        TEST_RR sra, 20, 0xFFFFFFFF, 0x80000000, 31
        TEST_RR sra, 21, 0xF8765432, 0x87654321, 4
        TEST_RR sra, 22, 0x07654321, 0x76543210, 4
        TEST_RR or,  23, 0xFFF0FFF0, 0xF0F0F0F0, 0x0FF00FF0
        TEST_RR and, 24, 0x00F000F0, 0xF0F0F0F0, 0x0FF00FF0

        # ---- Befehle mit Direktwert
        TEST_IMM addi, 30, 0x00000800, 0x00000001, 2047
        TEST_IMM addi, 31, 0xFFFFF801, 0x00000001, -2048
        TEST_IMM addi, 32, 0x7FFFFFFF, 0x80000000, -1
        TEST_IMM addi, 33, 0x00000400, 0x00000000, 1024     # Bit 30 des Befehls gesetzt, trotzdem Addition
        TEST_IMM slti, 34, 1, 0xFFFFFFFF, 0
        TEST_IMM slti, 35, 0, 0x00000000, -1
        TEST_IMM slti, 36, 1, 0x000003FF, 1024
        TEST_IMM sltiu, 37, 1, 0x00000000, -1               # Vergleich mit 0xFFFFFFFF
        TEST_IMM sltiu, 38, 0, 0xFFFFFFFF, 1
        TEST_IMM sltiu, 39, 1, 0x000003FF, 1024
        TEST_IMM xori, 40, 0x0F0F0F0F, 0xF0F0F0F0, -1
        TEST_IMM xori, 41, 0x00000755, 0x00000012, 0x747
        TEST_IMM ori,  42, 0xFFFFFFF0, 0xF0F0F0F0, -16
        TEST_IMM ori,  43, 0x000007F7, 0x00000012, 0x7F5
        TEST_IMM andi, 44, 0xF0F0F0F0, 0xF0F0F0F0, -16
        TEST_IMM andi, 45, 0x00000410, 0x00000F12, 0x4F0
        TEST_IMM slli, 46, 0x80000000, 0x00000001, 31
        TEST_IMM slli, 47, 0x2468ACF0, 0x12345678, 1
        TEST_IMM srli, 48, 0x00000001, 0x80000000, 31
        TEST_IMM srli, 49, 0x08765432, 0x87654321, 4
        TEST_IMM srai, 50, 0xFFFFFFFF, 0x80000000, 31
        TEST_IMM srai, 51, 0xF8765432, 0x87654321, 4
        TEST_IMM srai, 52, 0x00000000, 0x7FFFFFFF, 31

        # ---- lui, auipc
        li      s1, 60
        lui     t2, 0xABCDE
        li      t3, 0xABCDE000
        bne     t2, t3, fehler
        li      s1, 61
        lui     t2, 0xFFFFF
        li      t3, 0xFFFFF000
        bne     t2, t3, fehler
        li      s1, 62
1:      auipc   t2, 0
        la      t3, 1b
        bne     t2, t3, fehler
        li      s1, 63
2:      auipc   t2, 0x12345
        la      t3, 2b
        li      t4, 0x12345000
        add     t3, t3, t4
        bne     t2, t3, fehler

        # ---- bedingte Spruenge
        TEST_BR_JA   beq,  70, 5, 5
        TEST_BR_NEIN beq,  71, 5, 6
        TEST_BR_JA   bne,  72, 5, 6
        TEST_BR_NEIN bne,  73, 5, 5
        TEST_BR_JA   blt,  74, -1, 1
        TEST_BR_NEIN blt,  75, 1, -1
        TEST_BR_NEIN blt,  76, 3, 3
        TEST_BR_JA   bge,  77, 1, -1
        TEST_BR_JA   bge,  78, 3, 3
        TEST_BR_NEIN bge,  79, -1, 1
        TEST_BR_JA   bltu, 80, 1, -1
        TEST_BR_NEIN bltu, 81, -1, 1
        TEST_BR_NEIN bltu, 82, 3, 3
        TEST_BR_JA   bgeu, 83, -1, 1
        TEST_BR_JA   bgeu, 84, 3, 3
        TEST_BR_NEIN bgeu, 85, 1, -1

        # Sprung rueckwaerts: Schleife mit 5 Durchlaeufen
        li      s1, 86
        li      t0, 0
        li      t1, 5
3:      addi    t0, t0, 1
        blt     t0, t1, 3b
        bne     t0, t1, fehler

        # ---- jal, jalr
        li      s1, 90
        la      t3, 4f
        jal     t2, 5f
4:      j       fehler
5:      bne     t2, t3, fehler      # Rueckkehradresse pruefen

        li      s1, 91
        la      t4, 7f
        la      t3, 6f
        jalr    t2, 0(t4)
6:      j       fehler
7:      bne     t2, t3, fehler

        li      s1, 92              # jalr mit Versatz, Bit 0 der Zieladresse wird geloescht
        la      t4, 9f
        addi    t4, t4, -7
        la      t3, 8f
        jalr    t2, 8(t4)
8:      j       fehler
9:      bne     t2, t3, fehler

        li      s1, 93              # Unterprogrammaufruf
        li      a0, 20
        call    verdopple
        li      t3, 40
        bne     a0, t3, fehler

        # ---- lw, sw
        li      s1, 100
        li      t0, 0x100
        li      t1, 0xDEADBEEF
        sw      t1, 0(t0)
        lw      t2, 0(t0)
        bne     t2, t1, fehler
        li      s1, 101
        li      t1, 0x12345678
        sw      t1, 2044(t0)
        lw      t2, 2044(t0)
        bne     t2, t1, fehler
        li      s1, 102
        li      t0, 0x200
        li      t1, 0x0BADF00D
        sw      t1, -4(t0)
        lw      t2, -4(t0)
        bne     t2, t1, fehler
        li      s1, 103
        li      t0, 0x1FC
        lw      t2, 0(t0)           # gleiche Speicherzelle ueber andere Basisadresse
        bne     t2, t1, fehler
        li      s1, 104
        li      t0, 0x100
        lw      t2, 0(t0)           # der erste Wert steht noch da
        li      t1, 0xDEADBEEF
        bne     t2, t1, fehler

        # ---- x0 bleibt null
        li      s1, 110
        li      t0, 123
        add     x0, t0, t0
        bne     x0, zero, fehler
        li      s1, 111
        addi    x0, x0, 55
        lui     x0, 0x12345
        jal     x0, 10f
10:     add     t2, x0, x0
        bne     t2, zero, fehler

        # ---- fertig
        li      t0, 0x00C0FFEE
        sw      t0, 0(s0)
        ebreak

fehler: sw      s1, 0(s0)
        ebreak

verdopple:
        add     a0, a0, a0
        ret
