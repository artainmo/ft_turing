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
let alphabet = parse_json json "alphabet" Yojson.Basic.Util.to_list
let blank = parse_json json "blank" Yojson.Basic.Util.to_string
let states = parse_json json "states" Yojson.Basic.Util.to_list
let initial = parse_json json "initial" Yojson.Basic.Util.to_string
let finals = parse_json json "finals" Yojson.Basic.Util.to_list
let transitions = parse_json json "transitions" Yojson.Basic.Util.to_assoc

let () = Printf.printf "input: %s\n" input
let () = Printf.printf "name: %s\n" name
let () = Printf.printf "alphabet:\n"
let () = List.iter (fun x -> print_endline ("  " ^ Yojson.Basic.to_string x)) alphabet
let () = Printf.printf "blank: %s\n" blank
let () = Printf.printf "states:\n"
let () = List.iter (fun x -> print_endline ("  " ^ Yojson.Basic.to_string x)) states
let () = Printf.printf "initial: %s\n" initial
let () = Printf.printf "finals:\n"
let () = List.iter (fun x -> print_endline ("  " ^ Yojson.Basic.to_string x)) finals
let () = Printf.printf "transitions:\n"
let () = List.iter (fun (state, rules) -> 
    Printf.printf "  state %s:\n" state;
    List.iter (fun rule ->
        let read = parse_json rule "read" Yojson.Basic.Util.to_string in
        let to_state = parse_json rule "to_state" Yojson.Basic.Util.to_string in
        let write = parse_json rule "write" Yojson.Basic.Util.to_string in
        let action = parse_json rule "action" Yojson.Basic.Util.to_string in
        Printf.printf "    read: %s, to_state: %s, write: %s, action: %s\n" read to_state write action
    ) (rules |> Yojson.Basic.Util.to_list)
) transitions
