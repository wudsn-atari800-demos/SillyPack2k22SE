;	@com.wudsn.ide.lng.outputfoldermode=SOURCE_FOLDER
	icl "..\..\asm\Fixes.asm"

	org $2000
	m_fade_screen_out

	opt h-
	ins 'ATARIADV-Original.xex'