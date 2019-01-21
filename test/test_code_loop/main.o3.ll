; ModuleID = 'main.c'
source_filename = "main.c"
target datalayout = "E-m:e-p:32:32-i64:64-n32"
target triple = "ppc32"

@upto = local_unnamed_addr global i32 25, align 4
@data = local_unnamed_addr global [10 x i32] [i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10], align 4

; Function Attrs: norecurse nounwind readonly
define i32 @main() local_unnamed_addr #0 {
entry:
  %0 = load i32, i32* @upto, align 4, !tbaa !1
  %cmp5 = icmp sgt i32 %0, 0
  br i1 %cmp5, label %while.body.preheader, label %while.end

while.body.preheader:                             ; preds = %entry
  br label %while.body

while.body:                                       ; preds = %while.body.preheader, %while.body
  %result.07 = phi i32 [ %add, %while.body ], [ 0, %while.body.preheader ]
  %i.06 = phi i32 [ %inc, %while.body ], [ 0, %while.body.preheader ]
  %inc = add nuw nsw i32 %i.06, 1
  %arrayidx = getelementptr inbounds [10 x i32], [10 x i32]* @data, i32 0, i32 %i.06
  %1 = load i32, i32* %arrayidx, align 4, !tbaa !1
  %add = add nsw i32 %1, %result.07
  %cmp = icmp slt i32 %add, %0
  br i1 %cmp, label %while.body, label %while.end.loopexit

while.end.loopexit:                               ; preds = %while.body
  br label %while.end

while.end:                                        ; preds = %while.end.loopexit, %entry
  %result.0.lcssa = phi i32 [ 0, %entry ], [ %add, %while.end.loopexit ]
  ret i32 %result.0.lcssa
}

attributes #0 = { norecurse nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="ppc" "target-features"="-altivec,-bpermd,-crypto,-direct-move,-extdiv,-power8-vector,-power9-vector,-qpx,-vsx" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
!1 = !{!2, !2, i64 0}
!2 = !{!"int", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
