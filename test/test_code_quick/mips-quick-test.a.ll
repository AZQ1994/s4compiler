; ModuleID = 'test_code_quick/mips-quick-test.bc'
source_filename = "test_code_quick/mips-quick-test.c"
target datalayout = "e-p:32:32-i64:64-v16:16-v32:32-n16:32:64"
target triple = "nvptx"

@data = local_unnamed_addr global [20 x i32] [i32 23002, i32 13359, i32 11466, i32 64118, i32 32403, i32 44024, i32 63253, i32 51654, i32 60960, i32 45232, i32 28137, i32 40242, i32 27545, i32 10747, i32 18543, i32 32541, i32 9632, i32 59878, i32 43528, i32 6841], align 4

; Function Attrs: nounwind
define i32 @quick(i32 %left, i32 %right) local_unnamed_addr #0 {
entry:
  %add15.reg2mem = alloca i32
  %inc.le.reg2mem = alloca i32
  %.reg2mem = alloca i32
  %arrayidx2.reg2mem = alloca i32*
  %i.0.reg2mem = alloca i32
  %last.0.ph.reg2mem = alloca i32
  %i.0.in.ph.reg2mem = alloca i32
  %.reg2mem10 = alloca i32
  %.in.reg2mem = alloca i32*
  %add15.pn.reg2mem = alloca i32
  %i.0.in.reg2mem = alloca i32
  %last.0.ph.reg2mem17 = alloca i32
  %i.0.in.ph.reg2mem19 = alloca i32
  %add15.pn.reg2mem21 = alloca i32
  %"reg2mem alloca point" = bitcast i32 0 to i32
  %cmp46 = icmp slt i32 %left, %right
  br i1 %cmp46, label %for.cond.preheader.preheader, label %entry.cleanup_crit_edge

entry.cleanup_crit_edge:                          ; preds = %entry
  br label %cleanup

for.cond.preheader.preheader:                     ; preds = %entry
  store i32 %left, i32* %add15.pn.reg2mem21
  br label %for.cond.preheader

for.cond.preheader:                               ; preds = %for.end.for.cond.preheader_crit_edge, %for.cond.preheader.preheader
  %add15.pn.reload22 = load i32, i32* %add15.pn.reg2mem21
  store i32 %add15.pn.reload22, i32* %add15.pn.reg2mem
  %add15.pn.reload16 = load i32, i32* %add15.pn.reg2mem
  %.in = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %add15.pn.reload16
  store i32* %.in, i32** %.in.reg2mem
  %.in.reload = load i32*, i32** %.in.reg2mem
  %0 = load i32, i32* %.in.reload, align 4, !tbaa !1
  store i32 %0, i32* %.reg2mem10
  %add15.pn.reload = load i32, i32* %add15.pn.reg2mem
  %add15.pn.reload14 = load i32, i32* %add15.pn.reg2mem
  store i32 %add15.pn.reload, i32* %last.0.ph.reg2mem17
  store i32 %add15.pn.reload14, i32* %i.0.in.ph.reg2mem19
  br label %for.cond.outer

for.cond.outer:                                   ; preds = %for.cond.preheader, %if.then4
  %i.0.in.ph.reload20 = load i32, i32* %i.0.in.ph.reg2mem19
  %last.0.ph.reload18 = load i32, i32* %last.0.ph.reg2mem17
  store i32 %i.0.in.ph.reload20, i32* %i.0.in.ph.reg2mem
  store i32 %last.0.ph.reload18, i32* %last.0.ph.reg2mem
  %i.0.in.ph.reload = load i32, i32* %i.0.in.ph.reg2mem
  store i32 %i.0.in.ph.reload, i32* %i.0.in.reg2mem
  br label %for.cond

for.cond:                                         ; preds = %for.body.for.cond_crit_edge, %for.cond.outer
  %i.0.in.reload = load i32, i32* %i.0.in.reg2mem
  %i.0 = add nsw i32 %i.0.in.reload, 1
  store i32 %i.0, i32* %i.0.reg2mem
  %cmp1 = icmp slt i32 %i.0.in.reload, %right
  br i1 %cmp1, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %i.0.reload6 = load i32, i32* %i.0.reg2mem
  %arrayidx2 = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %i.0.reload6
  store i32* %arrayidx2, i32** %arrayidx2.reg2mem
  %arrayidx2.reload4 = load i32*, i32** %arrayidx2.reg2mem
  %1 = load i32, i32* %arrayidx2.reload4, align 4, !tbaa !1
  store i32 %1, i32* %.reg2mem
  %.reload3 = load i32, i32* %.reg2mem
  %.reload11 = load i32, i32* %.reg2mem10
  %cmp3 = icmp slt i32 %.reload3, %.reload11
  br i1 %cmp3, label %if.then4, label %for.body.for.cond_crit_edge

for.body.for.cond_crit_edge:                      ; preds = %for.body
  %i.0.reload5 = load i32, i32* %i.0.reg2mem
  store i32 %i.0.reload5, i32* %i.0.in.reg2mem
  br label %for.cond

if.then4:                                         ; preds = %for.body
  %last.0.ph.reload9 = load i32, i32* %last.0.ph.reg2mem
  %inc.le = add nsw i32 %last.0.ph.reload9, 1
  store i32 %inc.le, i32* %inc.le.reg2mem
  %inc.le.reload2 = load i32, i32* %inc.le.reg2mem
  %arrayidx6.le = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %inc.le.reload2
  %2 = load i32, i32* %arrayidx6.le, align 4, !tbaa !1
  %arrayidx2.reload = load i32*, i32** %arrayidx2.reg2mem
  store i32 %2, i32* %arrayidx2.reload, align 4, !tbaa !1
  %.reload = load i32, i32* %.reg2mem
  store i32 %.reload, i32* %arrayidx6.le, align 4, !tbaa !1
  %inc.le.reload = load i32, i32* %inc.le.reg2mem
  %i.0.reload = load i32, i32* %i.0.reg2mem
  store i32 %inc.le.reload, i32* %last.0.ph.reg2mem17
  store i32 %i.0.reload, i32* %i.0.in.ph.reg2mem19
  br label %for.cond.outer

for.end:                                          ; preds = %for.cond
  %.in.reload12 = load i32*, i32** %.in.reg2mem
  %3 = load i32, i32* %.in.reload12, align 4, !tbaa !1
  %last.0.ph.reload = load i32, i32* %last.0.ph.reg2mem
  %arrayidx12 = getelementptr inbounds [20 x i32], [20 x i32]* @data, i32 0, i32 %last.0.ph.reload
  %4 = load i32, i32* %arrayidx12, align 4, !tbaa !1
  %.in.reload13 = load i32*, i32** %.in.reg2mem
  store i32 %4, i32* %.in.reload13, align 4, !tbaa !1
  store i32 %3, i32* %arrayidx12, align 4, !tbaa !1
  %last.0.ph.reload8 = load i32, i32* %last.0.ph.reg2mem
  %sub = add nsw i32 %last.0.ph.reload8, -1
  %add15.pn.reload15 = load i32, i32* %add15.pn.reg2mem
  %call = tail call i32 @quick(i32 %add15.pn.reload15, i32 %sub)
  %last.0.ph.reload7 = load i32, i32* %last.0.ph.reg2mem
  %add15 = add nsw i32 %last.0.ph.reload7, 1
  store i32 %add15, i32* %add15.reg2mem
  %add15.reload1 = load i32, i32* %add15.reg2mem
  %cmp = icmp slt i32 %add15.reload1, %right
  br i1 %cmp, label %for.end.for.cond.preheader_crit_edge, label %cleanup.loopexit

for.end.for.cond.preheader_crit_edge:             ; preds = %for.end
  %add15.reload = load i32, i32* %add15.reg2mem
  store i32 %add15.reload, i32* %add15.pn.reg2mem21
  br label %for.cond.preheader

cleanup.loopexit:                                 ; preds = %for.end
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

attributes #0 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-features"="-satom" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
!1 = !{!2, !2, i64 0}
!2 = !{!"int", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
