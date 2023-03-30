if Array.length Sys.argv < 2 || Array.length Sys.argv > 3 then begin
    Printf.printf "Wrong number of command line arguments. Use '-h' for help.\n" ; 
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
    Printf.printf "Wrong argument. Use '-h' for help.\n" ; 
    exit 0
end

let get_json file = 
    try 
        Yojson.Basic.from_file file
    with 
        | Sys_error message when message = (file ^ ": No such file or directory") -> 
                Printf.printf "File named '%s' not found\n" file ; exit 0

let json = 
    try
        get_json Sys.argv.(1)
    with
        | _ -> Printf.printf "Error '%s' is not a valid json file\n" Sys.argv.(1) ; exit 0
let input = Sys.argv.(2)

let parse_json json label conversion_function =
    try
        json |> Yojson.Basic.Util.member label |> conversion_function
    with
        | _ -> Printf.printf "Error parsing machine %s from '%s'" label Sys.argv.(1) ; exit 0

let name = parse_json json "name" Yojson.Basic.Util.to_string
let _alphabet = parse_json json "alphabet" Yojson.Basic.Util.to_list
let alphabet = List.map Yojson.Basic.to_string _alphabet
let blank = parse_json json "blank" Yojson.Basic.Util.to_string
let _states = parse_json json "states" Yojson.Basic.Util.to_list
let states = List.map Yojson.Basic.to_string _states
let initial = parse_json json "initial" Yojson.Basic.Util.to_string
let _finals = parse_json json "finals" Yojson.Basic.Util.to_list
let finals = List.map Yojson.Basic.to_string _finals

type rule = { read: string; to_state: string; write: string; action: string }
let __transitions = parse_json json "transitions" Yojson.Basic.Util.to_assoc
let _transitions = List.map (fun (state,rules) -> (state, rules |> Yojson.Basic.Util.to_list)) __transitions 
let transitions = List.map(fun (state,rules) -> (state, List.map(fun rule -> {
                read=parse_json rule "read" Yojson.Basic.Util.to_string;
                to_state=parse_json rule "to_state" Yojson.Basic.Util.to_string;
                write=parse_json rule "write" Yojson.Basic.Util.to_string;
                action=parse_json rule "action" Yojson.Basic.Util.to_string
            }) rules)) _transitions

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
(*
let verify_states_in_transitions states transitions = 
    List.for_all (fun state ->
        List.exists (fun (state_, rules) ->
            (*if state = state_ then true else false*)
            Printf.printf "  state %s:\n" state;
            Printf.printf "  state_ %s:\n" state_;
            true
        ) transitions
    ) states

let () = 
    try
        verify_states_in_transitions states transitions
    with
        | Not_found -> Printf.printf "A state has not been described as a transition."
 *)
