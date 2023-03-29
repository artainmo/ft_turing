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
	$(COMPILER) -o $@ $^

%.cmo: %.ml
	$(COMPILER) -c $<

opt: $(OBJECTS_OPT)
	$(COMPILER_OPT) -o $(EXECUTABLE) $^

%.cmx: %.ml
	$(COMPILER_OPT) -c $<

re: fclean all

re_opt: fclean opt

fclean: clean
	rm -rf $(EXECUTABLE)

clean:
	rm -rf $(SRCDIR)/*.cm[iox] $(SRCDIR)/*.o

env:
	chmod +x env.sh && ./env.sh
