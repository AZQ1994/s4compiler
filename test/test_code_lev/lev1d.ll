; ModuleID = 'lev1d.c'
source_filename = "lev1d.c"
target datalayout = "E-m:e-p:32:32-i64:64-n32"
target triple = "ppc32"

@data = local_unnamed_addr global [128 x i32] [i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31, i32 32, i32 33, i32 34, i32 35, i32 36, i32 37, i32 38, i32 39, i32 40, i32 41, i32 42, i32 43, i32 44, i32 45, i32 46, i32 47, i32 48, i32 49, i32 50, i32 51, i32 52, i32 53, i32 54, i32 55, i32 56, i32 57, i32 58, i32 59, i32 60, i32 61, i32 62, i32 63, i32 64, i32 65, i32 66, i32 67, i32 68, i32 69, i32 70, i32 71, i32 72, i32 73, i32 74, i32 75, i32 76, i32 77, i32 78, i32 79, i32 80, i32 81, i32 82, i32 83, i32 84, i32 85, i32 86, i32 87, i32 88, i32 89, i32 90, i32 91, i32 92, i32 93, i32 94, i32 95, i32 96, i32 97, i32 98, i32 99, i32 100, i32 101, i32 102, i32 103, i32 104, i32 105, i32 106, i32 107, i32 108, i32 109, i32 110, i32 111, i32 112, i32 113, i32 114, i32 115, i32 116, i32 117, i32 118, i32 119, i32 120, i32 121, i32 122, i32 123, i32 124, i32 125, i32 126, i32 127], align 4
@main.str1 = private unnamed_addr constant [128 x i32] [i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0, i32 107, i32 105, i32 116, i32 116, i32 101, i32 110, i32 0, i32 0], align 4
@main.str2 = private unnamed_addr constant [128 x i32] [i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0, i32 115, i32 105, i32 116, i32 116, i32 105, i32 110, i32 103, i32 0], align 4

; Function Attrs: norecurse nounwind
define i32 @main() local_unnamed_addr #0 {
entry:
  br label %while.body

while.cond.loopexit:                              ; preds = %if.end59
  %exitcond122 = icmp eq i32 %add, 128
  br i1 %exitcond122, label %while.end, label %while.body

while.body:                                       ; preds = %while.cond.loopexit, %entry
  %j.0121 = phi i32 [ 0, %entry ], [ %add, %while.cond.loopexit ]
  %add = add nuw nsw i32 %j.0121, 1
  %arrayidx2 = getelementptr inbounds [128 x i32], [128 x i32]* @main.str2, i32 0, i32 %j.0121
  %0 = load i32, i32* %arrayidx2, align 4, !tbaa !1
  br label %for.body

for.body:                                         ; preds = %if.end59, %while.body
  %i.0120 = phi i32 [ 0, %while.body ], [ %inc, %if.end59 ]
  %left_top.0119 = phi i32 [ %j.0121, %while.body ], [ %2, %if.end59 ]
  %left.0118 = phi i32 [ %add, %while.body ], [ %left.1, %if.end59 ]
  %arrayidx = getelementptr inbounds [128 x i32], [128 x i32]* @main.str1, i32 0, i32 %i.0120
  %1 = load i32, i32* %arrayidx, align 4, !tbaa !1
  %cmp3 = icmp eq i32 %1, %0
  %cmp4 = icmp sle i32 %left_top.0119, %left.0118
  %arrayidx6 = getelementptr inbounds [128 x i32], [128 x i32]* @data, i32 0, i32 %i.0120
  %2 = load i32, i32* %arrayidx6, align 4, !tbaa !1
  br i1 %cmp3, label %if.then, label %if.else30

if.then:                                          ; preds = %for.body
  br i1 %cmp4, label %if.then5, label %if.else16

if.then5:                                         ; preds = %if.then
  %add7 = add nsw i32 %2, 1
  %cmp8 = icmp slt i32 %add7, %left_top.0119
  %add7.left_top.0 = select i1 %cmp8, i32 %add7, i32 %left_top.0119
  br label %if.end59

if.else16:                                        ; preds = %if.then
  %cmp18 = icmp slt i32 %2, %left.0118
  br i1 %cmp18, label %if.then19, label %if.else24

if.then19:                                        ; preds = %if.else16
  %add21 = add nsw i32 %2, 1
  br label %if.end59

if.else24:                                        ; preds = %if.else16
  %add25 = add nsw i32 %left.0118, 1
  br label %if.end59

if.else30:                                        ; preds = %for.body
  br i1 %cmp4, label %if.then32, label %if.else45

if.then32:                                        ; preds = %if.else30
  %cmp34 = icmp slt i32 %2, %left_top.0119
  br i1 %cmp34, label %if.then35, label %if.else40

if.then35:                                        ; preds = %if.then32
  %add38 = add nsw i32 %2, 1
  br label %if.end59

if.else40:                                        ; preds = %if.then32
  %add41 = add nsw i32 %left_top.0119, 1
  br label %if.end59

if.else45:                                        ; preds = %if.else30
  %cmp47 = icmp slt i32 %2, %left.0118
  br i1 %cmp47, label %if.then48, label %if.else53

if.then48:                                        ; preds = %if.else45
  %add50 = add nsw i32 %2, 1
  br label %if.end59

if.else53:                                        ; preds = %if.else45
  %add54 = add nsw i32 %left.0118, 1
  br label %if.end59

if.end59:                                         ; preds = %if.then5, %if.else40, %if.then35, %if.else53, %if.then48, %if.else24, %if.then19
  %left.1 = phi i32 [ %add21, %if.then19 ], [ %add25, %if.else24 ], [ %add38, %if.then35 ], [ %add41, %if.else40 ], [ %add50, %if.then48 ], [ %add54, %if.else53 ], [ %add7.left_top.0, %if.then5 ]
  store i32 %left.1, i32* %arrayidx6, align 4, !tbaa !1
  %inc = add nuw nsw i32 %i.0120, 1
  %exitcond = icmp eq i32 %inc, 128
  br i1 %exitcond, label %while.cond.loopexit, label %for.body

while.end:                                        ; preds = %while.cond.loopexit
  ret i32 0
}

attributes #0 = { norecurse nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="ppc" "target-features"="-altivec,-bpermd,-crypto,-direct-move,-extdiv,-power8-vector,-power9-vector,-qpx,-vsx" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (trunk)"}
!1 = !{!2, !2, i64 0}
!2 = !{!"int", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
