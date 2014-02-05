DCC = dmd
DFLAGS = -w
LIBS = -L-lcurl

FILES = src/example.d src/controller/diffbot.d src/model/exception.d src/controller/httphandle.d 

diffbot: $(FILES)
	
	@$(DCC) $(DFLAGS) $(LIBS) $(FILES) -ofdiffbot -release

documentation:

	@$(DCC) $(DFLAGS) $(LIBS) $(FILES) -ofdiffbot -Dddocs

unittests: $(FILES)

	@$(DCC) $(DFLAGS) $(LIBS) $(FILES) -unittest -ofunittests -release

coverage:

	@$(DCC) $(DFLAGS) $(LIBS) $(FILES) -ofcoverage -cov -release

clean:

	@rm -f *.o *.lst docs/*.html diffbot unittests coverage
