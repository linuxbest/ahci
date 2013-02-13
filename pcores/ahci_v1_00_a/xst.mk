# Makefile rules for synthesizing a project using XST
$(WD)/%.scr $(WD)/%.prj: $(VERILOGFILES)
	rm -f $(WD)/$*.prj; touch $(WD)/$*.prj
	if test -f /usr/bin/cygpath;then PATHCONV="cygpath -w";else PATHCONV=echo;fi;\
		for i in $(VERILOGFILES); do echo "verilog work \"`$$PATHCONV $$PWD/$$i`\"" >> $(WD)/$*.prj; done
	echo 'set -tmpdir tmpdir' > $(WD)/$*.scr
	echo 'set -xsthdpdir xst' >> $(WD)/$*.scr
	echo 'run'                                                              \
		'-opt_mode speed'						\
		'-netlist_hierarchy as_optimized'                               \
		'-opt_level 1'							\
		'-p $(PART)'						\
		'-top $(TOPMODULE)'						\
		'-ifmt mixed'                                                   \
		'-ifn $*.prj'							\
		'-ofn $*'						\
		'-ofmt NGC'                                                     \
		'-hierarchy_separator /'					\
		'-iobuf $(IOBUFINSERTION)' >> $(WD)/$*.scr


$(WD)/%.ngc: $(WD)/%.scr $(WD)/%.prj
	rm -rf $(WD)/tmpdir
	mkdir $(WD)/tmpdir
	rm -rf $(WD)/xst
	mkdir $(WD)/xst
	cd $(WD); $(NICE) xst -ifn $*.scr -ofn $*.syr

$(WD)/%.ngd: $(WD)/%.ngc $(UCFFILE)
	rm -rf $(WD)/_ngo
	mkdir $(WD)/_ngo
	cd $(WD); $(NICE) ngdbuild -sd . -dd _ngo -nt timestamp -p $(PART) -uc ../$(UCFFILE) $*.ngc  $*.ngd

