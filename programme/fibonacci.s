# Fibonacci-Zahlen fuer die RV32I-CPU in Digital
#
#   - berechnet F(1) .. F(24), legt sie ab Adresse 0 im Datenspeicher ab
#     und gibt jede Zahl auf dem Ausgaberegister OUT (Adresse 0x80000000) aus
#   - summiert das Feld anschliessend in einem Unterprogramm wieder auf
#   - Endergebnis auf OUT: 121392 (0x1DA30), danach haelt ebreak die CPU an

        .equ    ANZAHL, 24

        .text
        .globl  _start
_start:
        li      sp, 0x4000          # Stapelzeiger auf das Ende des RAM
        li      s0, 0x80000000      # Adresse des Ausgaberegisters OUT
        li      s1, 0               # Zeiger auf das Feld im RAM
        li      t0, ANZAHL          # Schleifenzaehler
        li      a0, 0               # F(n-1)
        li      a1, 1               # F(n)

fib:    sw      a1, 0(s1)           # im RAM ablegen
        sw      a1, 0(s0)           # und ausgeben
        add     t1, a0, a1          # F(n+1) = F(n-1) + F(n)
        mv      a0, a1
        mv      a1, t1
        addi    s1, s1, 4
        addi    t0, t0, -1
        bnez    t0, fib

        li      a0, 0               # a0 = Anfang des Feldes
        li      a1, ANZAHL          # a1 = Anzahl der Elemente
        call    summe
        sw      a0, 0(s0)           # Summe ausgeben
        ebreak                      # CPU anhalten

# int summe(int *feld, int anzahl)
summe:  addi    sp, sp, -8
        sw      ra, 4(sp)
        sw      s2, 0(sp)
        li      s2, 0
        slli    a1, a1, 2           # Anzahl -> Bytes
        add     a1, a1, a0          # a1 = Endadresse
1:      bgeu    a0, a1, 2f
        lw      t0, 0(a0)
        add     s2, s2, t0
        addi    a0, a0, 4
        j       1b
2:      mv      a0, s2
        lw      s2, 0(sp)
        lw      ra, 4(sp)
        addi    sp, sp, 8
        ret
