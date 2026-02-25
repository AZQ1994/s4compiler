; ModuleID = '/Users/jingyuan.zhao/Desktop/subneg4-js/s4c/test/fixtures/fib.c'
source_filename = "/Users/jingyuan.zhao/Desktop/subneg4-js/s4c/test/fixtures/fib.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx15.0.0"

; Function Attrs: nofree nosync nounwind ssp memory(none) uwtable(sync)
define i32 @fib(i32 noundef %0) local_unnamed_addr #0 {
  br label %2

2:                                                ; preds = %6, %1
  %3 = phi i32 [ 0, %1 ], [ %10, %6 ]
  %4 = phi i32 [ %0, %1 ], [ %9, %6 ]
  %5 = icmp slt i32 %4, 2
  br i1 %5, label %11, label %6

6:                                                ; preds = %2
  %7 = add nsw i32 %4, -1
  %8 = tail call i32 @fib(i32 noundef %7)
  %9 = add nsw i32 %4, -2
  %10 = add nsw i32 %3, %8
  br label %2

11:                                               ; preds = %2
  %12 = add nsw i32 %3, %4
  ret i32 %12
}

; Function Attrs: nofree nosync nounwind ssp memory(none) uwtable(sync)
define i32 @main() local_unnamed_addr #0 {
  %1 = tail call i32 @fib(i32 noundef 10)
  ret i32 %1
}

attributes #0 = { nofree nosync nounwind ssp memory(none) uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 0]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 1}
!5 = !{!"Apple clang version 17.0.0 (clang-1700.3.19.1)"}
