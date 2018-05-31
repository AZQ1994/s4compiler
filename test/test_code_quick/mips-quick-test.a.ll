; ModuleID = 'test/test_code_quick/mips-quick-test.bc'
source_filename = "test/test_code_quick/mips-quick-test.c"
target datalayout = "E-m:e-p:32:32-i64:64-n32"
target triple = "ppc32"

@data = local_unnamed_addr global [20 x i32] [i32 23002, i32 13359, i32 11466, i32 64118, i32 32403, i32 44024, i32 63253, i32 51654, i32 60960, i32 45232, i32 28137, i32 40242, i32 27545, i32 10747, i32 18543, i32 32541, i32 9632, i32 59878, i32 43528, i32 6841], align 4

; Function Attrs: nounwind
define i32 @quick(i32 %left, i32 %right) local_unnamed_addr #0 {
entry:
  %add18.reg2mem = alloca i32
  %inc.reg2mem = alloca i32
  %.reg2mem = alloca i32
  %arrayidx3.reg2mem = alloca i32*
  %i.0.reg2mem = alloca i32
  %last.0.ph.reg2mem = alloca i32
  %i.0.in.ph.reg2mem = alloca i32
  %.reg2mem10 = alloca i32
  %.in.reg2mem = alloca i32*
  %add18.pn.reg2mem = alloca i32
  %i.0.in.reg2mem = alloca i32
  %last.0.ph.reg2mem17 = alloca i32
  %i.0.in.ph.reg2mem19 = alloca i32
  %add18.pn.reg2mem21 = alloca i32
  %"reg2mem alloca point" = bitcast i32 0 to i32
  %cmp48 = icmp slt i32 %left, %right
  br i1 %cmp48, label %while.cond.preheader.preheader, label %entry.cleanup_crit_edge

entry.cleanup_crit_edge:                          ; preds = %entry
  br label %cleanup

while.cond.preheader.preheader:                   ; preds = %entry
  store i32 %left, i32* %add18.pn.reg2mem21
  br label %while.cond.preheader

while.cond.preheader:                             ; preds = %while.end.while.cond.preheader_crit_edge, %while.cond.preheader.preheader
  %add18.pn.reload22 = load i32, i32* %add18.pn.reg2mem21
  store i32 %add18.pn.reload22, i32* %add18.pn.reg2mem
  %add18.pn.reload16 = load i32, i32* %add18.pn.reg2mem
  %.in = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %add18.pn.reload16
  store i32* %.in, i32** %.in.reg2mem
  %.in.reload = load i32*, i32** %.in.reg2mem
  %0 = load i32, i32* %.in.reload, align 4, !tbaa !1
  store i32 %0, i32* %.reg2mem10
  %add18.pn.reload = load i32, i32* %add18.pn.reg2mem
  %add18.pn.reload14 = load i32, i32* %add18.pn.reg2mem
  store i32 %add18.pn.reload, i32* %last.0.ph.reg2mem17
  store i32 %add18.pn.reload14, i32* %i.0.in.ph.reg2mem19
  br label %while.cond.outer

while.cond.outer:                                 ; preds = %while.cond.preheader, %if.then6
  %i.0.in.ph.reload20 = load i32, i32* %i.0.in.ph.reg2mem19
  %last.0.ph.reload18 = load i32, i32* %last.0.ph.reg2mem17
  store i32 %i.0.in.ph.reload20, i32* %i.0.in.ph.reg2mem
  store i32 %last.0.ph.reload18, i32* %last.0.ph.reg2mem
  %i.0.in.ph.reload = load i32, i32* %i.0.in.ph.reg2mem
  store i32 %i.0.in.ph.reload, i32* %i.0.in.reg2mem
  br label %while.cond

while.cond:                                       ; preds = %while.body.while.cond_crit_edge, %while.cond.outer
  %i.0.in.reload = load i32, i32* %i.0.in.reg2mem
  %i.0 = add nsw i32 %i.0.in.reload, 1
  store i32 %i.0, i32* %i.0.reg2mem
  %cmp2 = icmp slt i32 %i.0.in.reload, %right
  br i1 %cmp2, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %i.0.reload6 = load i32, i32* %i.0.reg2mem
  %arrayidx3 = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %i.0.reload6
  store i32* %arrayidx3, i32** %arrayidx3.reg2mem
  %arrayidx3.reload4 = load i32*, i32** %arrayidx3.reg2mem
  %1 = load i32, i32* %arrayidx3.reload4, align 4, !tbaa !1
  store i32 %1, i32* %.reg2mem
  %.reload3 = load i32, i32* %.reg2mem
  %.reload11 = load i32, i32* %.reg2mem10
  %cmp5 = icmp slt i32 %.reload3, %.reload11
  br i1 %cmp5, label %if.then6, label %while.body.while.cond_crit_edge

while.body.while.cond_crit_edge:                  ; preds = %while.body
  %i.0.reload5 = load i32, i32* %i.0.reg2mem
  store i32 %i.0.reload5, i32* %i.0.in.reg2mem
  br label %while.cond

if.then6:                                         ; preds = %while.body
  %last.0.ph.reload9 = load i32, i32* %last.0.ph.reg2mem
  %inc = add nsw i32 %last.0.ph.reload9, 1
  store i32 %inc, i32* %inc.reg2mem
  %inc.reload2 = load i32, i32* %inc.reg2mem
  %arrayidx8 = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %inc.reload2
  %2 = load i32, i32* %arrayidx8, align 4, !tbaa !1
  %arrayidx3.reload = load i32*, i32** %arrayidx3.reg2mem
  store i32 %2, i32* %arrayidx3.reload, align 4, !tbaa !1
  %.reload = load i32, i32* %.reg2mem
  store i32 %.reload, i32* %arrayidx8, align 4, !tbaa !1
  %inc.reload = load i32, i32* %inc.reg2mem
  %i.0.reload = load i32, i32* %i.0.reg2mem
  store i32 %inc.reload, i32* %last.0.ph.reg2mem17
  store i32 %i.0.reload, i32* %i.0.in.ph.reg2mem19
  br label %while.cond.outer

while.end:                                        ; preds = %while.cond
  %.in.reload12 = load i32*, i32** %.in.reg2mem
  %3 = load i32, i32* %.in.reload12, align 4, !tbaa !1
  %last.0.ph.reload = load i32, i32* %last.0.ph.reg2mem
  %arrayidx14 = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %last.0.ph.reload
  %4 = load i32, i32* %arrayidx14, align 4, !tbaa !1
  %.in.reload13 = load i32*, i32** %.in.reg2mem
  store i32 %4, i32* %.in.reload13, align 4, !tbaa !1
  store i32 %3, i32* %arrayidx14, align 4, !tbaa !1
  %last.0.ph.reload8 = load i32, i32* %last.0.ph.reg2mem
  %sub17 = add nsw i32 %last.0.ph.reload8, -1
  %add18.pn.reload15 = load i32, i32* %add18.pn.reg2mem
  %call = tail call i32 @quick(i32 %add18.pn.reload15, i32 %sub17)
  %last.0.ph.reload7 = load i32, i32* %last.0.ph.reg2mem
  %add18 = add nsw i32 %last.0.ph.reload7, 1
  store i32 %add18, i32* %add18.reg2mem
  %add18.reload1 = load i32, i32* %add18.reg2mem
  %cmp = icmp slt i32 %add18.reload1, %right
  br i1 %cmp, label %while.end.while.cond.preheader_crit_edge, label %cleanup.loopexit

while.end.while.cond.preheader_crit_edge:         ; preds = %while.end
  %add18.reload = load i32, i32* %add18.reg2mem
  store i32 %add18.reload, i32* %add18.pn.reg2mem21
  br label %while.cond.preheader

cleanup.loopexit:                                 ; preds = %while.end
  br label %cleanup

cleanup:                                          ; preds = %entry.cleanup_crit_edge, %cleanup.loopexit
  ret i32 0
}

; Function Attrs: nounwind
define i32 @main() local_unnamed_addr #0 {
entry:
  %"reg2mem alloca point" = bitcast i32 0 to i32
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
