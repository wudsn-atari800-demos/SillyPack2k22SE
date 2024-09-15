;	@com.wudsn.ide.lng.outputfoldermode=SOURCE_FOLDER
	icl "..\..\asm\Fixes.asm"

	zp = $ca	;Defined free ZP address space, 8 bytes required
	org $5a00	
	m_load_high zp "INSOMNIA-Original.xex"