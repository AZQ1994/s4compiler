; ModuleID = 'test/test_code_bubble_sort/bubble.bc'
source_filename = "test/test_code_bubble_sort/bubble.c"
target datalayout = "e-p:32:32-i64:64-v16:16-v32:32-n16:32:64"
target triple = "nvptx"

@N = local_unnamed_addr global [20 x i32] [i32 23002, i32 13359, i32 11466, i32 64118, i32 32403, i32 44024, i32 63253, i32 51654, i32 60960, i32 45232, i32 28137, i32 40242, i32 27545, i32 10747, i32 18543, i32 32541, i32 9632, i32 59878, i32 43528, i32 6841], align 4
@len = local_unnamed_addr global i32 20, align 4

; Function Attrs: norecurse nounwind
define i32 @main() local_unnamed_addr #0 {
entry:
  %j.0.1.reg2mem = alloca i32
  %inc.reg2mem = alloca i32
  %.reg2mem = alloca i32
  %arrayidx5.1.reg2mem = alloca i32*
  %.reg2mem5 = alloca i32
  %arrayidx.1.reg2mem = alloca i32*
  %j.0.reg2mem = alloca i32
  %.reg2mem10 = alloca i32
  %arrayidx5.reg2mem = alloca i32*
  %.reg2mem14 = alloca i32
  %arrayidx.reg2mem = alloca i32*
  %j.030.reg2mem = alloca i32
  %j.0.in29.unr.ph.reg2mem = alloca i32
  %j.030.unr.ph.reg2mem = alloca i32
  %.reg2mem21 = alloca i32
  %.reg2mem24 = alloca i32
  %i.032.reg2mem = alloca i32
  %j.0.prol.reg2mem = alloca i32
  %arrayidx5.prol.reg2mem = alloca i32*
  %arrayidx.prol.reg2mem = alloca i32*
  %.reg2mem33 = alloca i32
  %j.027.reg2mem = alloca i32
  %.reg2mem39 = alloca i32
  %j.0.in29.reg2mem = alloca i32
  %j.030.reg2mem47 = alloca i32
  %j.0.in29.unr.ph.reg2mem49 = alloca i32
  %j.030.unr.ph.reg2mem51 = alloca i32
  %i.032.reg2mem53 = alloca i32
  %"reg2mem alloca point" = bitcast i32 0 to i32
  %0 = load i32, i32* @len, align 4, !tbaa !1
  store i32 %0, i32* %.reg2mem39
  %.reload46 = load i32, i32* %.reg2mem39
  %cmp31 = icmp sgt i32 %.reload46, 0
  br i1 %cmp31, label %for.cond1.preheader.preheader, label %entry.for.end14_crit_edge

entry.for.end14_crit_edge:                        ; preds = %entry
  br label %for.end14

for.cond1.preheader.preheader:                    ; preds = %entry
  %.reload44 = load i32, i32* %.reg2mem39
  %j.027 = add nsw i32 %.reload44, -1
  store i32 %j.027, i32* %j.027.reg2mem
  %.reload43 = load i32, i32* %.reg2mem39
  %1 = add i32 %.reload43, -2
  store i32 %1, i32* %.reg2mem33
  %j.027.reload37 = load i32, i32* %j.027.reg2mem
  %arrayidx.prol = getelementptr inbounds [20 x i32], [20 x i32]* @N, i32 0, i32 %j.027.reload37
  store i32* %arrayidx.prol, i32** %arrayidx.prol.reg2mem
  %.reload42 = load i32, i32* %.reg2mem39
  %sub4.prol = add nsw i32 %.reload42, -2
  %arrayidx5.prol = getelementptr inbounds [20 x i32], [20 x i32]* @N, i32 0, i32 %sub4.prol
  store i32* %arrayidx5.prol, i32** %arrayidx5.prol.reg2mem
  %.reload40 = load i32, i32* %.reg2mem39
  %j.0.prol = add nsw i32 %.reload40, -2
  store i32 %j.0.prol, i32* %j.0.prol.reg2mem
  store i32 0, i32* %i.032.reg2mem53
  br label %for.cond1.preheader

for.cond1.preheader:                              ; preds = %for.inc13.for.cond1.preheader_crit_edge, %for.cond1.preheader.preheader
  %i.032.reload54 = load i32, i32* %i.032.reg2mem53
  store i32 %i.032.reload54, i32* %i.032.reg2mem
  %i.032.reload30 = load i32, i32* %i.032.reg2mem
  %j.027.reload38 = load i32, i32* %j.027.reg2mem
  %cmp228 = icmp sgt i32 %j.027.reload38, %i.032.reload30
  br i1 %cmp228, label %for.body3.preheader, label %for.cond1.preheader.for.inc13_crit_edge

for.cond1.preheader.for.inc13_crit_edge:          ; preds = %for.cond1.preheader
  br label %for.inc13

for.body3.preheader:                              ; preds = %for.cond1.preheader
  %i.032.reload27 = load i32, i32* %i.032.reg2mem
  %j.027.reload = load i32, i32* %j.027.reg2mem
  %2 = sub i32 %j.027.reload, %i.032.reload27
  %xtraiter = and i32 %2, 1
  %lcmp.mod = icmp eq i32 %xtraiter, 0
  br i1 %lcmp.mod, label %for.body3.preheader.for.body3.prol.loopexit.unr-lcssa_crit_edge, label %for.body3.prol.preheader

for.body3.preheader.for.body3.prol.loopexit.unr-lcssa_crit_edge: ; preds = %for.body3.preheader
  %j.027.reload36 = load i32, i32* %j.027.reg2mem
  %.reload41 = load i32, i32* %.reg2mem39
  store i32 %.reload41, i32* %j.0.in29.unr.ph.reg2mem49
  store i32 %j.027.reload36, i32* %j.030.unr.ph.reg2mem51
  br label %for.body3.prol.loopexit.unr-lcssa

for.body3.prol.preheader:                         ; preds = %for.body3.preheader
  br label %for.body3.prol

for.body3.prol:                                   ; preds = %for.body3.prol.preheader
  %arrayidx.prol.reload32 = load i32*, i32** %arrayidx.prol.reg2mem
  %3 = load i32, i32* %arrayidx.prol.reload32, align 4, !tbaa !1
  store i32 %3, i32* %.reg2mem24
  %arrayidx5.prol.reload31 = load i32*, i32** %arrayidx5.prol.reg2mem
  %4 = load i32, i32* %arrayidx5.prol.reload31, align 4, !tbaa !1
  store i32 %4, i32* %.reg2mem21
  %.reload23 = load i32, i32* %.reg2mem21
  %.reload26 = load i32, i32* %.reg2mem24
  %cmp6.prol = icmp slt i32 %.reload26, %.reload23
  br i1 %cmp6.prol, label %if.then.prol, label %for.body3.prol.for.cond1.backedge.prol_crit_edge

for.body3.prol.for.cond1.backedge.prol_crit_edge: ; preds = %for.body3.prol
  br label %for.cond1.backedge.prol

if.then.prol:                                     ; preds = %for.body3.prol
  %.reload22 = load i32, i32* %.reg2mem21
  %arrayidx.prol.reload = load i32*, i32** %arrayidx.prol.reg2mem
  store i32 %.reload22, i32* %arrayidx.prol.reload, align 4, !tbaa !1
  %.reload25 = load i32, i32* %.reg2mem24
  %arrayidx5.prol.reload = load i32*, i32** %arrayidx5.prol.reg2mem
  store i32 %.reload25, i32* %arrayidx5.prol.reload, align 4, !tbaa !1
  br label %for.cond1.backedge.prol

for.cond1.backedge.prol:                          ; preds = %for.body3.prol.for.cond1.backedge.prol_crit_edge, %if.then.prol
  %j.0.prol.reload = load i32, i32* %j.0.prol.reg2mem
  %j.027.reload35 = load i32, i32* %j.027.reg2mem
  store i32 %j.027.reload35, i32* %j.0.in29.unr.ph.reg2mem49
  store i32 %j.0.prol.reload, i32* %j.030.unr.ph.reg2mem51
  br label %for.body3.prol.loopexit.unr-lcssa

for.body3.prol.loopexit.unr-lcssa:                ; preds = %for.body3.preheader.for.body3.prol.loopexit.unr-lcssa_crit_edge, %for.cond1.backedge.prol
  %j.030.unr.ph.reload52 = load i32, i32* %j.030.unr.ph.reg2mem51
  %j.0.in29.unr.ph.reload50 = load i32, i32* %j.0.in29.unr.ph.reg2mem49
  store i32 %j.030.unr.ph.reload52, i32* %j.030.unr.ph.reg2mem
  store i32 %j.0.in29.unr.ph.reload50, i32* %j.0.in29.unr.ph.reg2mem
  br label %for.body3.prol.loopexit

for.body3.prol.loopexit:                          ; preds = %for.body3.prol.loopexit.unr-lcssa
  %i.032.reload = load i32, i32* %i.032.reg2mem
  %.reload34 = load i32, i32* %.reg2mem33
  %5 = icmp eq i32 %.reload34, %i.032.reload
  br i1 %5, label %for.body3.prol.loopexit.for.inc13.loopexit_crit_edge, label %for.body3.preheader.new

for.body3.prol.loopexit.for.inc13.loopexit_crit_edge: ; preds = %for.body3.prol.loopexit
  br label %for.inc13.loopexit

for.body3.preheader.new:                          ; preds = %for.body3.prol.loopexit
  %j.0.in29.unr.ph.reload = load i32, i32* %j.0.in29.unr.ph.reg2mem
  %j.030.unr.ph.reload = load i32, i32* %j.030.unr.ph.reg2mem
  store i32 %j.0.in29.unr.ph.reload, i32* %j.0.in29.reg2mem
  store i32 %j.030.unr.ph.reload, i32* %j.030.reg2mem47
  br label %for.body3

for.body3:                                        ; preds = %for.cond1.backedge.1.for.body3_crit_edge, %for.body3.preheader.new
  %j.030.reload48 = load i32, i32* %j.030.reg2mem47
  %j.0.in29.reload = load i32, i32* %j.0.in29.reg2mem
  store i32 %j.030.reload48, i32* %j.030.reg2mem
  %j.030.reload20 = load i32, i32* %j.030.reg2mem
  %arrayidx = getelementptr inbounds [20 x i32], [20 x i32]* @N, i32 0, i32 %j.030.reload20
  store i32* %arrayidx, i32** %arrayidx.reg2mem
  %arrayidx.reload17 = load i32*, i32** %arrayidx.reg2mem
  %6 = load i32, i32* %arrayidx.reload17, align 4, !tbaa !1
  store i32 %6, i32* %.reg2mem14
  %sub4 = add nsw i32 %j.0.in29.reload, -2
  %arrayidx5 = getelementptr inbounds [20 x i32], [20 x i32]* @N, i32 0, i32 %sub4
  store i32* %arrayidx5, i32** %arrayidx5.reg2mem
  %arrayidx5.reload13 = load i32*, i32** %arrayidx5.reg2mem
  %7 = load i32, i32* %arrayidx5.reload13, align 4, !tbaa !1
  store i32 %7, i32* %.reg2mem10
  %.reload12 = load i32, i32* %.reg2mem10
  %.reload16 = load i32, i32* %.reg2mem14
  %cmp6 = icmp slt i32 %.reload16, %.reload12
  br i1 %cmp6, label %if.then, label %for.body3.for.cond1.backedge_crit_edge

for.body3.for.cond1.backedge_crit_edge:           ; preds = %for.body3
  br label %for.cond1.backedge

for.cond1.backedge:                               ; preds = %for.body3.for.cond1.backedge_crit_edge, %if.then
  %j.030.reload19 = load i32, i32* %j.030.reg2mem
  %j.0 = add nsw i32 %j.030.reload19, -1
  store i32 %j.0, i32* %j.0.reg2mem
  %j.0.reload9 = load i32, i32* %j.0.reg2mem
  %arrayidx.1 = getelementptr inbounds [20 x i32], [20 x i32]* @N, i32 0, i32 %j.0.reload9
  store i32* %arrayidx.1, i32** %arrayidx.1.reg2mem
  %arrayidx.1.reload8 = load i32*, i32** %arrayidx.1.reg2mem
  %8 = load i32, i32* %arrayidx.1.reload8, align 4, !tbaa !1
  store i32 %8, i32* %.reg2mem5
  %j.030.reload18 = load i32, i32* %j.030.reg2mem
  %sub4.1 = add nsw i32 %j.030.reload18, -2
  %arrayidx5.1 = getelementptr inbounds [20 x i32], [20 x i32]* @N, i32 0, i32 %sub4.1
  store i32* %arrayidx5.1, i32** %arrayidx5.1.reg2mem
  %arrayidx5.1.reload4 = load i32*, i32** %arrayidx5.1.reg2mem
  %9 = load i32, i32* %arrayidx5.1.reload4, align 4, !tbaa !1
  store i32 %9, i32* %.reg2mem
  %.reload3 = load i32, i32* %.reg2mem
  %.reload7 = load i32, i32* %.reg2mem5
  %cmp6.1 = icmp slt i32 %.reload7, %.reload3
  br i1 %cmp6.1, label %if.then.1, label %for.cond1.backedge.for.cond1.backedge.1_crit_edge

for.cond1.backedge.for.cond1.backedge.1_crit_edge: ; preds = %for.cond1.backedge
  br label %for.cond1.backedge.1

if.then:                                          ; preds = %for.body3
  %.reload11 = load i32, i32* %.reg2mem10
  %arrayidx.reload = load i32*, i32** %arrayidx.reg2mem
  store i32 %.reload11, i32* %arrayidx.reload, align 4, !tbaa !1
  %arrayidx5.reload = load i32*, i32** %arrayidx5.reg2mem
  %.reload15 = load i32, i32* %.reg2mem14
  store i32 %.reload15, i32* %arrayidx5.reload, align 4, !tbaa !1
  br label %for.cond1.backedge

for.inc13.loopexit.unr-lcssa:                     ; preds = %for.cond1.backedge.1
  br label %for.inc13.loopexit

for.inc13.loopexit:                               ; preds = %for.body3.prol.loopexit.for.inc13.loopexit_crit_edge, %for.inc13.loopexit.unr-lcssa
  br label %for.inc13

for.inc13:                                        ; preds = %for.cond1.preheader.for.inc13_crit_edge, %for.inc13.loopexit
  %i.032.reload29 = load i32, i32* %i.032.reg2mem
  %inc = add nuw nsw i32 %i.032.reload29, 1
  store i32 %inc, i32* %inc.reg2mem
  %inc.reload2 = load i32, i32* %inc.reg2mem
  %.reload45 = load i32, i32* %.reg2mem39
  %cmp = icmp slt i32 %inc.reload2, %.reload45
  br i1 %cmp, label %for.inc13.for.cond1.preheader_crit_edge, label %for.end14.loopexit

for.inc13.for.cond1.preheader_crit_edge:          ; preds = %for.inc13
  %inc.reload = load i32, i32* %inc.reg2mem
  store i32 %inc.reload, i32* %i.032.reg2mem53
  br label %for.cond1.preheader

for.end14.loopexit:                               ; preds = %for.inc13
  br label %for.end14

for.end14:                                        ; preds = %entry.for.end14_crit_edge, %for.end14.loopexit
  ret i32 0

if.then.1:                                        ; preds = %for.cond1.backedge
  %.reload = load i32, i32* %.reg2mem
  %arrayidx.1.reload = load i32*, i32** %arrayidx.1.reg2mem
  store i32 %.reload, i32* %arrayidx.1.reload, align 4, !tbaa !1
  %arrayidx5.1.reload = load i32*, i32** %arrayidx5.1.reg2mem
  %.reload6 = load i32, i32* %.reg2mem5
  store i32 %.reload6, i32* %arrayidx5.1.reload, align 4, !tbaa !1
  br label %for.cond1.backedge.1

for.cond1.backedge.1:                             ; preds = %for.cond1.backedge.for.cond1.backedge.1_crit_edge, %if.then.1
  %j.030.reload = load i32, i32* %j.030.reg2mem
  %j.0.1 = add nsw i32 %j.030.reload, -2
  store i32 %j.0.1, i32* %j.0.1.reg2mem
  %j.0.1.reload1 = load i32, i32* %j.0.1.reg2mem
  %i.032.reload28 = load i32, i32* %i.032.reg2mem
  %cmp2.1 = icmp sgt i32 %j.0.1.reload1, %i.032.reload28
  br i1 %cmp2.1, label %for.cond1.backedge.1.for.body3_crit_edge, label %for.inc13.loopexit.unr-lcssa

for.cond1.backedge.1.for.body3_crit_edge:         ; preds = %for.cond1.backedge.1
  %j.0.1.reload = load i32, i32* %j.0.1.reg2mem
  %j.0.reload = load i32, i32* %j.0.reg2mem
  store i32 %j.0.reload, i32* %j.0.in29.reg2mem
  store i32 %j.0.1.reload, i32* %j.030.reg2mem47
  br label %for.body3
}

attributes #0 = { norecurse nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-features"="-satom" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
!1 = !{!2, !2, i64 0}
!2 = !{!"int", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
