(*  Title:   Template_Test.thy

Examples/tests for proof templates.  In Isabelle/jEdit, a clickable proof
template is shown in the output panel automatically for every \<^theory_text>\<open>proof\<close>
command (and on demand via the \<^theory_text>\<open>template\<close> command); clicking it inserts
the template into the proof text.
*)

theory Template_Test
  imports Main Template_Testing
begin

section \<open>Automatic templates: shown for any \<^theory_text>\<open>proof\<close> command\<close>

text \<open>
  No \<^theory_text>\<open>template\<close> command is needed: in the editor, the template appears in the
  output panel as soon as the \<^theory_text>\<open>proof\<close> command is processed.
\<close>

subsection \<open>Original example\<close>

lemma "\<forall>x. P x \<longrightarrow> P x"
proof (intro allI impI)
  template_test \<open>
  fix x
  assume "P x"
  show "P x"
    sorry\<close>
  fix x
  assume "P x"
  then show "P x" .
qed


subsection \<open>Multiple subgoals, separated by \<^theory_text>\<open>next\<close>\<close>

lemma "A \<and> A \<longrightarrow> A \<and> A \<and> A"
proof (intro conjI impI)
  template_test \<open>
  assume "A \<and> A"
  show A
    sorry
next
  assume "A \<and> A"
  show A
    sorry
next
  assume "A \<and> A"
  show A
    sorry\<close>
  assume "A \<and> A"
  then show A and A and A by simp_all
qed


subsection \<open>Induction: fixes and induction hypotheses appear in the template\<close>

lemma "rev (rev xs) = xs"
proof (induct xs)
  template_test \<open>
  show "rev (rev []) = []"
    sorry
next
  fix a xs
  assume "rev (rev xs) = xs"
  show "rev (rev (a # xs)) = a # xs"
    sorry\<close>
  show "rev (rev []) = []" by simp
next
  fix a xs
  assume "rev (rev xs) = xs"
  then show "rev (rev (a # xs)) = a # xs" by simp
qed


subsection \<open>Works in any proof block, e.g. plain \<^theory_text>\<open>proof -\<close>\<close>

lemma "(0 :: nat) \<le> n * n"
proof -
  template_test \<open>
  show "0 \<le> n * n"
    sorry\<close>
  show "0 \<le> n * n" by simp
qed


subsection \<open>Several assumptions and fixed variables in one subgoal\<close>

lemma "\<forall>x y. x < y \<longrightarrow> y < z \<longrightarrow> x < (z :: nat)"
proof (intro allI impI)
  template_test \<open>
  fix x y
  assume
    "x < y" and
    "y < z"
  show "x < z"
    sorry\<close>
  fix x y :: nat
  assume "x < y" and "y < z"
  then show "x < z" by simp
qed


subsection \<open>Optional type annotations via configuration option\<close>

context
  notes [[template_show_types]]
begin

lemma "\<forall>x. rev [x] = [x]"
proof (intro allI)
  template_test \<open>
  fix x :: 'a
  show "rev [x] = [x]"
    sorry\<close>
  fix x :: 'a
  show "rev [x] = [x]" by simp
qed

end


subsection \<open>Optional cartouches instead of quotes\<close>

context
  notes [[template_cartouches]]
begin

lemma "\<forall>x. P x \<longrightarrow> P x"
proof (intro allI impI)
  template_test \<open>
  fix x
  assume \<open>P x\<close>
  show \<open>P x\<close>
    sorry\<close>
  fix x
  assume "P x"
  then show "P x" .
qed

end


subsection \<open>No remaining subgoals: nothing is printed\<close>

lemma True
proof
  template_test \<open>\<close>
qed


section \<open>Explicit \<^theory_text>\<open>template\<close> command\<close>

text \<open>
  The \<^theory_text>\<open>template\<close> command prints the same template on demand, anywhere inside
  a proof block, e.g. also after \<^theory_text>\<open>apply\<close> steps or with \<^theory_text>\<open>[[template_auto = false]]\<close>.
\<close>

subsection \<open>Original example\<close>

lemma "\<forall>x. P x \<longrightarrow> P x"
proof (intro allI impI)
  template
  template_test \<open>
  fix x
  assume "P x"
  show "P x"
    sorry\<close>
  fix x
  assume "P x"
  then show "P x" .
qed


subsection \<open>Multiple subgoals, separated by \<^theory_text>\<open>next\<close>\<close>

lemma "A \<and> A \<longrightarrow> A \<and> A \<and> A"
proof (intro conjI impI)
  template
  template_test \<open>
  assume "A \<and> A"
  show A
    sorry
next
  assume "A \<and> A"
  show A
    sorry
next
  assume "A \<and> A"
  show A
    sorry\<close>
  assume "A \<and> A"
  then show A and A and A by simp_all
qed


subsection \<open>Induction: fixes and induction hypotheses appear in the template\<close>

lemma "rev (rev xs) = xs"
proof (induct xs)
  template
  template_test \<open>
  show "rev (rev []) = []"
    sorry
next
  fix a xs
  assume "rev (rev xs) = xs"
  show "rev (rev (a # xs)) = a # xs"
    sorry\<close>
  show "rev (rev []) = []" by simp
next
  fix a xs
  assume "rev (rev xs) = xs"
  then show "rev (rev (a # xs)) = a # xs" by simp
qed


subsection \<open>Works in any proof block, e.g. plain \<^theory_text>\<open>proof -\<close>\<close>

lemma "(0 :: nat) \<le> n * n"
proof -
  template
  template_test \<open>
  show "0 \<le> n * n"
    sorry\<close>
  show "0 \<le> n * n" by simp
qed


subsection \<open>Several assumptions and fixed variables in one subgoal\<close>

lemma "\<forall>x y. x < y \<longrightarrow> y < z \<longrightarrow> x < (z :: nat)"
proof (intro allI impI)
  template
  template_test \<open>
  fix x y
  assume
    "x < y" and
    "y < z"
  show "x < z"
    sorry\<close>
  fix x y :: nat
  assume "x < y" and "y < z"
  then show "x < z" by simp
qed


subsection \<open>Optional type annotations via configuration option\<close>

context
  notes [[template_show_types]]
begin

lemma "\<forall>x. rev [x] = [x]"
proof (intro allI)
  template
  template_test \<open>
  fix x :: 'a
  show "rev [x] = [x]"
    sorry\<close>
  fix x :: 'a
  show "rev [x] = [x]" by simp
qed

end


subsection \<open>Inside \<^theory_text>\<open>apply\<close> scripts: schematic variables become placeholders\<close>

lemma "\<exists>x. x = (1 :: nat)"
  apply (rule exI)
  template
  template_test \<open>
  show "_ = 1"
    sorry\<close>
  apply (rule refl)
  done


subsection \<open>No remaining subgoals\<close>

lemma True
proof
  template  \<comment> \<open>prints \<^verbatim>\<open>No subgoals remaining!\<close>\<close>
  template_test \<open>\<close>
qed

end
