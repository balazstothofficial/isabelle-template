(*  Title:   Template_Testing.thy
    Author:  Balazs Toth

Test infrastructure for proof templates: the command \<^text>\<open>template_test\<close>
checks that the generated template matches the expected text.  It checks the
same text that the automatic output and the \<^text>\<open>template\<close> command print.
*)

theory Template_Testing
  imports Template.Template
  keywords "template_test" :: diag
begin

ML_file \<open>template_testing.ML\<close>

end
