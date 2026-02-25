; ModuleID = 'test/fixtures/quick_medium.c'
source_filename = "test/fixtures/quick_medium.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx15.0.0"

@data = global [20 x i32] [i32 85, i32 24, i32 63, i32 45, i32 17, i32 31, i32 96, i32 50, i32 78, i32 12, i32 67, i32 39, i32 54, i32 88, i32 21, i32 73, i32 42, i32 60, i32 35, i32 9], align 4

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @quick(i32 noundef %0, i32 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  store i32 %0, ptr %4, align 4
  store i32 %1, ptr %5, align 4
  %11 = load i32, ptr %4, align 4
  %12 = load i32, ptr %5, align 4
  %13 = icmp sge i32 %11, %12
  br i1 %13, label %14, label %15

14:                                               ; preds = %2
  store i32 0, ptr %3, align 4
  br label %79

15:                                               ; preds = %2
  %16 = load i32, ptr %4, align 4
  store i32 %16, ptr %6, align 4
  %17 = load i32, ptr %6, align 4
  %18 = sext i32 %17 to i64
  %19 = getelementptr inbounds [20 x i32], ptr @data, i64 0, i64 %18
  %20 = load i32, ptr %19, align 4
  store i32 %20, ptr %7, align 4
  %21 = load i32, ptr %4, align 4
  store i32 %21, ptr %8, align 4
  %22 = load i32, ptr %5, align 4
  store i32 %22, ptr %9, align 4
  br label %23

23:                                               ; preds = %15, %50
  br label %24

24:                                               ; preds = %31, %23
  %25 = load i32, ptr %8, align 4
  %26 = sext i32 %25 to i64
  %27 = getelementptr inbounds [20 x i32], ptr @data, i64 0, i64 %26
  %28 = load i32, ptr %27, align 4
  %29 = load i32, ptr %7, align 4
  %30 = icmp slt i32 %28, %29
  br i1 %30, label %31, label %34

31:                                               ; preds = %24
  %32 = load i32, ptr %8, align 4
  %33 = add nsw i32 %32, 1
  store i32 %33, ptr %8, align 4
  br label %24, !llvm.loop !6

34:                                               ; preds = %24
  br label %35

35:                                               ; preds = %42, %34
  %36 = load i32, ptr %9, align 4
  %37 = sext i32 %36 to i64
  %38 = getelementptr inbounds [20 x i32], ptr @data, i64 0, i64 %37
  %39 = load i32, ptr %38, align 4
  %40 = load i32, ptr %7, align 4
  %41 = icmp sgt i32 %39, %40
  br i1 %41, label %42, label %45

42:                                               ; preds = %35
  %43 = load i32, ptr %9, align 4
  %44 = add nsw i32 %43, -1
  store i32 %44, ptr %9, align 4
  br label %35, !llvm.loop !8

45:                                               ; preds = %35
  %46 = load i32, ptr %8, align 4
  %47 = load i32, ptr %9, align 4
  %48 = icmp sge i32 %46, %47
  br i1 %48, label %49, label %50

49:                                               ; preds = %45
  br label %70

50:                                               ; preds = %45
  %51 = load i32, ptr %8, align 4
  %52 = sext i32 %51 to i64
  %53 = getelementptr inbounds [20 x i32], ptr @data, i64 0, i64 %52
  %54 = load i32, ptr %53, align 4
  store i32 %54, ptr %10, align 4
  %55 = load i32, ptr %9, align 4
  %56 = sext i32 %55 to i64
  %57 = getelementptr inbounds [20 x i32], ptr @data, i64 0, i64 %56
  %58 = load i32, ptr %57, align 4
  %59 = load i32, ptr %8, align 4
  %60 = sext i32 %59 to i64
  %61 = getelementptr inbounds [20 x i32], ptr @data, i64 0, i64 %60
  store i32 %58, ptr %61, align 4
  %62 = load i32, ptr %10, align 4
  %63 = load i32, ptr %9, align 4
  %64 = sext i32 %63 to i64
  %65 = getelementptr inbounds [20 x i32], ptr @data, i64 0, i64 %64
  store i32 %62, ptr %65, align 4
  %66 = load i32, ptr %8, align 4
  %67 = add nsw i32 %66, 1
  store i32 %67, ptr %8, align 4
  %68 = load i32, ptr %9, align 4
  %69 = add nsw i32 %68, -1
  store i32 %69, ptr %9, align 4
  br label %23

70:                                               ; preds = %49
  %71 = load i32, ptr %4, align 4
  %72 = load i32, ptr %8, align 4
  %73 = sub nsw i32 %72, 1
  %74 = call i32 @quick(i32 noundef %71, i32 noundef %73)
  %75 = load i32, ptr %9, align 4
  %76 = add nsw i32 %75, 1
  %77 = load i32, ptr %5, align 4
  %78 = call i32 @quick(i32 noundef %76, i32 noundef %77)
  store i32 0, ptr %3, align 4
  br label %79

79:                                               ; preds = %70, %14
  %80 = load i32, ptr %3, align 4
  ret i32 %80
}

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @main() #0 {
  %1 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  %2 = call i32 @quick(i32 noundef 0, i32 noundef 19)
  %3 = load i32, ptr @data, align 4
  %4 = load i32, ptr getelementptr inbounds ([20 x i32], ptr @data, i64 0, i64 19), align 4
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
