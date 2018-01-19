; ModuleID = 'test/test_code_01/plus.bc'
source_filename = "test/test_code_01/plus.c"
target datalayout = "e-p:32:32-i64:64-v16:16-v32:32-n16:32:64"
target triple = "nvptx"

; Function Attrs: norecurse nounwind readnone
define i32 @plus(i32 %a) local_unnamed_addr #0 {
entry:
  %.reg2mem = alloca i32
  %res.0.lcssa.reg2mem = alloca i32
  %"reg2mem alloca point" = bitcast i32 0 to i32
  %cmp6 = icmp slt i32 %a, 0
  br i1 %cmp6, label %entry.for.cond.cleanup_crit_edge, label %for.body.preheader

entry.for.cond.cleanup_crit_edge:                 ; preds = %entry
  store i32 0, i32* %res.0.lcssa.reg2mem
  br label %for.cond.cleanup

for.body.preheader:                               ; preds = %entry
  %0 = zext i32 %a to i33
  %1 = add i32 %a, -1
  %2 = zext i32 %1 to i33
  %3 = mul i33 %0, %2
  %4 = lshr i33 %3, 1
  %5 = trunc i33 %4 to i32
  %6 = add i32 %5, %a
  store i32 %6, i32* %.reg2mem
  %.reload = load i32, i32* %.reg2mem
  store i32 %.reload, i32* %res.0.lcssa.reg2mem
  br label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %entry.for.cond.cleanup_crit_edge, %for.body.preheader
  %res.0.lcssa.reload = load i32, i32* %res.0.lcssa.reg2mem
  ret i32 %res.0.lcssa.reload
}

; Function Attrs: norecurse nounwind readnone
define i32 @main() local_unnamed_addr #0 {
entry:
  %"reg2mem alloca point" = bitcast i32 0 to i32
  ret i32 0
}

attributes #0 = { norecurse nounwind readnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-features"="-satom" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
