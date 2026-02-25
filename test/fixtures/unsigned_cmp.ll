; ModuleID = 'test/fixtures/unsigned_cmp.c'
source_filename = "test/fixtures/unsigned_cmp.c"
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
  store i32 5, ptr %2, align 4
  store i32 -1, ptr %3, align 4
  %12 = load i32, ptr %2, align 4
  %13 = load i32, ptr %3, align 4
  %14 = icmp ult i32 %12, %13
  %15 = zext i1 %14 to i64
  %16 = select i1 %14, i32 1, i32 0
  store i32 %16, ptr %4, align 4
  %17 = load i32, ptr %3, align 4
  %18 = load i32, ptr %2, align 4
  %19 = icmp ult i32 %17, %18
  %20 = zext i1 %19 to i64
  %21 = select i1 %19, i32 1, i32 0
  store i32 %21, ptr %5, align 4
  %22 = load i32, ptr %2, align 4
  %23 = load i32, ptr %2, align 4
  %24 = icmp ult i32 %22, %23
  %25 = zext i1 %24 to i64
  %26 = select i1 %24, i32 1, i32 0
  store i32 %26, ptr %6, align 4
  %27 = load i32, ptr %2, align 4
  %28 = load i32, ptr %2, align 4
  %29 = icmp ule i32 %27, %28
  %30 = zext i1 %29 to i64
  %31 = select i1 %29, i32 1, i32 0
  store i32 %31, ptr %7, align 4
  %32 = load i32, ptr %2, align 4
  %33 = load i32, ptr %3, align 4
  %34 = icmp ugt i32 %32, %33
  %35 = zext i1 %34 to i64
  %36 = select i1 %34, i32 1, i32 0
  store i32 %36, ptr %8, align 4
  %37 = load i32, ptr %3, align 4
  %38 = load i32, ptr %2, align 4
  %39 = icmp uge i32 %37, %38
  %40 = zext i1 %39 to i64
  %41 = select i1 %39, i32 1, i32 0
  store i32 %41, ptr %9, align 4
  store i32 -2, ptr %10, align 4
  %42 = load i32, ptr %10, align 4
  %43 = load i32, ptr %3, align 4
  %44 = icmp ult i32 %42, %43
  %45 = zext i1 %44 to i64
  %46 = select i1 %44, i32 1, i32 0
  store i32 %46, ptr %11, align 4
  %47 = load i32, ptr %4, align 4
  %48 = load i32, ptr %5, align 4
  %49 = add nsw i32 %47, %48
  %50 = load i32, ptr %6, align 4
  %51 = add nsw i32 %49, %50
  %52 = load i32, ptr %7, align 4
  %53 = add nsw i32 %51, %52
  %54 = load i32, ptr %8, align 4
  %55 = add nsw i32 %53, %54
  %56 = load i32, ptr %9, align 4
  %57 = add nsw i32 %55, %56
  %58 = load i32, ptr %11, align 4
  %59 = add nsw i32 %57, %58
  ret i32 %59
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
