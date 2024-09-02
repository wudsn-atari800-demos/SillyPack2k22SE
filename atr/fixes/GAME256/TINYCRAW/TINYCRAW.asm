;	@com.wudsn.ide.lng.outputfoldermode=SOURCE_FOLDER
	icl "..\..\asm\Fixes.asm"

	opt h+
	
	m_enable_basic
	opt h-

	ins 'TINYCRAW-Original.xex',+2
	
	opt h+
	run $80
