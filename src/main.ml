(* VERIFY COMMAND LINE ARGUMENTS *)
if Array.length Sys.argv < 2 || Array.length Sys.argv > 3 then begin
    Printf.fprintf stderr "ERROR: Wrong number of command line arguments. Use '-h' for help.\n" ;
    exit 0
end else if Array.length Sys.argv = 2 && (Sys.argv.(1) = "--help" || Sys.argv.(1) = "-h") then begin
    Printf.printf "usage: ft_turing [-h] jsonfile input\n";
    Printf.printf "\n";
    Printf.printf "positional arguments:\n";
    Printf.printf "  jsonfile            json description of the machine\n";
    Printf.printf "\n";
    Printf.printf "  input               input of the machine\n";
    Printf.printf "\n";
    Printf.printf "optional arguments:\n";
    Printf.printf "  -h, --help          show this help message and exit\n";
    exit 0
end else if Array.length Sys.argv = 2 then begin
    Printf.fprintf stderr "ERROR: Wrong argument. Use '-h' for help.\n" ;
    exit 0
end

let get_json file =
    try
        Yojson.Basic.from_file file
    with
        | Sys_error message when message = (file ^ ": No such file or directory") ->
                Printf.fprintf stderr "ERROR: File named '%s' not found.\n" file ; exit 0
let json =
    try
        get_json Sys.argv.(1)
    with
        | _ -> Printf.fprintf stderr "ERROR: '%s' is not a valid json file.\n" Sys.argv.(1) ; exit 0

let input = Sys.argv.(2)

(* PARSE MACHINE DESCRIPTION IN JSON FILE *)
let parse_json json label conversion_function =
    try
        json |> Yojson.Basic.Util.member label |> conversion_function
    with
        | _ -> Printf.fprintf stderr "ERROR: parsing machine %s from '%s'.\n" label Sys.argv.(1) ; exit 0

let remove_quotes s =
  String.sub s 1 (String.length s - 2)

let name = parse_json json "name" Yojson.Basic.Util.to_string
let __alphabet = parse_json json "alphabet" Yojson.Basic.Util.to_list
let _alphabet = List.map Yojson.Basic.to_string __alphabet
let alphabet = List.map remove_quotes _alphabet
let blank = parse_json json "blank" Yojson.Basic.Util.to_string
let __states = parse_json json "states" Yojson.Basic.Util.to_list
let _states = List.map Yojson.Basic.to_string __states
let states = List.map remove_quotes _states
let initial = parse_json json "initial" Yojson.Basic.Util.to_string
let __finals = parse_json json "finals" Yojson.Basic.Util.to_list
let _finals = List.map Yojson.Basic.to_string __finals
let finals = List.map remove_quotes _finals

type rule = { read: string; to_state: string; write: string; action: string }
let __transitions = parse_json json "transitions" Yojson.Basic.Util.to_assoc
let _transitions = List.map(fun (state,rules) -> (state, rules |> Yojson.Basic.Util.to_list)) __transitions
let transitions = List.map(fun (state,rules) -> (state, List.map(fun rule -> {
                read=parse_json rule "read" Yojson.Basic.Util.to_string;
                to_state=parse_json rule "to_state" Yojson.Basic.Util.to_string;
                write=parse_json rule "write" Yojson.Basic.Util.to_string;
                action=parse_json rule "action" Yojson.Basic.Util.to_string
            }) rules)) _transitions

(* CHECK FOR ERRORS IN PARSED VALUES *)
let verify_states_in_transitions_or_finals states transitions finals =
    let transitions_states = List.map (fun (state, rules) -> state) transitions in
    List.for_all (fun state ->
        List.mem state transitions_states || List.mem state finals
    ) states;;

if verify_states_in_transitions_or_finals states transitions finals = false then begin
    Printf.fprintf stderr "ERROR: Not all states are described in transitions or finals.\n";
    exit 0
end

let verify_alphabet_single_char alphabet =
    List.for_all(fun item ->
        String.length item = 1
    ) alphabet;;

if verify_alphabet_single_char alphabet = false then begin
    Printf.fprintf stderr "ERROR: Not all alphabet values consist of a single character.\n";
    exit 0
end;;

if List.mem blank alphabet = false then begin
    Printf.fprintf stderr "ERROR: Blank character is not part of alphabet.\n";
    exit 0
end;;

let string_to_char s =
    String.get s 0;;

if String.contains input (string_to_char blank) then begin
    Printf.fprintf stderr "ERROR: Input contains the blank character.\n";
    exit 0
end;;

let verify_input_in_alphabet input alphabet =
    String.for_all (fun c ->
        List.mem (String.make 1 c) alphabet
    ) input;;

if verify_input_in_alphabet input alphabet = false then begin
    Printf.fprintf stderr "ERROR: Not all input characters are part of alphabet.\n";
    exit 0
end;;

if List.mem initial states = false then begin
    Printf.fprintf stderr "ERROR: The initial state is not part of states.\n";
    exit 0
end

let verify_finals_in_states finals states =
    List.for_all (fun final ->
        List.mem final states
    ) finals;;

if verify_finals_in_states finals states = false then begin
    Printf.fprintf stderr "ERROR: Not all finals are in states.\n";
    exit 0
end

let verify_transitionToState_in_states transitions states =
    let _transitionToStates = List.map (fun(state, rules)-> List.map(fun(rule)-> rule.to_state) rules) transitions in
    let transitionToStates = List.concat _transitionToStates in
    List.for_all (fun to_state ->
        List.mem to_state states
    ) transitionToStates;;

if verify_transitionToState_in_states transitions states = false then begin
    Printf.fprintf stderr "ERROR: In transitions not all 'to_state' values exist in states.\n";
    exit 0
end

let verify_transitionWrite_in_alphabet transitions alphabet =
    let _transitionWrites = List.map (fun(state, rules)-> List.map(fun(rule)-> rule.write) rules) transitions in
    let transitionWrites = List.concat _transitionWrites in
    List.for_all (fun write ->
        List.mem write alphabet
    ) transitionWrites;;

if verify_transitionWrite_in_alphabet transitions alphabet = false then begin
    Printf.fprintf stderr "ERROR: In transitions not all 'write' values exist in alphabet.\n";
    exit 0
end

let verify_transitionRead_in_alphabet transitions alphabet =
    let _transitionReads = List.map (fun(state, rules)-> List.map(fun(rule)-> rule.read) rules) transitions in
    let transitionReads = List.concat _transitionReads in
    List.for_all (fun read ->
        List.mem read alphabet
    ) transitionReads;;

if verify_transitionRead_in_alphabet transitions alphabet = false then begin
    Printf.fprintf stderr "ERROR: In transitions not all 'read' values exist in alphabet.\n";
    exit 0
end

let verify_transitionAction transitions =
    let _transitionActions = List.map (fun(state, rules)-> List.map(fun(rule)-> rule.action) rules) transitions in
    let transitionActions = List.concat _transitionActions in
    List.for_all (fun action ->
        List.mem action ["RIGHT";"LEFT"]
    ) transitionActions;;

if verify_transitionAction transitions = false then begin
    Printf.fprintf stderr "ERROR: In transitions not all 'action' values equal to RIGHT or LEFT.\n";
    exit 0
end

(* PRINT ALL THE PARSED VALUES *)
let () = Printf.printf "input: %s\n" input
let () = Printf.printf "name: %s\n" name
let () = Printf.printf "alphabet:\n"
let () = List.iter (fun x -> print_endline ("  " ^ x)) alphabet
let () = Printf.printf "blank: %s\n" blank
let () = Printf.printf "states:\n"
let () = List.iter (fun x -> print_endline ("  " ^ x)) states
let () = Printf.printf "initial: %s\n" initial
let () = Printf.printf "finals:\n"
let () = List.iter (fun x -> print_endline ("  " ^ x)) finals
let () = Printf.printf "transitions:\n"
let () = List.iter (fun (state, rules) ->
    Printf.printf "  state %s:\n" state;
    List.iter (fun rule ->
        let read = rule.read in
        let to_state = rule.to_state in
        let write = rule.write in
        let action = rule.action in
        Printf.printf "    read: %s, to_state: %s, write: %s, action: %s\n" read to_state write action
    ) rules
) transitions

(* TURING MACHINE *)
let tape_half_size = 1000
let tape_display_half_size = 20
let tape = (String.make tape_half_size (string_to_char blank)) ^ input ^ (String.make tape_half_size (string_to_char blank))
let head = tape_half_size

let next_head_position tape head rule =
    if rule.action = "RIGHT" then 
        if head + 1 > String.length tape - 1 then begin
            Printf.fprintf stderr "ERROR: Trying to move head at out of bound index.\n"; 
            exit 0
        end else 1 
    else 
        if head - 1 < 0 then begin
            Printf.fprintf stderr "ERROR: Trying to move head at out of bound index.\n";
            exit 0;
        end else -1

let find_state rule_to_state =
    if List.mem rule_to_state finals = true then begin
        Printf.printf "END: Next state (%s) is final state.\n" rule_to_state;
        exit 0
    end else
        List.find(fun(state,rules) -> rule_to_state = state) transitions

let find_rule tape head rules =
    List.find(fun rule -> (string_to_char rule.read) = tape.[head]) rules

let update_char_at_index str id new_char =
    let len = String.length str in
    if id >= len then begin
        Printf.fprintf stderr "ERROR: Trying to update a char at an out of bound index.\n";
        exit 0
    end else
        let prefix = String.sub str 0 id in
        let suffix = String.sub str (id + 1) (len - id - 1) in
        prefix ^ (String.make 1 new_char) ^ suffix

let write_to_tape tape head rule =
    update_char_at_index tape head (string_to_char rule.write)

let display_tape tape head =
    Printf.printf "%s\n" ((String.make (head - tape_half_size + tape_display_half_size + 1) ' ') ^ "⦡");
    Printf.printf "[%s]\n" (String.sub tape (head - tape_display_half_size) ((String.length input) + (2 * tape_display_half_size)))

let rec looping_machine tape head rule =
    let () = Printf.printf "START\n" in
    (*display_tape tape head;*)
    let () = Printf.printf "DEBUG0\n" in
    let new_tape = write_to_tape tape head rule in
    let () = Printf.printf "DEBUG\n" in
    let new_head = next_head_position new_tape head rule in
    let () = Printf.printf "DEBUG1\n" in
    let new_state = find_state rule.to_state in
    let () = Printf.printf "DEBUG2\n" in
    let new_rule = find_rule new_tape new_head (snd new_state) in
    let () = Printf.printf "DEBUG3\n" in
    looping_machine new_tape new_head new_rule

let find_first_rule =
    let state = find_state initial in
    find_rule tape head (snd state)

let () = looping_machine tape head find_first_rule
