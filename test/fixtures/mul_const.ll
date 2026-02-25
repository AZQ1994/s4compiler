; ModuleID = '/Users/jingyuan.zhao/Desktop/subneg4-js/s4c/test/fixtures/mul_const.c'
source_filename = "/Users/jingyuan.zhao/Desktop/subneg4-js/s4c/test/fixtures/mul_const.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx15.0.0"

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  store i32 7, ptr %2, align 4
  %12 = load i32, ptr %2, align 4
  %13 = mul nsw i32 %12, 0
  store i32 %13, ptr %3, align 4
  %14 = load i32, ptr %2, align 4
  %15 = mul nsw i32 %14, 1
  store i32 %15, ptr %4, align 4
  %16 = load i32, ptr %2, align 4
  %17 = mul nsw i32 %16, 2
  store i32 %17, ptr %5, align 4
  %18 = load i32, ptr %2, align 4
  %19 = mul nsw i32 %18, 3
  store i32 %19, ptr %6, align 4
  %20 = load i32, ptr %2, align 4
  %21 = mul nsw i32 %20, 8
  store i32 %21, ptr %7, align 4
  %22 = load i32, ptr %2, align 4
  %23 = mul nsw i32 0, %22
  store i32 %23, ptr %8, align 4
  %24 = load i32, ptr %2, align 4
  %25 = mul nsw i32 1, %24
  store i32 %25, ptr %9, align 4
  %26 = load i32, ptr %2, align 4
  %27 = mul nsw i32 %26, -1
  store i32 %27, ptr %10, align 4
  %28 = load i32, ptr %2, align 4
  %29 = mul nsw i32 %28, -3
  store i32 %29, ptr %11, align 4
  %30 = load i32, ptr %3, align 4
  %31 = load i32, ptr %4, align 4
  %32 = add nsw i32 %30, %31
  %33 = load i32, ptr %5, align 4
  %34 = add nsw i32 %32, %33
  %35 = load i32, ptr %6, align 4
  %36 = add nsw i32 %34, %35
  %37 = load i32, ptr %7, align 4
  %38 = add nsw i32 %36, %37
  %39 = load i32, ptr %8, align 4
  %40 = add nsw i32 %38, %39
  %41 = load i32, ptr %9, align 4
  %42 = add nsw i32 %40, %41
  %43 = load i32, ptr %10, align 4
  %44 = add nsw i32 %42, %43
  %45 = load i32, ptr %11, align 4
  %46 = add nsw i32 %44, %45
  ret i32 %46
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
