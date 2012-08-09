GHCFLAGS=-Wall -XNoCPP -fno-warn-name-shadowing -XHaskell98 -O2
HLINTFLAGS=-XHaskell98 -XNoCPP -i 'Use camelCase' -i 'Use String' -i 'Use head' -i 'Use string literal' -i 'Use list comprehension' --utf8
VERSION=0.1

.PHONY: all shell clean doc install debian

all: report.html doc dist/build/libHSwai-dispatch-$(VERSION).a dist/wai-dispatch-$(VERSION).tar.gz

install: dist/build/libHSwai-dispatch-$(VERSION).a
	cabal install

shell:
	ghci $(GHCFLAGS)

report.html: Network/Wai/Dispatch.hs
	-hlint $(HLINTFLAGS) --report $^

doc: dist/doc/html/wai-dispatch/index.html README

README: wai-dispatch.cabal
	tail -n+$$(( `grep -n ^description: $^ | head -n1 | cut -d: -f1` + 1 )) $^ > .$@
	head -n+$$(( `grep -n ^$$ .$@ | head -n1 | cut -d: -f1` - 1 )) .$@ > $@
	-printf ',s/        //g\n,s/^.$$//g\n,s/\\\\\\//\\//g\nw\nq\n' | ed $@
	$(RM) .$@

dist/doc/html/wai-dispatch/index.html: dist/setup-config Network/Wai/Dispatch.hs
	cabal haddock --hyperlink-source

dist/setup-config: wai-dispatch.cabal
	cabal configure

clean:
	find -name '*.o' -o -name '*.hi' | xargs $(RM)
	$(RM) -r dist

dist/build/libHSwai-dispatch-$(VERSION).a: dist/setup-config Network/Wai/Dispatch.hs
	cabal build --ghc-options="$(GHCFLAGS)"

dist/wai-dispatch-$(VERSION).tar.gz: README dist/setup-config Network/Wai/Dispatch.hs
	cabal check
	cabal sdist
