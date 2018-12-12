; ModuleID = '2.c'
source_filename = "2.c"
target datalayout = "E-m:e-p:32:32-i64:64-n32"
target triple = "ppc32"

@a = local_unnamed_addr global i32 1, align 4
@b = local_unnamed_addr global i32 2, align 4
@c = common local_unnamed_addr global i32 0, align 4

; Function Attrs: norecurse nounwind
define i32 @main() local_unnamed_addr #0 {
entry:
  %0 = load i32, i32* @a, align 4, !tbaa !1
  %add = shl nsw i32 %0, 1
  store i32 %add, i32* @c, align 4, !tbaa !1
  ret i32 %0
}

attributes #0 = { norecurse nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="ppc" "target-features"="-altivec,-bpermd,-crypto,-direct-move,-extdiv,-power8-vector,-power9-vector,-qpx,-vsx" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
!1 = !{!2, !2, i64 0}
!2 = !{!"int", !3, i64 0}
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
