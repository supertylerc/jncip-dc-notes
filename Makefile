# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
SOURCEDIR     = .
BUILDDIR      = _build

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile

prepare:
	mv docs/jncip-dc-notes.pdf ./jncip-dc-notes.pdf

clean:
	rm -rf _build/*
	rm -rf docs/*
html:
	@$(SPHINXBUILD) -M html "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
	mv _build/html/* docs/
	mv docs/_static docs/static
	for i in `ls docs/*.html`; do sed -i -e 's/_static/static/g' $$i; done
	for i in `ls docs/*.html`; do sed -i -e 's,static/jquery.js,https://code.jquery.com/jquery-3.4.1.min.js,g' $$i; done

pdf:
	@$(SPHINXBUILD) -M rinoh "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
	mv jncip-dc-notes.pdf docs/jncip-dc-notes.pdf || true
	[ `du -k "_build/rinoh/jncip-dc-notes.pdf"` -eq `du -k "docs/jncip-dc-notes.pdf"` ] && exit 0 || true
	mv _build/rinoh/jncip-dc-notes.pdf docs/

publish: prepare clean html pdf
	echo "jncip-dc.tylerc.me" > docs/CNAME

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
