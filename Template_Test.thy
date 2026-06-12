theory Template_Test
  imports Main Template
begin

lemma "\<forall>x. P x \<longrightarrow> P x"
proof (intro allI impI) 
  (* This should give me in the output a template to click (like for inductions) that looks like:
    fix x
    assume "P x"
    show "P x"
      sorry
   *)
  fix x
  assume "P x"
  then show "P x" .
qed


end


end
