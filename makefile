EXECUTABLE = ft_turing
COMPILER = ocamlc
COMPILER_OPT = ocamlopt
SRCDIR = ./src
SRCSFILES = main.ml
SRCS = $(addprefix $(SRCDIR)/,$(SRCSFILES))
OBJECTS = $(SRCS:.ml=.cmo)
OBJECTS_OPT = $(SRCS:.ml=.cmx)

all: $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	ocamlfind $(COMPILER) -o $@ -thread -linkpkg -package yojson,unix,threads $^

%.cmo: %.ml
	ocamlfind $(COMPILER) -c -thread -package yojson,unix,threads $<

opt: $(OBJECTS_OPT)
	ocamlfind $(COMPILER_OPT) -o $(EXECUTABLE) -thread -linkpkg -package yojson,unix,threads $^

%.cmx: %.ml
	ocamlfind $(COMPILER_OPT) -c -thread -package yojson,unix,threads $<

re: fclean all

re_opt: fclean opt

fclean: clean
	rm -rf $(EXECUTABLE)

clean:
	rm -rf $(SRCDIR)/*.cm[iox] $(SRCDIR)/*.o

env:
	opam --version || (brew install opam && opam init --yes --shell-setup)
	ocamlfind --version || opam install ocamlfind --yes
	ocamlfind list | grep "yojson" || opam install yojson --yes
