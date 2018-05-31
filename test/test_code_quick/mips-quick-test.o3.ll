; ModuleID = 'test/test_code_quick/mips-quick-test.c'
source_filename = "test/test_code_quick/mips-quick-test.c"
target datalayout = "E-m:e-p:32:32-i64:64-n32"
target triple = "ppc32"

@data = local_unnamed_addr global [20 x i32] [i32 23002, i32 13359, i32 11466, i32 64118, i32 32403, i32 44024, i32 63253, i32 51654, i32 60960, i32 45232, i32 28137, i32 40242, i32 27545, i32 10747, i32 18543, i32 32541, i32 9632, i32 59878, i32 43528, i32 6841], align 4

; Function Attrs: nounwind
define i32 @quick(i32 %left, i32 %right) local_unnamed_addr #0 {
entry:
  %cmp48 = icmp slt i32 %left, %right
  br i1 %cmp48, label %while.cond.preheader.preheader, label %cleanup

while.cond.preheader.preheader:                   ; preds = %entry
  br label %while.cond.preheader

while.cond.preheader:                             ; preds = %while.cond.preheader.preheader, %while.end
  %add18.pn = phi i32 [ %add18, %while.end ], [ %left, %while.cond.preheader.preheader ]
  %.in = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %add18.pn
  %0 = load i32, i32* %.in, align 4, !tbaa !1
  br label %while.cond.outer

while.cond.outer:                                 ; preds = %while.cond.preheader, %if.then6
  %i.0.in.ph = phi i32 [ %add18.pn, %while.cond.preheader ], [ %i.0, %if.then6 ]
  %last.0.ph = phi i32 [ %add18.pn, %while.cond.preheader ], [ %inc, %if.then6 ]
  br label %while.cond

while.cond:                                       ; preds = %while.cond.outer, %while.body
  %i.0.in = phi i32 [ %i.0, %while.body ], [ %i.0.in.ph, %while.cond.outer ]
  %i.0 = add nsw i32 %i.0.in, 1
  %cmp2 = icmp slt i32 %i.0.in, %right
  br i1 %cmp2, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %arrayidx3 = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %i.0
  %1 = load i32, i32* %arrayidx3, align 4, !tbaa !1
  %cmp5 = icmp slt i32 %1, %0
  br i1 %cmp5, label %if.then6, label %while.cond

if.then6:                                         ; preds = %while.body
  %inc = add nsw i32 %last.0.ph, 1
  %arrayidx8 = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %inc
  %2 = load i32, i32* %arrayidx8, align 4, !tbaa !1
  store i32 %2, i32* %arrayidx3, align 4, !tbaa !1
  store i32 %1, i32* %arrayidx8, align 4, !tbaa !1
  br label %while.cond.outer

while.end:                                        ; preds = %while.cond
  %3 = load i32, i32* %.in, align 4, !tbaa !1
  %arrayidx14 = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %last.0.ph
  %4 = load i32, i32* %arrayidx14, align 4, !tbaa !1
  store i32 %4, i32* %.in, align 4, !tbaa !1
  store i32 %3, i32* %arrayidx14, align 4, !tbaa !1
  %sub17 = add nsw i32 %last.0.ph, -1
  %call = tail call i32 @quick(i32 %add18.pn, i32 %sub17)
  %add18 = add nsw i32 %last.0.ph, 1
  %cmp = icmp slt i32 %add18, %right
  br i1 %cmp, label %while.cond.preheader, label %cleanup.loopexit

cleanup.loopexit:                                 ; preds = %while.end
  br label %cleanup

cleanup:                                          ; preds = %cleanup.loopexit, %entry
  ret i32 0
}

; Function Attrs: nounwind
define i32 @main() local_unnamed_addr #0 {
entry:
  %call = tail call i32 @quick(i32 0, i32 19)
  ret i32 0
}

attributes #0 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="ppc" "target-features"="-altivec,-bpermd,-crypto,-direct-move,-extdiv,-power8-vector,-power9-vector,-qpx,-vsx" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
!1 = !{!2, !2, i64 0}
!2 = !{!"int", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
