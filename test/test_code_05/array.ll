; ModuleID = 'test_code_05/array.c'
source_filename = "test_code_05/array.c"
target datalayout = "e-p:32:32-i64:64-v16:16-v32:32-n16:32:64"
target triple = "nvptx"

@arr.array = private unnamed_addr constant [10 x i32] [i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9], align 4

; Function Attrs: norecurse nounwind readnone
define i32 @arr(i32 %i) local_unnamed_addr #0 {
entry:
  %arrayidx = getelementptr inbounds [10 x i32], [10 x i32]* @arr.array, i32 0, i32 %i
  %0 = load i32, i32* %arrayidx, align 4, !tbaa !1
  ret i32 %0
}

; Function Attrs: norecurse nounwind readnone
define i32 @main() local_unnamed_addr #0 {
entry:
  ret i32 5
}

attributes #0 = { norecurse nounwind readnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-features"="-satom" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
!1 = !{!2, !2, i64 0}
!2 = !{!"int", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
