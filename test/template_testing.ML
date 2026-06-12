(*  Title:   template_testing.ML
    Author:  Balazs Toth

Command "template_test": check that the generated proof template matches the
expected text and fail otherwise.
*)

local

fun trim_blank_lines s =
  split_lines s
  |> drop_prefix (forall_string Symbol.is_ascii_blank)
  |> drop_suffix (forall_string Symbol.is_ascii_blank)
  |> cat_lines;

in

val _ =
  Outer_Syntax.command \<^command_keyword>\<open>template_test\<close>
    "check the generated proof template against the expected text"
    (Parse.embedded >> (fn expected =>
      Toplevel.keep_proof (fn st =>
        let val actual = the_default "" (Template.template_text (Toplevel.proof_of st)) in
          if trim_blank_lines actual = trim_blank_lines expected then ()
          else
            error (cat_lines
              ["Proof template differs from expected text:", actual, "", "Expected:", expected])
        end)));

end;
