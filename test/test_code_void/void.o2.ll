; ModuleID = 'void.c'
source_filename = "void.c"
target datalayout = "E-m:e-p:32:32-i64:64-n32"
target triple = "ppc32"

; Function Attrs: norecurse nounwind readnone
define void @test(i32 %a) local_unnamed_addr #0 {
entry:
  ret void
}

; Function Attrs: norecurse nounwind readnone
define i32 @main() local_unnamed_addr #0 {
entry:
  ret i32 0
}

attributes #0 = { norecurse nounwind readnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="ppc" "target-features"="-altivec,-bpermd,-crypto,-direct-move,-extdiv,-power8-vector,-power9-vector,-qpx,-vsx" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}