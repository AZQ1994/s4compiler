; ModuleID = '/Users/jingyuan.zhao/Desktop/subneg4-js/s4c/test/fixtures/collatz.c'
source_filename = "/Users/jingyuan.zhao/Desktop/subneg4-js/s4c/test/fixtures/collatz.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx15.0.0"

; Function Attrs: nofree norecurse nosync nounwind ssp memory(none) uwtable(sync)
define i32 @collatz_steps(i32 noundef %0) local_unnamed_addr #0 {
  %2 = icmp eq i32 %0, 1
  br i1 %2, label %14, label %3

3:                                                ; preds = %1, %3
  %4 = phi i32 [ %12, %3 ], [ 0, %1 ]
  %5 = phi i32 [ %11, %3 ], [ %0, %1 ]
  %6 = and i32 %5, 1
  %7 = icmp eq i32 %6, 0
  %8 = ashr exact i32 %5, 1
  %9 = mul nsw i32 %5, 3
  %10 = add nsw i32 %9, 1
  %11 = select i1 %7, i32 %8, i32 %10
  %12 = add nuw nsw i32 %4, 1
  %13 = icmp eq i32 %11, 1
  br i1 %13, label %14, label %3, !llvm.loop !6

14:                                               ; preds = %3, %1
  %15 = phi i32 [ 0, %1 ], [ %12, %3 ]
  ret i32 %15
}

; Function Attrs: nofree norecurse nosync nounwind ssp memory(none) uwtable(sync)
define i32 @main() local_unnamed_addr #0 {
  br label %1

1:                                                ; preds = %1, %0
  %2 = phi i32 [ %10, %1 ], [ 0, %0 ]
  %3 = phi i32 [ %9, %1 ], [ 27, %0 ]
  %4 = and i32 %3, 1
  %5 = icmp eq i32 %4, 0
  %6 = ashr exact i32 %3, 1
  %7 = mul nsw i32 %3, 3
  %8 = add nsw i32 %7, 1
  %9 = select i1 %5, i32 %6, i32 %8
  %10 = add nuw nsw i32 %2, 1
  %11 = icmp eq i32 %9, 1
  br i1 %11, label %12, label %1, !llvm.loop !6

12:                                               ; preds = %1
  ret i32 %10
}

attributes #0 = { nofree norecurse nosync nounwind ssp memory(none) uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 0]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 1}
!5 = !{!"Apple clang version 17.0.0 (clang-1700.3.19.1)"}
!6 = distinct !{!6, !7, !8}
!7 = !{!"llvm.loop.mustprogress"}
!8 = !{!"llvm.loop.unroll.disable"}
