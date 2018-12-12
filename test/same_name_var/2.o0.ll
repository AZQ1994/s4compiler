; ModuleID = '2.c'
source_filename = "2.c"
target datalayout = "E-m:e-p:32:32-i64:64-n32"
target triple = "ppc32"

@a = global i32 1, align 4
@b = global i32 2, align 4
@c = common global i32 0, align 4

; Function Attrs: noinline nounwind
define i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  %i = alloca i32, align 4
  %i1 = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  %0 = load i32, i32* @a, align 4
  store i32 %0, i32* %i, align 4
  %1 = load i32, i32* @b, align 4
  store i32 %1, i32* %i1, align 4
  %2 = load i32, i32* %i, align 4
  %3 = load i32, i32* @a, align 4
  %add = add nsw i32 %2, %3
  store i32 %add, i32* @c, align 4
  %4 = load i32, i32* %i, align 4
  ret i32 %4
}

attributes #0 = { noinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="ppc" "target-features"="-altivec,-bpermd,-crypto,-direct-move,-extdiv,-power8-vector,-power9-vector,-qpx,-vsx" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
