; ModuleID = '/Users/jingyuan.zhao/Desktop/subneg4-js/s4c/test/fixtures/matmul.c'
source_filename = "/Users/jingyuan.zhao/Desktop/subneg4-js/s4c/test/fixtures/matmul.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx15.0.0"

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca [4 x i32], align 4
  %3 = alloca [4 x i32], align 4
  %4 = alloca [4 x i32], align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  %11 = getelementptr inbounds [4 x i32], ptr %2, i64 0, i64 0
  store i32 1, ptr %11, align 4
  %12 = getelementptr inbounds [4 x i32], ptr %2, i64 0, i64 1
  store i32 2, ptr %12, align 4
  %13 = getelementptr inbounds [4 x i32], ptr %2, i64 0, i64 2
  store i32 3, ptr %13, align 4
  %14 = getelementptr inbounds [4 x i32], ptr %2, i64 0, i64 3
  store i32 4, ptr %14, align 4
  %15 = getelementptr inbounds [4 x i32], ptr %3, i64 0, i64 0
  store i32 5, ptr %15, align 4
  %16 = getelementptr inbounds [4 x i32], ptr %3, i64 0, i64 1
  store i32 6, ptr %16, align 4
  %17 = getelementptr inbounds [4 x i32], ptr %3, i64 0, i64 2
  store i32 7, ptr %17, align 4
  %18 = getelementptr inbounds [4 x i32], ptr %3, i64 0, i64 3
  store i32 8, ptr %18, align 4
  store i32 0, ptr %5, align 4
  br label %19

19:                                               ; preds = %63, %0
  %20 = load i32, ptr %5, align 4
  %21 = icmp slt i32 %20, 2
  br i1 %21, label %22, label %66

22:                                               ; preds = %19
  store i32 0, ptr %6, align 4
  br label %23

23:                                               ; preds = %59, %22
  %24 = load i32, ptr %6, align 4
  %25 = icmp slt i32 %24, 2
  br i1 %25, label %26, label %62

26:                                               ; preds = %23
  store i32 0, ptr %7, align 4
  store i32 0, ptr %8, align 4
  br label %27

27:                                               ; preds = %48, %26
  %28 = load i32, ptr %8, align 4
  %29 = icmp slt i32 %28, 2
  br i1 %29, label %30, label %51

30:                                               ; preds = %27
  %31 = load i32, ptr %7, align 4
  %32 = load i32, ptr %5, align 4
  %33 = mul nsw i32 %32, 2
  %34 = load i32, ptr %8, align 4
  %35 = add nsw i32 %33, %34
  %36 = sext i32 %35 to i64
  %37 = getelementptr inbounds [4 x i32], ptr %2, i64 0, i64 %36
  %38 = load i32, ptr %37, align 4
  %39 = load i32, ptr %8, align 4
  %40 = mul nsw i32 %39, 2
  %41 = load i32, ptr %6, align 4
  %42 = add nsw i32 %40, %41
  %43 = sext i32 %42 to i64
  %44 = getelementptr inbounds [4 x i32], ptr %3, i64 0, i64 %43
  %45 = load i32, ptr %44, align 4
  %46 = mul nsw i32 %38, %45
  %47 = add nsw i32 %31, %46
  store i32 %47, ptr %7, align 4
  br label %48

48:                                               ; preds = %30
  %49 = load i32, ptr %8, align 4
  %50 = add nsw i32 %49, 1
  store i32 %50, ptr %8, align 4
  br label %27, !llvm.loop !6

51:                                               ; preds = %27
  %52 = load i32, ptr %7, align 4
  %53 = load i32, ptr %5, align 4
  %54 = mul nsw i32 %53, 2
  %55 = load i32, ptr %6, align 4
  %56 = add nsw i32 %54, %55
  %57 = sext i32 %56 to i64
  %58 = getelementptr inbounds [4 x i32], ptr %4, i64 0, i64 %57
  store i32 %52, ptr %58, align 4
  br label %59

59:                                               ; preds = %51
  %60 = load i32, ptr %6, align 4
  %61 = add nsw i32 %60, 1
  store i32 %61, ptr %6, align 4
  br label %23, !llvm.loop !8

62:                                               ; preds = %23
  br label %63

63:                                               ; preds = %62
  %64 = load i32, ptr %5, align 4
  %65 = add nsw i32 %64, 1
  store i32 %65, ptr %5, align 4
  br label %19, !llvm.loop !9

66:                                               ; preds = %19
  store i32 0, ptr %9, align 4
  store i32 0, ptr %10, align 4
  br label %67

67:                                               ; preds = %77, %66
  %68 = load i32, ptr %10, align 4
  %69 = icmp slt i32 %68, 4
  br i1 %69, label %70, label %80

70:                                               ; preds = %67
  %71 = load i32, ptr %9, align 4
  %72 = load i32, ptr %10, align 4
  %73 = sext i32 %72 to i64
  %74 = getelementptr inbounds [4 x i32], ptr %4, i64 0, i64 %73
  %75 = load i32, ptr %74, align 4
  %76 = add nsw i32 %71, %75
  store i32 %76, ptr %9, align 4
  br label %77

77:                                               ; preds = %70
  %78 = load i32, ptr %10, align 4
  %79 = add nsw i32 %78, 1
  store i32 %79, ptr %10, align 4
  br label %67, !llvm.loop !10

80:                                               ; preds = %67
  %81 = load i32, ptr %9, align 4
  ret i32 %81
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
!9 = distinct !{!9, !7}
!10 = distinct !{!10, !7}
