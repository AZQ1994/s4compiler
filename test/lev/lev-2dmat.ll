; ModuleID = 'lev-2dmat.c'
source_filename = "lev-2dmat.c"
target datalayout = "E-m:e-p:32:32-i64:64-n32"
target triple = "ppc32"

@data = local_unnamed_addr global [129 x [129 x i32]] zeroinitializer, align 4
@main.str1 = private unnamed_addr constant [128 x i8] c"kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  ", align 1
@main.str2 = private unnamed_addr constant [128 x i8] c"sitting sitting sitting sitting sitting sitting sitting sitting sitting sitting sitting sitting sitting sitting sitting sitting ", align 1

; Function Attrs: norecurse nounwind
define i32 @main() local_unnamed_addr #0 {
entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %i.0150 = phi i32 [ 0, %entry ], [ %inc, %for.body ]
  %arrayidx1 = getelementptr inbounds [129 x [129 x i32]], [129 x [129 x i32]]* @data, i32 0, i32 %i.0150, i32 0
  store i32 %i.0150, i32* %arrayidx1, align 4, !tbaa !1
  %arrayidx2 = getelementptr inbounds [129 x [129 x i32]], [129 x [129 x i32]]* @data, i32 0, i32 0, i32 %i.0150
  store i32 %i.0150, i32* %arrayidx2, align 4, !tbaa !1
  %inc = add nuw nsw i32 %i.0150, 1
  %exitcond152 = icmp eq i32 %inc, 129
  br i1 %exitcond152, label %for.cond6.preheader.preheader, label %for.body

for.cond6.preheader.preheader:                    ; preds = %for.body
  br label %for.cond6.preheader

for.cond6.preheader:                              ; preds = %for.cond6.preheader.preheader, %for.inc104
  %i.1149 = phi i32 [ %inc105, %for.inc104 ], [ 1, %for.cond6.preheader.preheader ]
  %sub = add nsw i32 %i.1149, -1
  %arrayidx27 = getelementptr inbounds [128 x i8], [128 x i8]* @main.str2, i32 0, i32 %sub
  %0 = load i8, i8* %arrayidx27, align 1, !tbaa !5
  %arrayidx13.phi.trans.insert = getelementptr inbounds [129 x [129 x i32]], [129 x [129 x i32]]* @data, i32 0, i32 %i.1149, i32 0
  %.pre = load i32, i32* %arrayidx13.phi.trans.insert, align 4, !tbaa !1
  %arrayidx23.phi.trans.insert = getelementptr inbounds [129 x [129 x i32]], [129 x [129 x i32]]* @data, i32 0, i32 %sub, i32 0
  %.pre153 = load i32, i32* %arrayidx23.phi.trans.insert, align 4, !tbaa !1
  br label %for.body8

for.body8:                                        ; preds = %for.body8, %for.cond6.preheader
  %1 = phi i32 [ %.pre153, %for.cond6.preheader ], [ %3, %for.body8 ]
  %2 = phi i32 [ %.pre, %for.cond6.preheader ], [ %cond98, %for.body8 ]
  %j.0148 = phi i32 [ 1, %for.cond6.preheader ], [ %inc102, %for.body8 ]
  %arrayidx10 = getelementptr inbounds [129 x [129 x i32]], [129 x [129 x i32]]* @data, i32 0, i32 %sub, i32 %j.0148
  %3 = load i32, i32* %arrayidx10, align 4, !tbaa !1
  %add = add nsw i32 %3, 1
  %sub12 = add nsw i32 %j.0148, -1
  %add14 = add nsw i32 %2, 1
  %cmp15 = icmp slt i32 %3, %2
  %arrayidx25 = getelementptr inbounds [128 x i8], [128 x i8]* @main.str1, i32 0, i32 %sub12
  %4 = load i8, i8* %arrayidx25, align 1, !tbaa !5
  %not.cmp29 = icmp ne i8 %4, %0
  %cond = zext i1 %not.cmp29 to i32
  %add31 = add nsw i32 %cond, %1
  %cmp32 = icmp slt i32 %add, %add31
  %add.add31 = select i1 %cmp32, i32 %add, i32 %add31
  %cmp73 = icmp slt i32 %add14, %add31
  %add14.add31 = select i1 %cmp73, i32 %add14, i32 %add31
  %cond98 = select i1 %cmp15, i32 %add.add31, i32 %add14.add31
  %arrayidx100 = getelementptr inbounds [129 x [129 x i32]], [129 x [129 x i32]]* @data, i32 0, i32 %i.1149, i32 %j.0148
  store i32 %cond98, i32* %arrayidx100, align 4, !tbaa !1
  %inc102 = add nuw nsw i32 %j.0148, 1
  %exitcond = icmp eq i32 %inc102, 129
  br i1 %exitcond, label %for.inc104, label %for.body8

for.inc104:                                       ; preds = %for.body8
  %inc105 = add nuw nsw i32 %i.1149, 1
  %exitcond151 = icmp eq i32 %inc105, 129
  br i1 %exitcond151, label %for.end106, label %for.cond6.preheader

for.end106:                                       ; preds = %for.inc104
  ret i32 0
}

attributes #0 = { norecurse nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="ppc" "target-features"="-altivec,-bpermd,-crypto,-direct-move,-extdiv,-power8-vector,-power9-vector,-qpx,-vsx" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
!1 = !{!2, !2, i64 0}
!2 = !{!"int", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!3, !3, i64 0}
