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

clean:
	rm -rf _build/*
	rm -rf docs/*
html:
	@$(SPHINXBUILD) -M html "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

pdf:
	@$(SPHINXBUILD) -M rinoh "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

publish: clean html pdf
	mv _build/html/* docs/
	mv docs/_static docs/static
	mv _build/pdf/* docs/
	for i in `ls docs/*.html`; do sed -i -e 's/_static/static/g' $$i; done
	for i in `ls docs/*.html`; do sed -i -e 's,static/jquery.js,https://code.jquery.com/jquery-3.4.1.min.js,g' $$i; done
	echo "jncip-dc.tylerc.me" > docs/CNAME
	git add .
	git commit

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
