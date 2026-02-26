; ModuleID = '/tmp/struct_array.c'
source_filename = "/tmp/struct_array.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx15.0.0"

%struct.Point = type { i32, i32 }

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca [3 x %struct.Point], align 4
  store i32 0, ptr %1, align 4
  %3 = getelementptr inbounds [3 x %struct.Point], ptr %2, i64 0, i64 0
  %4 = getelementptr inbounds %struct.Point, ptr %3, i32 0, i32 0
  store i32 1, ptr %4, align 4
  %5 = getelementptr inbounds [3 x %struct.Point], ptr %2, i64 0, i64 0
  %6 = getelementptr inbounds %struct.Point, ptr %5, i32 0, i32 1
  store i32 2, ptr %6, align 4
  %7 = getelementptr inbounds [3 x %struct.Point], ptr %2, i64 0, i64 1
  %8 = getelementptr inbounds %struct.Point, ptr %7, i32 0, i32 0
  store i32 3, ptr %8, align 4
  %9 = getelementptr inbounds [3 x %struct.Point], ptr %2, i64 0, i64 1
  %10 = getelementptr inbounds %struct.Point, ptr %9, i32 0, i32 1
  store i32 4, ptr %10, align 4
  %11 = getelementptr inbounds [3 x %struct.Point], ptr %2, i64 0, i64 2
  %12 = getelementptr inbounds %struct.Point, ptr %11, i32 0, i32 0
  store i32 5, ptr %12, align 4
  %13 = getelementptr inbounds [3 x %struct.Point], ptr %2, i64 0, i64 2
  %14 = getelementptr inbounds %struct.Point, ptr %13, i32 0, i32 1
  store i32 6, ptr %14, align 4
  %15 = getelementptr inbounds [3 x %struct.Point], ptr %2, i64 0, i64 0
  %16 = getelementptr inbounds %struct.Point, ptr %15, i32 0, i32 0
  %17 = load i32, ptr %16, align 4
  %18 = getelementptr inbounds [3 x %struct.Point], ptr %2, i64 0, i64 1
  %19 = getelementptr inbounds %struct.Point, ptr %18, i32 0, i32 1
  %20 = load i32, ptr %19, align 4
  %21 = add nsw i32 %17, %20
  %22 = getelementptr inbounds [3 x %struct.Point], ptr %2, i64 0, i64 2
  %23 = getelementptr inbounds %struct.Point, ptr %22, i32 0, i32 0
  %24 = load i32, ptr %23, align 4
  %25 = add nsw i32 %21, %24
  ret i32 %25
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
