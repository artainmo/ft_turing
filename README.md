# ft_turing
42 school [subject](https://cdn.intra.42.fr/pdf/pdf/60874/en.subject.pdf).

In OCaml using functional-programming I implemented a single headed and single tape Turing machine from a description provided in json.<br>
The Turing machine is the first mathematical and algorithmic model behind a general purpose computer.

## Run
1. To install all dependencies use `make env`. We expect you to be on mac with 'brew' available.
2. Now compile and create the program executable named 'ft_turing'. Use `make` to compile to byte-code with the 'ocamlc' compiler or use `make opt` to compile to machine-code with 'ocamlopt'.
3. To run the Turing machine launch the executbale with as first argument a json file describing a machine and as second argument machine input. For example like this `./ft_turing machines/unary_sub.json "111-11="`.

## Other commands
Tu clean the compilation file use `make fclean`.<br>
To clean and compile back use `make re` or `make re_opt`.

## Tests
1. ./ft_turing machines/unary_sub.json "111-11=" (should equal "1")
2. ./ft_turing machines/unary_add.json "11+11111=" (should equal "1111111")
3. ./ft_turing machines/palindrome_or_not.json 11011 (should equal "y")
4. ./ft_turing machines/palindrome_or_not.json 1011 (should equal "n")

## Documentation
[artainmo - OCaml](https://github.com/artainmo/general-programming/tree/main/languages/OCaml)<br>
[Turing Machines Explained - Computerphile](https://www.youtube.com/watch?v=dNRDvLACg5Q)<br>
[Turing Machine Primer - Computerphile](https://www.youtube.com/watch?v=DILF8usqp7M)<br>
[Busy Beaver Turing Machines - Computerphile](https://www.youtube.com/watch?v=CE8UhcyJS0I)<br>
[Turing Complete - Computerphile](https://www.youtube.com/watch?v=RPQD7-AOjMI)<br>
[Turing Machines - How Computer Science Was Created By Accident](https://www.youtube.com/watch?v=PLVCscCY4xI)
