(*  Title:   Template.thy
    Author:  Balazs Toth

Diagnostic command \<^text>\<open>template\<close> and automatic output after the
\<^text>\<open>proof\<close> command: print a clickable Isar proof template
(fix/assume/show ... sorry) for all remaining subgoals of the enclosing proof,
analogously to the proof outline printed for \<^text>\<open>proof (induction ...)\<close>.
*)

theory Template
  imports Pure
  keywords "template" :: diag
begin

ML_file \<open>template.ML\<close>

end
