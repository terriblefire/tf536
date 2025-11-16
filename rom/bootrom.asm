
	dc.w	$1111
; ---------------------------------------------------------------------------
entry:
	lea     ($DFF000).l,a4
        move.w  #$7FFF,d0
        move.w  d0,$9A(a4)
        move.w  d0,$9C(a4)
        move.w  d0,$96(a4)
	
	move.w  #$200,$100(a4)
        move.w  #0,$110(a4)
        move.w  #0,$180(a4)
        move.w  #0,d0
	
loc_F8002E:                             ; CODE XREF: ROM:00F80042↓j
        move.w  d0,$180(a4)
        move.w  #$32,d1
	
loc_F80036:                             ; CODE XREF: ROM:loc_F80036↓j
        dbf     d1,loc_F80036
        addi.w  #1,d0
        cmp.w   #$FFF,d0
        bne.w   loc_F8002E

end:	

	jmp	(a5)


	dc.b	"$VER:"
	incbin	"version.inc"
	
	CNOP	0,128
