; ModuleID = '/Users/jingyuan.zhao/Desktop/subneg4-js/s4c/test/fixtures/bubble_sort.c'
source_filename = "/Users/jingyuan.zhao/Desktop/subneg4-js/s4c/test/fixtures/bubble_sort.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx15.0.0"

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca [5 x i32], align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  %7 = getelementptr inbounds [5 x i32], ptr %2, i64 0, i64 0
  store i32 50, ptr %7, align 4
  %8 = getelementptr inbounds [5 x i32], ptr %2, i64 0, i64 1
  store i32 20, ptr %8, align 4
  %9 = getelementptr inbounds [5 x i32], ptr %2, i64 0, i64 2
  store i32 40, ptr %9, align 4
  %10 = getelementptr inbounds [5 x i32], ptr %2, i64 0, i64 3
  store i32 10, ptr %10, align 4
  %11 = getelementptr inbounds [5 x i32], ptr %2, i64 0, i64 4
  store i32 30, ptr %11, align 4
  store i32 5, ptr %3, align 4
  store i32 0, ptr %4, align 4
  br label %12

12:                                               ; preds = %59, %0
  %13 = load i32, ptr %4, align 4
  %14 = load i32, ptr %3, align 4
  %15 = sub nsw i32 %14, 1
  %16 = icmp slt i32 %13, %15
  br i1 %16, label %17, label %62

17:                                               ; preds = %12
  store i32 0, ptr %5, align 4
  br label %18

18:                                               ; preds = %55, %17
  %19 = load i32, ptr %5, align 4
  %20 = load i32, ptr %3, align 4
  %21 = load i32, ptr %4, align 4
  %22 = sub nsw i32 %20, %21
  %23 = sub nsw i32 %22, 1
  %24 = icmp slt i32 %19, %23
  br i1 %24, label %25, label %58

25:                                               ; preds = %18
  %26 = load i32, ptr %5, align 4
  %27 = sext i32 %26 to i64
  %28 = getelementptr inbounds [5 x i32], ptr %2, i64 0, i64 %27
  %29 = load i32, ptr %28, align 4
  %30 = load i32, ptr %5, align 4
  %31 = add nsw i32 %30, 1
  %32 = sext i32 %31 to i64
  %33 = getelementptr inbounds [5 x i32], ptr %2, i64 0, i64 %32
  %34 = load i32, ptr %33, align 4
  %35 = icmp sgt i32 %29, %34
  br i1 %35, label %36, label %54

36:                                               ; preds = %25
  %37 = load i32, ptr %5, align 4
  %38 = sext i32 %37 to i64
  %39 = getelementptr inbounds [5 x i32], ptr %2, i64 0, i64 %38
  %40 = load i32, ptr %39, align 4
  store i32 %40, ptr %6, align 4
  %41 = load i32, ptr %5, align 4
  %42 = add nsw i32 %41, 1
  %43 = sext i32 %42 to i64
  %44 = getelementptr inbounds [5 x i32], ptr %2, i64 0, i64 %43
  %45 = load i32, ptr %44, align 4
  %46 = load i32, ptr %5, align 4
  %47 = sext i32 %46 to i64
  %48 = getelementptr inbounds [5 x i32], ptr %2, i64 0, i64 %47
  store i32 %45, ptr %48, align 4
  %49 = load i32, ptr %6, align 4
  %50 = load i32, ptr %5, align 4
  %51 = add nsw i32 %50, 1
  %52 = sext i32 %51 to i64
  %53 = getelementptr inbounds [5 x i32], ptr %2, i64 0, i64 %52
  store i32 %49, ptr %53, align 4
  br label %54

54:                                               ; preds = %36, %25
  br label %55

55:                                               ; preds = %54
  %56 = load i32, ptr %5, align 4
  %57 = add nsw i32 %56, 1
  store i32 %57, ptr %5, align 4
  br label %18, !llvm.loop !6

58:                                               ; preds = %18
  br label %59

59:                                               ; preds = %58
  %60 = load i32, ptr %4, align 4
  %61 = add nsw i32 %60, 1
  store i32 %61, ptr %4, align 4
  br label %12, !llvm.loop !8

62:                                               ; preds = %12
  %63 = getelementptr inbounds [5 x i32], ptr %2, i64 0, i64 0
  %64 = load i32, ptr %63, align 4
  %65 = getelementptr inbounds [5 x i32], ptr %2, i64 0, i64 4
  %66 = load i32, ptr %65, align 4
  %67 = add nsw i32 %64, %66
  ret i32 %67
}

attributes #0 = { noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+bti,+ccdp,+ccidx,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8a,+zcm,+zcz" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 26, i32 0]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 1}
!5 = !{!"Apple clang version 17.0.0 (clang-1700.3.19.1)"}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
!8 = distinct !{!8, !7}
