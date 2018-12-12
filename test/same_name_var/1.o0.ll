; ModuleID = '1.c'
source_filename = "1.c"
target datalayout = "E-m:e-p:32:32-i64:64-n32"
target triple = "ppc32"

@data = global i32 5, align 4
@temp = global i32 3, align 4

; Function Attrs: noinline nounwind
define i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  %data = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  store i32 10, i32* %data, align 4
  %0 = load i32, i32* @temp, align 4
  %1 = load i32, i32* %data, align 4
  %sub = sub nsw i32 %0, %1
  ret i32 %sub
}

attributes #0 = { noinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="ppc" "target-features"="-altivec,-bpermd,-crypto,-direct-move,-extdiv,-power8-vector,-power9-vector,-qpx,-vsx" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
