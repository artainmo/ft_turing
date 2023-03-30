(*if Array.length Sys.argv < 2 || Array.length Sys.argv > 3 then begin
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

let json = get_json Sys.argv.(1) in let name = json |> member "name" |> to_string in Printf.print "%s" name
*)
