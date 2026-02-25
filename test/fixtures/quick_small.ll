; ModuleID = 'test/fixtures/quick_small.c'
source_filename = "test/fixtures/quick_small.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx15.0.0"

@data = global [5 x i32] [i32 50, i32 20, i32 40, i32 10, i32 30], align 4

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @quick(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  store i32 %0, ptr %4, align 4
  store i32 %1, ptr %5, align 4
  %10 = load i32, ptr %4, align 4
  %11 = load i32, ptr %5, align 4
  %12 = icmp sge i32 %10, %11
  br i1 %12, label %13, label %14

13:                                               ; preds = %2
  store i32 0, ptr %3, align 4
  br label %77

14:                                               ; preds = %2
  %15 = load i32, ptr %5, align 4
  %16 = sext i32 %15 to i64
  %17 = getelementptr inbounds [5 x i32], ptr @data, i64 0, i64 %16
  %18 = load i32, ptr %17, align 4
  store i32 %18, ptr %6, align 4
  %19 = load i32, ptr %4, align 4
  store i32 %19, ptr %7, align 4
  %20 = load i32, ptr %5, align 4
  store i32 %20, ptr %8, align 4
  br label %21

21:                                               ; preds = %14, %48
  br label %22

22:                                               ; preds = %29, %21
  %23 = load i32, ptr %7, align 4
  %24 = sext i32 %23 to i64
  %25 = getelementptr inbounds [5 x i32], ptr @data, i64 0, i64 %24
  %26 = load i32, ptr %25, align 4
  %27 = load i32, ptr %6, align 4
  %28 = icmp slt i32 %26, %27
  br i1 %28, label %29, label %32

29:                                               ; preds = %22
  %30 = load i32, ptr %7, align 4
  %31 = add nsw i32 %30, 1
  store i32 %31, ptr %7, align 4
  br label %22, !llvm.loop !6

32:                                               ; preds = %22
  br label %33

33:                                               ; preds = %40, %32
  %34 = load i32, ptr %8, align 4
  %35 = sext i32 %34 to i64
  %36 = getelementptr inbounds [5 x i32], ptr @data, i64 0, i64 %35
  %37 = load i32, ptr %36, align 4
  %38 = load i32, ptr %6, align 4
  %39 = icmp sgt i32 %37, %38
  br i1 %39, label %40, label %43

40:                                               ; preds = %33
  %41 = load i32, ptr %8, align 4
  %42 = add nsw i32 %41, -1
  store i32 %42, ptr %8, align 4
  br label %33, !llvm.loop !8

43:                                               ; preds = %33
  %44 = load i32, ptr %7, align 4
  %45 = load i32, ptr %8, align 4
  %46 = icmp sge i32 %44, %45
  br i1 %46, label %47, label %48

47:                                               ; preds = %43
  br label %68

48:                                               ; preds = %43
  %49 = load i32, ptr %7, align 4
  %50 = sext i32 %49 to i64
  %51 = getelementptr inbounds [5 x i32], ptr @data, i64 0, i64 %50
  %52 = load i32, ptr %51, align 4
  store i32 %52, ptr %9, align 4
  %53 = load i32, ptr %8, align 4
  %54 = sext i32 %53 to i64
  %55 = getelementptr inbounds [5 x i32], ptr @data, i64 0, i64 %54
  %56 = load i32, ptr %55, align 4
  %57 = load i32, ptr %7, align 4
  %58 = sext i32 %57 to i64
  %59 = getelementptr inbounds [5 x i32], ptr @data, i64 0, i64 %58
  store i32 %56, ptr %59, align 4
  %60 = load i32, ptr %9, align 4
  %61 = load i32, ptr %8, align 4
  %62 = sext i32 %61 to i64
  %63 = getelementptr inbounds [5 x i32], ptr @data, i64 0, i64 %62
  store i32 %60, ptr %63, align 4
  %64 = load i32, ptr %7, align 4
  %65 = add nsw i32 %64, 1
  store i32 %65, ptr %7, align 4
  %66 = load i32, ptr %8, align 4
  %67 = add nsw i32 %66, -1
  store i32 %67, ptr %8, align 4
  br label %21

68:                                               ; preds = %47
  %69 = load i32, ptr %4, align 4
  %70 = load i32, ptr %7, align 4
  %71 = sub nsw i32 %70, 1
  %72 = call i32 @quick(i32 noundef %69, i32 noundef %71)
  %73 = load i32, ptr %8, align 4
  %74 = add nsw i32 %73, 1
  %75 = load i32, ptr %5, align 4
  %76 = call i32 @quick(i32 noundef %74, i32 noundef %75)
  store i32 0, ptr %3, align 4
  br label %77

77:                                               ; preds = %68, %13
  %78 = load i32, ptr %3, align 4
  ret i32 %78
}

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @main() #0 {
  %1 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  %2 = call i32 @quick(i32 noundef 0, i32 noundef 4)
  %3 = load i32, ptr @data, align 4
  %4 = load i32, ptr getelementptr inbounds ([5 x i32], ptr @data, i64 0, i64 4), align 4
  %5 = add nsw i32 %3, %4
  ret i32 %5
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
