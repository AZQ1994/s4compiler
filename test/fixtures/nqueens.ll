; ModuleID = 'test/fixtures/nqueens.c'
source_filename = "test/fixtures/nqueens.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx15.0.0"

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @safe(ptr noundef %0, i32 noundef %1, i32 noundef %2) #0 {
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  store ptr %0, ptr %5, align 8
  store i32 %1, ptr %6, align 4
  store i32 %2, ptr %7, align 4
  store i32 0, ptr %8, align 4
  br label %10

10:                                               ; preds = %49, %3
  %11 = load i32, ptr %8, align 4
  %12 = load i32, ptr %6, align 4
  %13 = icmp slt i32 %11, %12
  br i1 %13, label %14, label %52

14:                                               ; preds = %10
  %15 = load ptr, ptr %5, align 8
  %16 = load i32, ptr %8, align 4
  %17 = sext i32 %16 to i64
  %18 = getelementptr inbounds i32, ptr %15, i64 %17
  %19 = load i32, ptr %18, align 4
  %20 = load i32, ptr %7, align 4
  %21 = icmp eq i32 %19, %20
  br i1 %21, label %22, label %23

22:                                               ; preds = %14
  store i32 0, ptr %4, align 4
  br label %53

23:                                               ; preds = %14
  %24 = load i32, ptr %6, align 4
  %25 = load i32, ptr %8, align 4
  %26 = sub nsw i32 %24, %25
  store i32 %26, ptr %9, align 4
  %27 = load ptr, ptr %5, align 8
  %28 = load i32, ptr %8, align 4
  %29 = sext i32 %28 to i64
  %30 = getelementptr inbounds i32, ptr %27, i64 %29
  %31 = load i32, ptr %30, align 4
  %32 = load i32, ptr %7, align 4
  %33 = sub nsw i32 %31, %32
  %34 = load i32, ptr %9, align 4
  %35 = icmp eq i32 %33, %34
  br i1 %35, label %36, label %37

36:                                               ; preds = %23
  store i32 0, ptr %4, align 4
  br label %53

37:                                               ; preds = %23
  %38 = load i32, ptr %7, align 4
  %39 = load ptr, ptr %5, align 8
  %40 = load i32, ptr %8, align 4
  %41 = sext i32 %40 to i64
  %42 = getelementptr inbounds i32, ptr %39, i64 %41
  %43 = load i32, ptr %42, align 4
  %44 = sub nsw i32 %38, %43
  %45 = load i32, ptr %9, align 4
  %46 = icmp eq i32 %44, %45
  br i1 %46, label %47, label %48

47:                                               ; preds = %37
  store i32 0, ptr %4, align 4
  br label %53

48:                                               ; preds = %37
  br label %49

49:                                               ; preds = %48
  %50 = load i32, ptr %8, align 4
  %51 = add nsw i32 %50, 1
  store i32 %51, ptr %8, align 4
  br label %10, !llvm.loop !6

52:                                               ; preds = %10
  store i32 1, ptr %4, align 4
  br label %53

53:                                               ; preds = %52, %47, %36, %22
  %54 = load i32, ptr %4, align 4
  ret i32 %54
}

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @solve(ptr noundef %0, i32 noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca ptr, align 8
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  store ptr %0, ptr %4, align 8
  store i32 %1, ptr %5, align 4
  %8 = load i32, ptr %5, align 4
  %9 = icmp eq i32 %8, 8
  br i1 %9, label %10, label %11

10:                                               ; preds = %2
  store i32 1, ptr %3, align 4
  br label %39

11:                                               ; preds = %2
  store i32 0, ptr %7, align 4
  store i32 0, ptr %6, align 4
  br label %12

12:                                               ; preds = %34, %11
  %13 = load i32, ptr %6, align 4
  %14 = icmp slt i32 %13, 8
  br i1 %14, label %15, label %37

15:                                               ; preds = %12
  %16 = load ptr, ptr %4, align 8
  %17 = load i32, ptr %5, align 4
  %18 = load i32, ptr %6, align 4
  %19 = call i32 @safe(ptr noundef %16, i32 noundef %17, i32 noundef %18)
  %20 = icmp ne i32 %19, 0
  br i1 %20, label %21, label %33

21:                                               ; preds = %15
  %22 = load i32, ptr %6, align 4
  %23 = load ptr, ptr %4, align 8
  %24 = load i32, ptr %5, align 4
  %25 = sext i32 %24 to i64
  %26 = getelementptr inbounds i32, ptr %23, i64 %25
  store i32 %22, ptr %26, align 4
  %27 = load i32, ptr %7, align 4
  %28 = load ptr, ptr %4, align 8
  %29 = load i32, ptr %5, align 4
  %30 = add nsw i32 %29, 1
  %31 = call i32 @solve(ptr noundef %28, i32 noundef %30)
  %32 = add nsw i32 %27, %31
  store i32 %32, ptr %7, align 4
  br label %33

33:                                               ; preds = %21, %15
  br label %34

34:                                               ; preds = %33
  %35 = load i32, ptr %6, align 4
  %36 = add nsw i32 %35, 1
  store i32 %36, ptr %6, align 4
  br label %12, !llvm.loop !8

37:                                               ; preds = %12
  %38 = load i32, ptr %7, align 4
  store i32 %38, ptr %3, align 4
  br label %39

39:                                               ; preds = %37, %10
  %40 = load i32, ptr %3, align 4
  ret i32 %40
}

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca [8 x i32], align 4
  store i32 0, ptr %1, align 4
  %3 = getelementptr inbounds [8 x i32], ptr %2, i64 0, i64 0
  %4 = call i32 @solve(ptr noundef %3, i32 noundef 0)
  ret i32 %4
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
