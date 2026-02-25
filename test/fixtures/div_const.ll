; ModuleID = '/Users/jingyuan.zhao/Desktop/subneg4-js/s4c/test/fixtures/div_const.c'
source_filename = "/Users/jingyuan.zhao/Desktop/subneg4-js/s4c/test/fixtures/div_const.c"
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
  store i32 0, ptr %1, align 4
  store i32 42, ptr %2, align 4
  %9 = load i32, ptr %2, align 4
  %10 = sdiv i32 %9, 1
  store i32 %10, ptr %3, align 4
  %11 = load i32, ptr %2, align 4
  %12 = sdiv i32 %11, -1
  store i32 %12, ptr %4, align 4
  %13 = load i32, ptr %2, align 4
  %14 = srem i32 %13, 1
  store i32 %14, ptr %5, align 4
  %15 = load i32, ptr %2, align 4
  %16 = srem i32 %15, -1
  store i32 %16, ptr %6, align 4
  %17 = load i32, ptr %2, align 4
  %18 = sdiv i32 0, %17
  store i32 %18, ptr %7, align 4
  %19 = load i32, ptr %2, align 4
  %20 = srem i32 0, %19
  store i32 %20, ptr %8, align 4
  %21 = load i32, ptr %3, align 4
  %22 = load i32, ptr %4, align 4
  %23 = add nsw i32 %21, %22
  %24 = load i32, ptr %5, align 4
  %25 = add nsw i32 %23, %24
  %26 = load i32, ptr %6, align 4
  %27 = add nsw i32 %25, %26
  %28 = load i32, ptr %7, align 4
  %29 = add nsw i32 %27, %28
  %30 = load i32, ptr %8, align 4
  %31 = add nsw i32 %29, %30
  %32 = add nsw i32 %31, 100
  ret i32 %32
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
