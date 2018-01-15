; ModuleID = 'test/test_code_bubble_sort/bubble.c'
source_filename = "test/test_code_bubble_sort/bubble.c"
target datalayout = "e-p:32:32-i64:64-v16:16-v32:32-n16:32:64"
target triple = "nvptx"

@N = local_unnamed_addr global [20 x i32] [i32 23002, i32 13359, i32 11466, i32 64118, i32 32403, i32 44024, i32 63253, i32 51654, i32 60960, i32 45232, i32 28137, i32 40242, i32 27545, i32 10747, i32 18543, i32 32541, i32 9632, i32 59878, i32 43528, i32 6841], align 4
@len = local_unnamed_addr global i32 20, align 4

; Function Attrs: norecurse nounwind
define i32 @main() local_unnamed_addr #0 {
entry:
  %0 = load i32, i32* @len, align 4, !tbaa !1
  %cmp31 = icmp sgt i32 %0, 0
  br i1 %cmp31, label %for.cond1.preheader.preheader, label %for.end14

for.cond1.preheader.preheader:                    ; preds = %entry
  %j.027 = add nsw i32 %0, -1
  %1 = add i32 %0, -2
  %arrayidx.prol = getelementptr inbounds [20 x i32], [20 x i32]* @N, i32 0, i32 %j.027
  %sub4.prol = add nsw i32 %0, -2
  %arrayidx5.prol = getelementptr inbounds [20 x i32], [20 x i32]* @N, i32 0, i32 %sub4.prol
  %j.0.prol = add nsw i32 %0, -2
  br label %for.cond1.preheader

for.cond1.preheader:                              ; preds = %for.cond1.preheader.preheader, %for.inc13
  %i.032 = phi i32 [ %inc, %for.inc13 ], [ 0, %for.cond1.preheader.preheader ]
  %cmp228 = icmp sgt i32 %j.027, %i.032
  br i1 %cmp228, label %for.body3.preheader, label %for.inc13

for.body3.preheader:                              ; preds = %for.cond1.preheader
  %2 = sub i32 %j.027, %i.032
  %xtraiter = and i32 %2, 1
  %lcmp.mod = icmp eq i32 %xtraiter, 0
  br i1 %lcmp.mod, label %for.body3.prol.loopexit.unr-lcssa, label %for.body3.prol.preheader

for.body3.prol.preheader:                         ; preds = %for.body3.preheader
  br label %for.body3.prol

for.body3.prol:                                   ; preds = %for.body3.prol.preheader
  %3 = load i32, i32* %arrayidx.prol, align 4, !tbaa !1
  %4 = load i32, i32* %arrayidx5.prol, align 4, !tbaa !1
  %cmp6.prol = icmp slt i32 %3, %4
  br i1 %cmp6.prol, label %if.then.prol, label %for.cond1.backedge.prol

if.then.prol:                                     ; preds = %for.body3.prol
  store i32 %4, i32* %arrayidx.prol, align 4, !tbaa !1
  store i32 %3, i32* %arrayidx5.prol, align 4, !tbaa !1
  br label %for.cond1.backedge.prol

for.cond1.backedge.prol:                          ; preds = %if.then.prol, %for.body3.prol
  br label %for.body3.prol.loopexit.unr-lcssa

for.body3.prol.loopexit.unr-lcssa:                ; preds = %for.body3.preheader, %for.cond1.backedge.prol
  %j.030.unr.ph = phi i32 [ %j.0.prol, %for.cond1.backedge.prol ], [ %j.027, %for.body3.preheader ]
  %j.0.in29.unr.ph = phi i32 [ %j.027, %for.cond1.backedge.prol ], [ %0, %for.body3.preheader ]
  br label %for.body3.prol.loopexit

for.body3.prol.loopexit:                          ; preds = %for.body3.prol.loopexit.unr-lcssa
  %5 = icmp eq i32 %1, %i.032
  br i1 %5, label %for.inc13.loopexit, label %for.body3.preheader.new

for.body3.preheader.new:                          ; preds = %for.body3.prol.loopexit
  br label %for.body3

for.body3:                                        ; preds = %for.cond1.backedge.1, %for.body3.preheader.new
  %j.030 = phi i32 [ %j.030.unr.ph, %for.body3.preheader.new ], [ %j.0.1, %for.cond1.backedge.1 ]
  %j.0.in29 = phi i32 [ %j.0.in29.unr.ph, %for.body3.preheader.new ], [ %j.0, %for.cond1.backedge.1 ]
  %arrayidx = getelementptr inbounds [20 x i32], [20 x i32]* @N, i32 0, i32 %j.030
  %6 = load i32, i32* %arrayidx, align 4, !tbaa !1
  %sub4 = add nsw i32 %j.0.in29, -2
  %arrayidx5 = getelementptr inbounds [20 x i32], [20 x i32]* @N, i32 0, i32 %sub4
  %7 = load i32, i32* %arrayidx5, align 4, !tbaa !1
  %cmp6 = icmp slt i32 %6, %7
  br i1 %cmp6, label %if.then, label %for.cond1.backedge

for.cond1.backedge:                               ; preds = %for.body3, %if.then
  %j.0 = add nsw i32 %j.030, -1
  %arrayidx.1 = getelementptr inbounds [20 x i32], [20 x i32]* @N, i32 0, i32 %j.0
  %8 = load i32, i32* %arrayidx.1, align 4, !tbaa !1
  %sub4.1 = add nsw i32 %j.030, -2
  %arrayidx5.1 = getelementptr inbounds [20 x i32], [20 x i32]* @N, i32 0, i32 %sub4.1
  %9 = load i32, i32* %arrayidx5.1, align 4, !tbaa !1
  %cmp6.1 = icmp slt i32 %8, %9
  br i1 %cmp6.1, label %if.then.1, label %for.cond1.backedge.1

if.then:                                          ; preds = %for.body3
  store i32 %7, i32* %arrayidx, align 4, !tbaa !1
  store i32 %6, i32* %arrayidx5, align 4, !tbaa !1
  br label %for.cond1.backedge

for.inc13.loopexit.unr-lcssa:                     ; preds = %for.cond1.backedge.1
  br label %for.inc13.loopexit

for.inc13.loopexit:                               ; preds = %for.body3.prol.loopexit, %for.inc13.loopexit.unr-lcssa
  br label %for.inc13

for.inc13:                                        ; preds = %for.inc13.loopexit, %for.cond1.preheader
  %inc = add nuw nsw i32 %i.032, 1
  %cmp = icmp slt i32 %inc, %0
  br i1 %cmp, label %for.cond1.preheader, label %for.end14.loopexit

for.end14.loopexit:                               ; preds = %for.inc13
  br label %for.end14

for.end14:                                        ; preds = %for.end14.loopexit, %entry
  ret i32 0

if.then.1:                                        ; preds = %for.cond1.backedge
  store i32 %9, i32* %arrayidx.1, align 4, !tbaa !1
  store i32 %8, i32* %arrayidx5.1, align 4, !tbaa !1
  br label %for.cond1.backedge.1

for.cond1.backedge.1:                             ; preds = %if.then.1, %for.cond1.backedge
  %j.0.1 = add nsw i32 %j.030, -2
  %cmp2.1 = icmp sgt i32 %j.0.1, %i.032
  br i1 %cmp2.1, label %for.body3, label %for.inc13.loopexit.unr-lcssa
}

attributes #0 = { norecurse nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-features"="-satom" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
!1 = !{!2, !2, i64 0}
!2 = !{!"int", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
