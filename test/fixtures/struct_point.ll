; ModuleID = 'struct_point.c'
source_filename = "struct_point.c"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx15.0.0"

%struct.Point = type { i32, i32 }

; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca %struct.Point, align 4
  store i32 0, ptr %1, align 4
  %3 = getelementptr inbounds %struct.Point, ptr %2, i32 0, i32 0
  store i32 10, ptr %3, align 4
  %4 = getelementptr inbounds %struct.Point, ptr %2, i32 0, i32 1
  store i32 20, ptr %4, align 4
  %5 = getelementptr inbounds %struct.Point, ptr %2, i32 0, i32 0
  %6 = load i32, ptr %5, align 4
  %7 = getelementptr inbounds %struct.Point, ptr %2, i32 0, i32 1
  %8 = load i32, ptr %7, align 4
  %9 = add nsw i32 %6, %8
  ret i32 %9
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
