; ModuleID = 'test_code_05/array.c'
source_filename = "test_code_05/array.c"
target datalayout = "e-p:32:32-i64:64-v16:16-v32:32-n16:32:64"
target triple = "nvptx"

@arr.array = private unnamed_addr constant [10 x i32] [i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9], align 4

; Function Attrs: noinline nounwind
define i32 @arr(i32 %i) #0 {
entry:
  %i.addr = alloca i32, align 4
  %array = alloca [10 x i32], align 4
  store i32 %i, i32* %i.addr, align 4
  %0 = bitcast [10 x i32]* %array to i8*
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %0, i8* bitcast ([10 x i32]* @arr.array to i8*), i32 40, i32 4, i1 false)
  %1 = load i32, i32* %i.addr, align 4
  %arrayidx = getelementptr inbounds [10 x i32], [10 x i32]* %array, i32 0, i32 %1
  %2 = load i32, i32* %arrayidx, align 4
  ret i32 %2
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i32(i8* nocapture writeonly, i8* nocapture readonly, i32, i32, i1) #1

; Function Attrs: noinline nounwind
define i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  %call = call i32 @arr(i32 5)
  ret i32 %call
}

attributes #0 = { noinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-features"="-satom" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 4.0.0 (tags/RELEASE_400/final)"}
