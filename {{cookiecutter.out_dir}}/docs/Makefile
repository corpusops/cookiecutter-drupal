# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
# let builddir be overriden in docker mode
SOURCEDIR     ?= .
BUILDDIR      ?= ../{{cookiecutter.docs_folder}}

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)/guide-administration/" "$(BUILDDIR)/guide-administration" $(SPHINXOPTS) $(O)
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)/guide-contributeur/" "$(BUILDDIR)/guide-contributeur" $(SPHINXOPTS) $(O)
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)/guide-developpeur/" "$(BUILDDIR)/guide-developpeur" $(SPHINXOPTS) $(O)
