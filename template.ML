(*  Title:   template.ML
    Author:  Balazs Toth

Clickable Isar proof templates for any proof block: print a template with
fix/assume/show ... sorry (with sendback markup) for all remaining subgoals,
analogously to the proof outline printed for "proof (induction ...)".
*)

signature TEMPLATE =
sig
  val show_types: bool Config.T
  val cartouches: bool Config.T
  val auto: bool Config.T
  val template_text: Proof.state -> string option
  val output_template: Proof.state -> unit
  val template: Proof.state -> unit
end;

structure Template: TEMPLATE =
struct

(* configuration *)

val show_types = Attrib.setup_config_bool \<^binding>\<open>template_show_types\<close> (K false);
val cartouches = Attrib.setup_config_bool \<^binding>\<open>template_cartouches\<close> (K false);
val auto = Attrib.setup_config_bool \<^binding>\<open>template_auto\<close> (K true);


(* plain source text for types and terms *)

val clean_string_of = Protocol_Message.clean_output o Pretty.unformatted_string_of;

fun maybe_quote ctxt s =
  let
    val s' = s |> perhaps (try (unprefix "'")) |> perhaps (try (unprefix "?"));
    val is_identifier = forall Symbol_Pos.is_identifier (Long_Name.explode s');
    val is_keyword = Keyword.is_literal (Thy_Header.get_keywords' ctxt) s;
    val quot = if Config.get ctxt cartouches then cartouche else quote;
  in if is_identifier andalso not is_keyword then s else quot s end;

fun print_typ ctxt = maybe_quote ctxt o clean_string_of o Syntax.unparse_typ ctxt;

val hide_vars = Term.map_aterms (fn Var (_, T) => Term.dummy_pattern T | a => a);

fun print_term ctxt =
  maybe_quote ctxt o clean_string_of o Syntax.unparse_term ctxt o hide_vars o
    singleton (Syntax.uncheck_terms ctxt);


(* decomposition of subgoals *)

fun dest_subgoal t =
  let
    val (fixes, horn) = funpow_yield (length (Term.strip_all_vars t)) Logic.dest_all_global t;
    val assms = Logic.strip_imp_prems horn;
    val concl = Logic.strip_imp_concl horn;
  in (fixes, assms, concl) end;

fun subgoal_context fixes ctxt =
  let val decls = map (fn (x, T) => (Binding.name x, SOME T, NoSyn)) fixes in
    snd (Proof_Context.add_fixes decls (Variable.set_body false ctxt))
      handle ERROR _ => snd (Proof_Context.add_fixes decls (Variable.set_body true ctxt))
  end;


(* Isar proof skeleton *)

fun print_skeleton ctxt indent (fixes, assms, concl) =
  let
    val ctxt' = subgoal_context fixes ctxt;
    val prefix = Symbol.spaces indent;
    fun print_clause _ [] = NONE
      | print_clause keyword [s] = SOME (prefix ^ keyword ^ " " ^ s)
      | print_clause keyword ss =
          let val (init, last) = split_last (map (fn s => prefix ^ "  " ^ s) ss)
          in SOME (cat_lines (prefix ^ keyword :: map (suffix " and") init @ [last])) end;
    fun print_fix (x, T) = Thy_Header.print_name' ctxt' x ^ " :: " ^ print_typ ctxt' T;
    val fix_items =
      if null fixes then []
      else if Config.get ctxt' show_types then map print_fix fixes
      else [implode_space (map (Thy_Header.print_name' ctxt' o #1) fixes)];
    val fixes_s = print_clause "fix" fix_items;
    val assms_s = print_clause "assume" (map (print_term ctxt') assms);
    val show_s = prefix ^ "show " ^ print_term ctxt' concl;
    val sorry_s = prefix ^ "  sorry";
    val context_lines = map_filter I [fixes_s, assms_s];
    val blank_lines = if null context_lines then [] else [""];
  in cat_lines (context_lines @ blank_lines @ [show_s, sorry_s]) end;


(* template for all remaining subgoals *)

(*Inside a structured proof body the template is the block body itself;
  otherwise (initial goal, apply scripts) it is wrapped in "proof -" ... "qed"
  to remain valid Isar text.*)
fun template_text state =
  let
    val {context = ctxt, goal, ...} = Proof.goal state;
    val print_ctxt = ctxt
      |> Context_Position.set_visible false
      |> fold (fn option => Config.put option false)
        [Printer.show_markup, Printer.show_type_emphasis,
          Printer.show_types, Printer.show_sorts, Thm.show_consts];
    val skeletons = map (print_skeleton print_ctxt 2 o dest_subgoal) (Thm.prems_of goal);
    val body = cat_lines (separate "next" skeletons);
  in
    if null skeletons then NONE
    else if can Proof.assert_forward state then SOME body
    else SOME (cat_lines ["proof -", body, "qed"])
  end;

fun output_text s =
  Output.information ("Proof outline:\n" ^ Active.sendback_markup_command s);

fun output_template state =
  (case template_text state of
    NONE => ()
  | SOME s => output_text s);

fun template state =
  (case template_text state of
    NONE => writeln "No subgoals remaining!"
  | SOME s => output_text s);


(* Isar command *)

val _ =
  Outer_Syntax.command \<^command_keyword>\<open>template\<close>
    "print clickable Isar proof template for all remaining subgoals"
    (Scan.succeed (Toplevel.keep_proof (template o Toplevel.proof_of)));


(* automatic output after the proof command (PIDE document processing only) *)

local

val print_function_name = "proof_template";
val base_thy = \<^theory>;
val proof_command = fst \<^command_keyword>\<open>proof\<close>;

in

val _ = Command.no_print_function print_function_name;

val _ =
  Command.print_function print_function_name
    (fn {command_name, ...} =>
      if command_name = proof_command then
        SOME {delay = NONE, pri = 0, persistent = true, strict = true,
          print_fn = fn _ => fn st =>
            if Toplevel.is_proof st andalso
              Context.subthy (base_thy, Toplevel.theory_of st) andalso
              Config.get (Toplevel.context_of st) auto
            then output_template (Toplevel.proof_of st)
            else ()}
      else NONE);

end;

end;
