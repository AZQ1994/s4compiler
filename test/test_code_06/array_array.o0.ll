; ModuleID = 'array_array.c'
source_filename = "array_array.c"
target datalayout = "e-p:32:32-i64:64-v16:16-v32:32-n16:32:64"
target triple = "nvptx"

@arr = global [10 x [10 x i32]] [[10 x i32] [i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9], [10 x i32] [i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 18, i32 19], [10 x i32] [i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29], [10 x i32] [i32 30, i32 31, i32 32, i32 33, i32 34, i32 35, i32 36, i32 37, i32 38, i32 39], [10 x i32] [i32 40, i32 41, i32 42, i32 43, i32 44, i32 45, i32 46, i32 47, i32 48, i32 49], [10 x i32] [i32 50, i32 51, i32 52, i32 53, i32 54, i32 55, i32 56, i32 57, i32 58, i32 59], [10 x i32] [i32 60, i32 61, i32 62, i32 63, i32 64, i32 65, i32 66, i32 67, i32 68, i32 69], [10 x i32] [i32 70, i32 71, i32 72, i32 73, i32 74, i32 75, i32 76, i32 77, i32 78, i32 79], [10 x i32] [i32 80, i32 81, i32 82, i32 83, i32 84, i32 85, i32 86, i32 87, i32 88, i32 89], [10 x i32] [i32 90, i32 91, i32 92, i32 93, i32 94, i32 95, i32 96, i32 97, i32 98, i32 99]], align 4
@c = global i32 0, align 4

; Function Attrs: noinline nounwind
define i32 @array(i32 %i, i32 %j) #0 {
entry:
  %i.addr = alloca i32, align 4
  %j.addr = alloca i32, align 4
  store i32 %i, i32* %i.addr, align 4
  store i32 %j, i32* %j.addr, align 4
  %0 = load i32, i32* @c, align 4
  %inc = add nsw i32 %0, 1
  store i32 %inc, i32* @c, align 4
  %1 = load i32, i32* %i.addr, align 4
  %arrayidx = getelementptr inbounds [10 x [10 x i32]], [10 x [10 x i32]]* @arr, i32 0, i32 %1
  %2 = load i32, i32* %j.addr, align 4
  %arrayidx1 = getelementptr inbounds [10 x i32], [10 x i32]* %arrayidx, i32 0, i32 %2
  %3 = load i32, i32* %arrayidx1, align 4
  ret i32 %3
}

; Function Attrs: noinline nounwind
define i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  %call = call i32 @array(i32 0, i32 1)
  %call1 = call i32 @array(i32 2, i32 3)
  %add = add nsw i32 %call, %call1
  %call2 = call i32 @array(i32 4, i32 5)
  %add3 = add nsw i32 %add, %call2
  %call4 = call i32 @array(i32 6, i32 7)
  %add5 = add nsw i32 %add3, %call4
  %call6 = call i32 @array(i32 8, i32 9)
  %add7 = add nsw i32 %add5, %call6
  ret i32 %add7
}

attributes #0 = { noinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-features"="-satom" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
