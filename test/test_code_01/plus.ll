; ModuleID = 'test/test_code_01/plus.c'
source_filename = "test/test_code_01/plus.c"
target datalayout = "e-p:32:32-i64:64-v16:16-v32:32-n16:32:64"
target triple = "nvptx"

; Function Attrs: norecurse nounwind readnone
define i32 @plus(i32 %a) local_unnamed_addr #0 {
entry:
  %cmp6 = icmp slt i32 %a, 0
  br i1 %cmp6, label %for.cond.cleanup, label %for.body.preheader

for.body.preheader:                               ; preds = %entry
  %0 = zext i32 %a to i33
  %1 = add i32 %a, -1
  %2 = zext i32 %1 to i33
  %3 = mul i33 %0, %2
  %4 = lshr i33 %3, 1
  %5 = trunc i33 %4 to i32
  %6 = add i32 %5, %a
  br label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %for.body.preheader, %entry
  %res.0.lcssa = phi i32 [ 0, %entry ], [ %6, %for.body.preheader ]
  ret i32 %res.0.lcssa
}

; Function Attrs: norecurse nounwind readnone
define i32 @main() local_unnamed_addr #0 {
entry:
  ret i32 0
}

attributes #0 = { norecurse nounwind readnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-features"="-satom" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
